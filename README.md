# wheels-basecoat

A Wheels package that ships CFML view helpers for [Basecoat UI](https://basecoatui.com) — shadcn/ui-quality components rendered as plain HTML. **No React, no build step, no Tailwind compile pipeline.** The package bundles the basecoat-css 0.3.x stylesheet and the basecoat-js component scripts so a fresh install is one copy + one helper call away from rendered components.

## Highlights

- **Zero-build**: the package ships the compiled CSS + JS for basecoat-css 0.3.11. `cp -r vendor/wheels-basecoat/assets public/` and you're styled.
- **Wheels-native form binding**: `uiBoundField(objectName="post", property="title")` auto-resolves value, error, and `name="post[title]"` from the controller-scoped model — same ergonomics as `textField`.
- **Hotwire-aware**: `turboStream(action="remove", target="post_X")` content-block helpers, `turboStreamHeader()` for the `text/vnd.turbo-stream.html` Content-Type, `uiButton(turboConfirm=, turboMethod=)`, and a CSP-safe dialog opener that's drop-in friendly inside frames.
- **Dark mode** out of the box: `basecoatThemeScript()` (synchronous pre-paint theme application) + `uiThemeToggle()` (delegated, CSP-safe).
- **Argument validation**: typos in `variant` / `size` / `type` throw `WheelsBasecoat.InvalidArgument` with the allowed list — instead of silently rendering `class="btn-primay"` and leaving you puzzled.
- **CSP-safe**: no inline `onclick` or `style` attributes on the rendered output. Dialog open/close + theme toggle delegate via `data-ui-*` attributes handled by a tiny vendored script.

## Requirements

- Wheels 4.0+
- Lucee 7.0+ or Adobe ColdFusion 2021+

## Installation

```bash
# Install the package
wheels packages add wheels-basecoat
# (or, manually) cp -r packages/basecoat vendor/wheels-basecoat

# Publish the bundled CSS+JS to your app's public/ directory
cp -r vendor/wheels-basecoat/assets/basecoat public/assets/basecoat

# Reload
wheels reload
```

After this all `ui*` and `basecoat*` helpers are in scope in controllers and views.

## Quickstart

```cfm
<!-- app/views/layout.cfm -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My App</title>

    <cfoutput>
        <!-- Apply saved dark/light theme before paint to avoid the FOUC -->
        #basecoatThemeScript()#
        #csrfMetaTags()#
        #basecoatIncludes()#
    </cfoutput>
</head>
<body class="bg-background text-foreground">
    <header class="border-b sticky top-0 z-10">
        <div class="container mx-auto max-w-5xl px-4 py-3 flex items-center justify-between">
            <a href="/" class="text-lg font-semibold">My App</a>
            <cfoutput>#uiThemeToggle()#</cfoutput>
        </div>
    </header>

    <main>
        <cfoutput>#includeContent()#</cfoutput>
    </main>

    <!-- Toaster for flash messages — renders nothing if no flash present -->
    <cfoutput>#basecoatFlashToasts()#</cfoutput>
</body>
</html>
```

```cfm
<!-- app/views/posts/_form.cfm -->
<cfoutput>
<turbo-frame id="post_form">
    <cfif post.hasErrors()>
        #uiAlert(
            title="Couldn't save the post",
            description="Please fix the highlighted fields below.",
            variant="destructive"
        )#
    </cfif>

    #startFormTag(action=isEdit ? "update" : "create", key=post.id ?: "")#
        #uiBoundField(objectName="post", property="title", required=true,
                      description="Up to 120 characters.")#

        #uiBoundField(objectName="post", property="body", type="textarea",
                      rows=10, required=true)#

        <div class="grid gap-4 sm:grid-cols-2">
            #uiBoundField(objectName="post", property="status", type="select",
                          options="draft:Draft,published:Published,archived:Archived")#
            #uiBoundField(objectName="post", property="publishedAt", type="datetime-local")#
        </div>

        <div class="flex justify-end gap-2 pt-2">
            <a href="#urlFor(route='posts')#" class="btn-ghost" data-turbo-frame="_top">Cancel</a>
            #uiButton(text=isEdit ? "Save changes" : "Publish post", type="submit", icon="check")#
        </div>
    #endFormTag()#
</turbo-frame>
</cfoutput>
```

That snippet — eight lines of meaningful markup — renders a fully-styled, label-bound, error-aware, Turbo-friendly form. The same form pre-2.0 was three times longer and required manual error-message wiring.

## Configuration

The only configurable helper is `basecoatIncludes()`. Defaults assume the bundled assets have been published to `public/assets/basecoat/`.

```cfml
#basecoatIncludes(
    cssPath = "/assets/basecoat/basecoat.min.css",
    jsPath = "/assets/basecoat/js/all.min.js",
    uiJsPath = "/assets/basecoat/js/wheels-basecoat-ui.min.js",
    basecoatJS = true,
    uiJS = true,
    alpine = false,
    alpineVersion = "3",
    turboAware = true
)#
```

| Argument | Default | Purpose |
|---|---|---|
| `cssPath` | `/assets/basecoat/basecoat.min.css` | URL to the basecoat-css stylesheet. |
| `jsPath` | `/assets/basecoat/js/all.min.js` | URL to the basecoat-js component bundle (drives tabs, dropdown, popover, select, command, sidebar, toast). |
| `uiJsPath` | `/assets/basecoat/js/wheels-basecoat-ui.min.js` | Tiny script that delegates dialog open/close + theme toggle. CSP-safe replacement for inline `onclick`. |
| `basecoatJS` | `true` | Load basecoat-js. |
| `uiJS` | `true` | Load the wheels-basecoat-ui shim. |
| `alpine` | `false` | Optional — load Alpine.js. **Not required by any built-in helper.** Pre-2.0 default was `true`. |
| `alpineVersion` | `"3"` | Alpine major version when `alpine=true`. |
| `turboAware` | `true` | Emit `<meta name="turbo-cache-control" content="no-preview">`. Recommended any time Turbo is loaded. |

## Component reference

| Category | Helpers |
|---|---|
| **Setup** | `basecoatIncludes`, `basecoatThemeScript` |
| **Buttons & display** | `uiButton`, `uiButtonGroup` / `uiButtonGroupSeparator` / `uiButtonGroupEnd`, `uiBadge`, `uiAvatar`, `uiKbd`, `uiIcon`, `uiSpinner`, `uiSkeleton`, `uiProgress`, `uiSeparator` |
| **Feedback** | `uiAlert`, `uiTooltip`, `uiToaster`, `uiToast`, `basecoatFlashToasts` |
| **Containers** | `uiCard` / `uiCardHeader` / `uiCardContent` / `uiCardFooter` / `uiCardEnd`, `uiFieldset` / `uiFieldsetEnd` |
| **Overlays** | `uiDialog` / `uiDialogFooter` / `uiDialogEnd`, `uiPopover` / `uiPopoverTrigger` / `uiPopoverContent` / `uiPopoverEnd` |
| **Forms** | `uiField`, `uiBoundField` (Wheels-bound) |
| **Tables** | `uiTable` / `uiTableHeader` / `uiTableBody` / `uiTableRow` / `uiTableHead` / `uiTableCell` + `*End` helpers |
| **Navigation** | `uiTabs`, `uiDropdown`, `uiPagination`, `uiBreadcrumb`, `uiSidebar` |
| **Theme** | `uiThemeToggle` |
| **Hotwire** | `turboStream`, `turboStreamEnd`, `turboStreamHeader` |

Visit `/wheels/packages/wheels-basecoat` (the package's own `index.cfm`) for a live showcase of every component with its source.

## Wheels form binding (`uiBoundField`)

The killer feature for tutorial users. Pass an `objectName` (a controller-scoped model) and a `property`; the helper wires up:

- the input `name` (`<objectName>[<property>]` — Rails-style)
- the input `value` from `obj[property]` (with date type coercion to ISO format)
- the error message from `obj.errorsOn(property)[1].message` when validation has failed (also adds the `border-destructive` red border)
- the `<label>` text (humanized from the property name — `firstName` → `First name`)

```cfml
#uiBoundField(objectName="post", property="title")#
```

…is equivalent to `uiField(label="Title", name="post[title]", value=post.title, errorMessage=post.hasErrors("title") ? post.errorsOn("title")[1].message : "")`. Multiply that across a five-field form and the savings are obvious.

## Hotwire / Turbo

```cfml
<!-- A "remove me from the list" Turbo Stream response, rendered from a controller partial -->
<cfoutput>
#turboStreamHeader()#
#turboStream(action="remove", target="post_#postId#")#
</cfoutput>
```

```cfml
<!-- An "append to the comments" Turbo Stream response with content -->
<cfoutput>
#turboStreamHeader()#
#turboStream(action="append", target="comments")#
    <article id="comment_#comment.id#">#comment.body#</article>
#turboStreamEnd()#
</cfoutput>
```

Buttons and forms cooperate with Turbo natively:

```cfml
#uiButton(text="Delete", variant="destructive",
          turboConfirm="Delete this post? This cannot be undone.",
          turboMethod="delete", href=urlFor(route="post", key=post.id))#
```

## Dark mode

```cfm
<head>
    <cfoutput>#basecoatThemeScript()#</cfoutput>  <!-- runs before paint -->
    <cfoutput>#basecoatIncludes()#</cfoutput>
</head>
<body>
    <cfoutput>#uiThemeToggle()#</cfoutput>
</body>
```

`basecoatThemeScript()` reads `localStorage["basecoat:theme"]` (or falls back to `prefers-color-scheme: dark`) and applies `.dark` to `<html>` synchronously. `uiThemeToggle()` renders a sun/moon button that flips the class and persists the choice. The toggle uses a `data-ui-theme-toggle` attribute handled by `wheels-basecoat-ui.js` — no inline JS, so it works under strict CSP.

## Argument validation

Typos throw clear errors instead of silently rendering broken markup:

```cfml
#uiButton(text="Save", variant="primay")#
<!-- WheelsBasecoat.InvalidArgument: uiButton() received an unsupported variant value: 'primay'.
     Allowed values are: primary,secondary,destructive,outline,ghost,link. -->
```

Validated args: `uiButton.variant`, `uiButton.size`, `uiBadge.variant`, `uiAlert.variant`, `uiField.type`, `uiToast.variant`, `uiButtonGroup.orientation`, `turboStream.action`, `uiThemeToggle.size`.

## Deactivating

```bash
rm -rf vendor/wheels-basecoat
rm -rf public/assets/basecoat
wheels reload
```

## Versioning & compatibility

- The plugin tracks **basecoat-css 0.3.x**. The bundled CSS+JS pin to a specific patch (see `package.json::basecoatCSSVersion`).
- Helpers emit semantic markup (`<header>` / `<section>` / `<footer>` for cards) that basecoat-css 0.3.x's selectors expect. Pre-1.1 emitted older `.card-header` div+class markup that 0.3.x silently ignored.
- `uiBoundField` uses Wheels' `errorsOn` / `hasErrors` API. Tested against Wheels 4.0+.

## Reference

- `CLAUDE.md` — markup reference for AI-assisted contributions
- `.ai/ARCHITECTURE.md` — design principles, phase plan, future component inventory
- [Basecoat UI](https://basecoatui.com) — upstream CSS component library
- [Hotwire Turbo](https://turbo.hotwired.dev/) — for the Turbo Stream contract

## License

MIT
