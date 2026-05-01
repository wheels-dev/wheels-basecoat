# wheels-basecoat (for AI coding assistants)

You are writing CFML in a Wheels 4 application that has the **wheels-basecoat** package installed. This document tells you everything you need to know to write idiomatic, correct code that uses the package's helpers.

## Read order

1. **This file** — package architecture, helper inventory, the rules of the road.
2. **`.ai/PATTERNS.md`** — when to use which helper. Decision trees.
3. **`.ai/PITFALLS.md`** — known footguns. Skim before writing CFML.
4. **`.ai/EXAMPLES.md`** — scenario-driven recipes. Find the closest match before composing your own.
5. **`.ai/SCAFFOLDS.md`** — copy-paste templates for index / show / new / edit / login / signup / dashboard pages.
6. **`.ai/HELPERS.md`** — formal signature reference for every helper.

## What this package is

A Wheels 4.0+ package that ships:

- **Bundled `basecoat-css` 0.3.11** — the upstream CSS framework, pinned to a known-good version, copied into `assets/basecoat/basecoat.min.css`.
- **Bundled `basecoat-js`** — the upstream interactive component scripts (`tabs.js`, `dropdown-menu.js`, `popover.js`, `select.js`, `command.js`, `sidebar.js`, `toast.js`) plus an `all.min.js` aggregate.
- **`wheels-basecoat-ui.js`** — a tiny CSP-safe shim for dialog open/close + theme toggle + sidebar toggle + slider live mirror, all delegated via `data-ui-*` attributes (no inline event handlers).
- **`wheels-basecoat-extras.min.css`** — visual defaults for components basecoat-css doesn't ship CSS for (breadcrumb, pagination, steps, rating, radio).
- **~80 CFML helpers** that emit basecoat-styled HTML, in a single `Basecoat.cfc`.
- **Argument validation** that throws `WheelsBasecoat.InvalidArgument` with helpful detail for unsupported variant/size/type values.

The whole point: a Wheels developer never has to think about basecoat-css's class names or basecoat-js's contracts. They write `#uiBoundField(objectName="post", property="title")#` and get a fully styled, model-bound, error-aware form field.

## Package architecture

Standard Wheels package. The main CFC (`Basecoat.cfc`) contains `init()` and all public helpers. Wheels' `PackageLoader` injects every public method into the controller scope via the `provides.mixins: "controller"` declaration in `package.json`. Because Wheels views execute in the controller's `variables` scope, the helpers surface transitively in views — call them as `#functionName()#` in any view file.

```
wheels-basecoat/
├── CLAUDE.md                 # This file (AI tools read first)
├── README.md                 # Human-facing docs
├── CHANGELOG.md
├── Basecoat.cfc              # Main package CFC — every helper lives here
├── package.json              # Wheels package manifest
├── box.json                  # CommandBox metadata + install hooks
├── index.cfm                 # Doc page rendered at /wheels/packages/wheels-basecoat
├── .ai/
│   ├── HELPERS.md            # Formal signature reference (every helper)
│   ├── EXAMPLES.md           # Scenario-driven recipes
│   ├── SCAFFOLDS.md          # Copy-paste page templates
│   ├── PATTERNS.md           # When to use which helper
│   ├── PITFALLS.md           # Known footguns
│   └── ARCHITECTURE.md       # Long-form design context
├── assets/basecoat/
│   ├── basecoat.min.css      # Bundled basecoat-css 0.3.11
│   ├── wheels-basecoat-extras.min.css  # Our additions
│   └── js/
│       ├── all.min.js        # All basecoat-js modules in one file
│       ├── basecoat.min.js   # Just the registration kernel
│       ├── tabs.min.js / dropdown-menu.min.js / popover.min.js / select.min.js
│       ├── command.min.js / sidebar.min.js / toast.min.js
│       └── wheels-basecoat-ui.min.js   # Our CSP-safe shim
├── examples/showcase/        # Mountable live-render showcase (see "Showcase" below)
├── scripts/install.cfm       # CommandBox install hook (publishes assets to public/)
└── tests/
    ├── BasecoatSimpleSpec.cfc
    ├── BasecoatComplexSpec.cfc
    ├── BasecoatV2Spec.cfc / V21Spec / V22Spec / V23Spec / V24Spec
    └── BasecoatV30Spec.cfc
```

## Setup

The first thing every Wheels app needs in its layout:

```cfm
<head>
    <cfoutput>
        ##basecoatThemeScript()##           <!-- pre-paint theme to avoid FOUC -->
        ##csrfMetaTags()##
        ##basecoatIncludes()##              <!-- loads CSS + JS + ui shim -->
    </cfoutput>
</head>
<body>
    ...
    <cfoutput>##basecoatFlashToasts()##</cfoutput>  <!-- renders flash() as toasts -->
</body>
```

That's it. Every helper is now in scope.

## The form-binding family — the killer feature

If the form references a Wheels model, **always prefer the `uiBound*` family** over the unbound primitives. The bound helpers auto-resolve value, name (`<obj>[<prop>]`), validation error, and humanized label from the controller-scoped model object.

| Input type | Unbound | Bound |
|---|---|---|
| Text / textarea / select / checkbox / switch / date / etc. | `uiField` | `uiBoundField` |
| Rich combobox (search, multi-select) | `uiSelect` | `uiBoundSelect` |
| Range slider | `uiSlider` | `uiBoundSlider` |
| Single boolean | `uiField(type=checkbox)` | `uiBoundCheckbox` |
| Multi-checkbox collection | `uiCheckboxGroup` | `uiBoundCheckboxGroup` |
| Single-choice radio | `uiRadioGroup` | `uiBoundRadioGroup` |
| Model-level error rollup | n/a | `uiErrorSummary(model)` |

Idiomatic Wheels-bound form:

```cfm
<cfoutput>
##uiErrorSummary(post)##
##startFormTag(action=isEdit ? "update" : "create", key=post.id ?: "")##
    ##uiBoundField(objectName="post", property="title", required=true)##
    ##uiBoundField(objectName="post", property="body", type="textarea", rows=10)##
    ##uiBoundField(objectName="post", property="status", type="select",
                   options="draft:Draft,published:Published,archived:Archived")##
    ##uiBoundCheckbox(objectName="post", property="featured", switch=true)##

    <div class="flex justify-end gap-2 pt-2">
        <a href="##urlFor(route='posts')##" class="btn-ghost" data-turbo-frame="_top">Cancel</a>
        ##uiButton(text=isEdit ? "Save" : "Publish", type="submit", icon="check")##
    </div>
##endFormTag()##
</cfoutput>
```

## The Hotwire / Turbo story

The package is Hotwire-aware but Hotwire-independent:

- **Form submissions inside `<turbo-frame>`** — frame-scope is automatic; the controller just `renderPartial("form", post=post, layout=false)` on validation failure and Turbo swaps the frame.
- **`turboStream(action=, target=)` + `turboStreamEnd()` + `turboStreamHeader()`** — compose Turbo Stream responses from CFML. `turboStreamHeader()` is **mandatory** for the `Content-Type: text/vnd.turbo-stream.html` header that Turbo 8 strictly requires.
- **`uiButton(turboConfirm=, turboMethod=)`** — emits `data-turbo-confirm` / `data-turbo-method` so destructive actions get a confirm and Turbo treats the link as the right verb.
- **`buttonTo(method="delete", inputClass="btn-destructive", data_turbo_confirm="...", data_turbo_stream="true")`** — Wheels' `buttonTo` converts `data_turbo_*` underscore-args to hyphen-attributes, which is how you wire CSRF + Turbo Stream + method-spoofing in one call.

## The dark mode story

```cfm
<head>
    <cfoutput>##basecoatThemeScript()##</cfoutput>  <!-- runs synchronously, before paint -->
    <cfoutput>##basecoatIncludes()##</cfoutput>
</head>
<body>
    <cfoutput>##uiThemeToggle()##</cfoutput>
</body>
```

`basecoatThemeScript()` reads `localStorage["basecoat:theme"]` (or falls back to `prefers-color-scheme: dark`) and applies `.dark` to `<html>` BEFORE first paint. `uiThemeToggle()` renders a sun/moon button that flips the class and persists. The toggle is delegated via `data-ui-theme-toggle` (handled by `wheels-basecoat-ui.js`) — no inline JS, CSP-safe.

## Convention-over-configuration helpers (v3.0)

The shortest path from "I have a model" to "rendered UI":

```cfm
<!-- Auto-build a form from the model's properties -->
##uiResourceForm(post)##

<!-- Auto-build a table from a Wheels query result -->
##uiResourceTable(posts, columns="title,status,publishedAt")##

<!-- Pagination UI from a paginated query -->
##uiPaginationFor(posts, baseUrl=urlFor(route="posts"))##
```

These read property metadata from the model (`enum()`, validations, types) and render the matching helpers. Use them for admin scaffolds and quick prototypes. For polished public-facing pages, hand-author with the bound helpers above.

## Helper categories at a glance

| Category | Helpers |
|---|---|
| **Setup** | `basecoatIncludes`, `basecoatThemeScript`, `basecoatFlashToasts` |
| **Buttons & display** | `uiButton`, `uiButtonGroup` (+sep + end), `uiBadge`, `uiAvatar`, `uiKbd`, `uiIcon`, `uiSpinner`, `uiSkeleton`, `uiProgress`, `uiSeparator` |
| **Feedback** | `uiAlert`, `uiCallout`, `uiToast`, `uiToaster`, `uiTooltip`, `uiEmptyState` |
| **Containers** | `uiCard` (+ header/content/footer + ends), `uiFieldset` (+end), `uiAccordion` (+ item + ends), `uiTimeline` (+ item + end) |
| **Overlays** | `uiDialog` (+footer + end), `uiPopover` (+ trigger + content + ends), `uiCommand` family + `uiCommandDialog` |
| **Forms (unbound)** | `uiField`, `uiSelect`, `uiSlider`, `uiCheckboxGroup`, `uiRadioGroup`, `uiTagInput`, `uiFileUpload`, `uiDatePicker`, `uiRating` |
| **Forms (Wheels-bound)** | `uiBoundField`, `uiBoundSelect`, `uiBoundSlider`, `uiBoundCheckbox`, `uiBoundCheckboxGroup`, `uiBoundRadioGroup`, `uiBoundFile`, `uiErrorSummary` |
| **Tables** | `uiTable` family + `uiResourceTable` |
| **Navigation** | `uiTabs`, `uiDropdown`, `uiBreadcrumb`, `uiPagination`, `uiPaginationFor`, `uiSidebar` family + `uiSidebarToggle`, `uiSteps` family |
| **Code display** | `uiCodeBlock` |
| **Theme** | `uiThemeToggle` |
| **Hotwire** | `turboStream`, `turboStreamEnd`, `turboStreamHeader` |
| **Wheels conventions** | `uiResourceForm`, `uiResourceTable`, `uiPaginationFor` |

For the formal signature of any helper, see `.ai/HELPERS.md`.

## Coding rules

These are non-negotiable when generating CFML for this codebase:

1. **CFML's null-coalescing operator is `?:` not `??`.** Lucee 7 silently fails to compile the whole component on `??` and every helper goes undefined. ([Pitfall #1](.ai/PITFALLS.md))

2. **Inside `<cfoutput>`, `##` is the escape for a literal `#`.** Three or five hashes are unbalanced and will throw "Syntax Error, Invalid Construct". When showing source code in a `<pre><code>` block, either close `</cfoutput>` around it or use exactly four hashes (`##...##`). ([Pitfall #2](.ai/PITFALLS.md))

3. **A `_form.cfm` partial that's wrapped in `<turbo-frame>` must keep that frame as the OUTERMOST element.** Don't add chrome (breadcrumbs, page header, outer card) inside the partial — those go in `new.cfm` / `edit.cfm` around the partial. On validation failure the controller returns the partial alone for Turbo to swap, and any chrome inside would render nested on the existing page. ([Pitfall #3](.ai/PITFALLS.md))

4. **Links inside a `<turbo-frame>` are scoped to that frame.** Cancel links and breadcrumb back-links inside a form frame must carry `data-turbo-frame="_top"` to break out, or Turbo will look for the same frame in the navigation target and surface "Content missing". ([Pitfall #4](.ai/PITFALLS.md))

5. **Wheels' `buttonTo` puts kwargs on the FORM by default.** To put a class on the inner `<button>`, use `inputClass="..."`. Hyphenated attributes like `data-turbo-confirm` must be written as `data_turbo_confirm` (underscore form) — Wheels converts to hyphens. ([Pitfall #5](.ai/PITFALLS.md))

6. **`turboStreamHeader()` is mandatory at the top of any partial that emits `<turbo-stream>` elements.** Turbo 8 won't process the stream without `Content-Type: text/vnd.turbo-stream.html`. ([Pitfall #6](.ai/PITFALLS.md))

7. **`Posts.cfc::config()` must call `super.config()` if it overrides config.** Otherwise `protectsFromForgery()` from the base controller never runs — non-GET endpoints still validate CSRF (Comments etc.), but Wheels' `startFormTag` won't emit the `authenticityToken` hidden field, and the form submission 500s. ([Pitfall #7](.ai/PITFALLS.md))

8. **Always prefer the bound helpers** (`uiBoundField`, `uiBoundSelect`, etc.) when there's a model object in scope. They handle name-namespacing, value pre-population, error rendering, and label humanization in one call.

9. **`uiCommand` and `uiCommandDialog` items use `<button role="menuitem">` (or `<a>` with `href`).** Use `data-keep-command-open` on items inside a command-dialog that should keep the modal open after a click (e.g. theme toggles).

10. **Argument validation throws on typos.** `uiButton(variant="primay")` raises `WheelsBasecoat.InvalidArgument` with the allowed list. If you see this error in a stack trace, fix the call site — don't catch and continue.

## Mini-glossary

- **basecoat-css** — the upstream CSS framework (https://basecoatui.com). Pinned to 0.3.11.
- **basecoat-js** — the upstream component-interaction scripts (tabs, dropdowns, popovers, etc.).
- **wheels-basecoat-ui.js** — our small CSP-safe shim that handles dialog/theme/sidebar/slider via `data-ui-*` delegation.
- **extras CSS** — `wheels-basecoat-extras.min.css`, our companion stylesheet for components basecoat-css doesn't ship CSS for.
- **showcase** — the `examples/showcase/` mountable controller. Run it in your Wheels app to get a live `/basecoat-showcase` URL with every helper rendered alongside its source. Doubles as a visual regression target.
- **PackageLoader** — Wheels' system for mixing package helpers into controller scope.
- **frame submission** — the Turbo pattern where a form inside `<turbo-frame id="X">` swaps just that frame on response.

## When in doubt

- Read `.ai/EXAMPLES.md`. It has a recipe for almost every common scenario.
- Read `.ai/PITFALLS.md`. The bugs that bite hardest are listed there with fixes.
- The package version is in `package.json::version`. Helpers added in a specific version are tagged in `index.cfm` with `vX.Y` pills.
- Run the test suite (`tests/Basecoat*Spec.cfc`) — it's the executable spec for every helper's expected output.
