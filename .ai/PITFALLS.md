# Pitfalls

Bugs that bite hardest when writing CFML for a wheels-basecoat app. Each entry has the symptom (what you'll see), the cause, and the fix.

## 1. CFML's null-coalescing operator is `?:` not `??`

**Symptom:**
```
Lucee 7.0.0.395 Error (template)
Syntax Error, Invalid Construct ; Failed at [/path/Basecoat.cfc:1870]
```
…followed by every subsequent request:
```
Application Error: No matching function [UIBADGE] found
```

**Cause:** Lucee 7 doesn't support the JS `??` nullish-coalescing operator. The whole component fails to compile, the `PackageLoader` mixin doesn't activate, and every `ui*` call goes undefined.

**Fix:**
```cfml
// ❌ wrong
var raw = obj[arguments.property] ?? "";

// ✅ right
var raw = obj[arguments.property] ?: "";
```

CFML uses the Elvis operator `?:` (no second char). Mental model: it's a SafeNavigation operator, not a JS-style nullish coalesce.

## 2. Hash-escape unbalance inside `<cfoutput>`

**Symptom:**
```
Syntax Error, Invalid Construct ; Failed at [/path/index.cfm:50]
```
…on a line that contains code samples in a `<pre><code>` block.

**Cause:** Inside `<cfoutput>`, `##` is the escape for a literal `#`. Three or five `#` characters in a row are unbalanced — `###expr##` parses as `##` (one literal `#`) + `#expr#` (expression) + `#` (start of unclosed expression).

**Fix:** Two ways:
- **Close `</cfoutput>` around the code block, then reopen.** `#` outside `<cfoutput>` is just a character.
- **Use exactly four hashes** for a single literal `#expr#`: `##expr##`.

```cfm
<!-- ❌ wrong (5 #s, parser error) -->
<cfoutput>
<pre><code>###uiButton(text="Save")##</code></pre>
</cfoutput>

<!-- ✅ right (close cfoutput around the literal source) -->
<cfoutput>
</cfoutput><pre><code>#uiButton(text="Save")#</code></pre><cfoutput>
</cfoutput>

<!-- ✅ also right (4 #s, escapes to literal #expr#) -->
<cfoutput>
<pre><code>##uiButton(text="Save")##</code></pre>
</cfoutput>
```

## 3. `_form.cfm` partial chrome belongs in `new.cfm`/`edit.cfm`, NOT in the partial

**Symptom:** After a validation failure, the page shows nested breadcrumbs / nested page headers / a card-inside-a-card.

**Cause:** A `_form.cfm` partial that's wrapped in `<turbo-frame id="post_form">` will be returned alone by `renderPartial(partial="form", layout=false)` on validation failure. Turbo then finds the matching frame in the response and swaps it. If the partial contains breadcrumbs/h1/uiCard, they'll appear nested inside the existing chrome on the page.

**Fix:** Keep `_form.cfm` minimal — `<turbo-frame id="post_form">` as the outermost element, just the form fields inside. Put breadcrumbs, page header, and `uiCard` chrome in `new.cfm` / `edit.cfm` around `#includePartial("form")#`.

```cfm
<!-- ✅ _form.cfm -->
<cfoutput>
<turbo-frame id="post_form">
  ##uiErrorSummary(post)##
  ##startFormTag(action=isEdit ? "update" : "create", key=post.id ?: "")##
    ##uiBoundField(objectName="post", property="title")##
    ...
  ##endFormTag()##
</turbo-frame>
</cfoutput>

<!-- ✅ edit.cfm -->
<cfoutput>
<main class="container mx-auto py-8 max-w-3xl px-4">
    ##uiBreadcrumb()##
        ##uiBreadcrumbItem(text="Posts", href=urlFor(route="posts"))##
        ##uiBreadcrumbSeparator()##
        ##uiBreadcrumbItem(text="Edit")##
    ##uiBreadcrumbEnd()##
    <h1>Edit post</h1>
    ##uiCard()#####uiCardContent()##
        ##includePartial("form")##
    ##uiCardContentEnd()#####uiCardEnd()##
</main>
</cfoutput>
```

## 4. Links inside `<turbo-frame>` are frame-scoped — "Content missing"

**Symptom:** Clicking Cancel on a form (or a breadcrumb link, or any `<a>` inside a frame) shows the text "Content missing" inside the frame instead of navigating.

**Cause:** Turbo treats links inside a `<turbo-frame>` as frame submissions. It expects the response to contain a matching `<turbo-frame>` element with the same id; when it doesn't, Turbo surfaces "Content missing" inside the frame.

**Fix:** Add `data-turbo-frame="_top"` to the link to force a top-level navigation:

```cfm
<!-- ❌ Cancel inside <turbo-frame id="post_form"> with no escape — Content missing. -->
<a href="##urlFor(route='posts')##" class="btn-ghost">Cancel</a>

<!-- ✅ Breaks out to the top frame. -->
<a href="##urlFor(route='posts')##" class="btn-ghost" data-turbo-frame="_top">Cancel</a>
```

For form Save success: Wheels' `redirectTo` returns 302 → Turbo follows → top-level navigation, no escape needed.

## 5. `buttonTo` puts kwargs on the FORM by default

**Symptom:** `buttonTo(class="btn-destructive")` renders an unstyled button. The class is on the `<form>` instead.

**Cause:** Wheels' `buttonTo` generates a `<form>` containing a single `<button>`. By default, kwargs land on the form. The button gets `class=""`.

**Fix:** Use `inputClass=` for the inner button. `class=` for the form (e.g. `class="inline-block"` for layout). Hyphenated attributes like `data-turbo-confirm` must be written `data_turbo_confirm` — Wheels converts underscores to hyphens.

```cfm
<!-- ❌ Class on form, button unstyled -->
##buttonTo(route="post", key=post.id, text="Delete", method="delete", class="btn-destructive")##

<!-- ✅ Class on button via inputClass; turbo confirm via data_ attrs -->
##buttonTo(
    route="post",
    key=post.id,
    text="Delete",
    method="delete",
    class="inline-block",
    inputClass="btn-destructive",
    data_turbo_confirm="Delete this? This cannot be undone.",
    data_turbo_stream="true"
)##
```

## 6. Turbo Stream responses need the right Content-Type

**Symptom:** A controller that's supposed to respond with `<turbo-stream>` elements navigates the page instead. Or the stream doesn't apply (DOM doesn't change).

**Cause:** Turbo 8 strictly checks the response Content-Type. Without `text/vnd.turbo-stream.html` it treats the response as plain HTML and either tries to swap a frame or does a full visit.

**Fix:** Always emit `turboStreamHeader()` at the top of any Turbo Stream partial:

```cfm
<!-- ✅ app/views/posts/_postRemoved.cfm -->
<cfparam name="postId" default="0">
<cfoutput>
##turboStreamHeader()##
##turboStream(action="remove", target="post_##postId##")##
</cfoutput>
```

Wheels controllers detect Turbo Stream requests via the request headers — the standard pattern is:

```cfml
function delete() {
    post = params.post;
    ownershipCheck(post);
    var deletedId = post.id;
    post.delete();
    var headers = getHttpRequestData().headers;
    var accept = StructKeyExists(headers, "Accept") ? headers.Accept : (cgi.http_accept ?: "");
    if (accept contains "turbo-stream") {
        renderPartial(partial="postRemoved", postId=deletedId, layout=false);
    } else {
        redirectTo(route="posts");
    }
}
```

The form on the index card needs `data_turbo_stream="true"` for Turbo to advertise the stream Accept header.

## 7. Forgot `super.config()` — CSRF token not emitted

**Symptom:** Form submissions to a sibling controller (Comments, etc.) fail with `Wheels.InvalidAuthenticityToken: This POSTed request was attempted without a valid authenticity token.`

**Cause:** The base `Controller.cfc` calls `protectsFromForgery()` in its own `config()`. If a child controller defines its own `config()` without calling `super.config()`, that protection is skipped — Wheels' `startFormTag` checks `$isRequestProtectedFromForgery()` to decide whether to emit the `authenticityToken` hidden field, and skips it for unprotected controllers. The form rendered on a Posts page that submits to Comments will be missing the token, and Comments (which DOES inherit the protection) rejects the submission.

**Fix:** Always `super.config()` in child controllers that override `config()`:

```cfml
component extends="Controller" {

    function config() {
        super.config();   // ← critical: keeps protectsFromForgery() active
        filters(through="authenticate", except="index,show");
    }

    ...
}
```

## 8. Wheels DI services drop after idle / code edits

**Symptom:** Random pages 500 with `Wheels.DI.ServiceNotFound: No service registered with the name 'authenticator'.`

**Cause:** Wheels' DI registry can drop services after long idle periods or after code edits that trigger application reloads. Subsequent requests look up `application.wo.service("authenticator")` and find nothing.

**Fix:** Wrap the lookup in a try/catch in helpers that need it, treating "service not found" as "not authenticated":

```cfml
private struct function $authResult() {
    try {
        return application.wo.service("authenticator").authenticate(request);
    } catch (any e) {
        return {success: false};
    }
}
```

Recovery (one-off): `?reload=true&password=<your-reload-password>` (the password is in `config/settings.cfm::reloadPassword`).

## 9. Lucee `cgi.http_accept` may be empty

**Symptom:** Your Turbo Stream branch in a controller (`if cgi.http_accept contains "turbo-stream"`) never fires even though Turbo is sending the right header.

**Cause:** Some Lucee/CGI shim configurations leave `cgi.http_accept` empty or stale.

**Fix:** Read from `getHttpRequestData().headers.Accept` first, fall back to CGI:

```cfml
var headers = getHttpRequestData().headers;
var accept = StructKeyExists(headers, "Accept") ? headers.Accept : (cgi.http_accept ?: "");
```

## 10. The `[email protected]` CDN URL gets mangled by email-obfuscation

**Symptom:** Loading Turbo from `https://cdn.jsdelivr.net/npm/@hotwired/[email protected]/...` 503s; the rendered URL in the browser shows `[email%20protected]` instead of `[email protected]`.

**Cause:** Cloudflare-style email-obfuscation heuristics treat the `name@version` pattern as an email address and rewrite it.

**Fix:** Vendor Turbo locally (or use any CDN URL form that doesn't include `@version`):

```html
<script type="module" src="/javascripts/turbo.es2017-esm.min.js"></script>
```

The wheels-basecoat package's bundled assets sidestep this entirely — `basecoatIncludes()` references the local `/assets/basecoat/...` paths.

## 11. Private package methods don't reach the controller scope

**Symptom:** A helper that calls another helper internally throws `No matching function [$X] found`.

**Cause:** Wheels' `PackageLoader` only mixes PUBLIC methods of the package CFC into the target scope. Private methods stay on the CFC — they're not visible from the mixed-in `variables` scope where helpers run when called from views.

**Fix:** Make any method that's called by another (mixed-in) helper `public`. Use the `$` prefix to signal "internal — don't call from app code" while keeping it visible across the mixin boundary:

```cfml
public string function uiBadge(text) {
    $validateEnum(text, "...");   // ← called from mixed-in scope
}

// Must be `public` even though the `$` prefix says "internal"
public void function $validateEnum(value, allowed, helper, argument) { ... }
```

## 12. Posts list `posts.comments.recordCount` doesn't work

**Symptom:** A view that uses `posts.comments.recordCount` after `model("Post").findAll(include="comments")` throws or returns 0 unexpectedly.

**Cause:** Wheels' `include="comments"` flattens the joined columns onto the parent row rather than nesting a child query. There's no `.comments` sub-collection on each row.

**Fix:** Use a per-row `model("Comment").count(where="postId=#posts.id#")`. It's technically N+1 but it's a small N and the alternative requires controller-side aggregation.

## 13. `<input type="date">` value format mismatch

**Symptom:** An edit form with `type="date"` shows an empty date field even though the model has a value.

**Cause:** Lucee/Wheels' default datetime serialization (`{ts '2026-05-01 14:00:00'}` style) doesn't match the `YYYY-MM-DD` format that `<input type="date">` requires. The browser silently rejects the value as invalid.

**Fix:** `uiBoundField(type="date")` and `uiBoundField(type="datetime-local")` already coerce the model value to the correct ISO format. If you're hand-rolling, use `DateFormat(value, "yyyy-mm-dd")` or `DateTimeFormat(value, "yyyy-mm-dd'T'HH:nn")`.

## 14. Lucee stores datetimes wrapped in literal quotes

**Symptom:** `DateFormat(post.publishedAt, "mmm d, yyyy")` 500s. The raw value looks like `'2026-05-01 14:00:00'` (literal quotes included).

**Cause:** Some Wheels adapter / Lucee combinations store datetime columns as quote-wrapped strings.

**Fix:** Strip the quotes defensively before formatting:

```cfml
var cleaned = Replace(Trim(post.publishedAt ?: ""), "'", "", "all");
var display = (Len(cleaned) && IsDate(cleaned))
    ? DateFormat(cleaned, "mmm d, yyyy")
    : "";
```

`uiBoundField(type=date|datetime-local|time)` already does this.
