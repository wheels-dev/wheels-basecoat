# Architecture (long-form context)

For day-to-day reference, read `CLAUDE.md` and `.ai/HELPERS.md`. This file is the design rationale — why the package is shaped the way it is.

## Goal

A Wheels developer should never have to think about basecoat-css class names or basecoat-js component contracts. They write `#uiBoundField(objectName="post", property="title")#` and get a fully styled, model-bound, error-aware, Turbo-friendly form field.

The plugin sits between the application and basecoat:
- it bundles known-good versions of basecoat-css + basecoat-js so apps don't need a build pipeline
- it bridges Wheels' model object idioms (`obj.errorsOn`, `obj.hasErrors`, `obj.allErrors`) into the rendered HTML
- it provides CSP-safe alternatives where basecoat-css ships inline-script patterns
- it ships visual defaults (`wheels-basecoat-extras.min.css`) for components basecoat-css doesn't style

## File layout

```
wheels-basecoat/
├── Basecoat.cfc              # Single CFC; every public method is a helper.
├── package.json              # Wheels manifest. provides.mixins=controller.
├── box.json                  # CommandBox metadata + install hooks.
├── index.cfm                 # Static doc page rendered at /wheels/packages/wheels-basecoat.
├── CLAUDE.md                 # AI-tools-read-first. Master index of patterns + rules.
├── README.md                 # Human docs.
├── CHANGELOG.md
├── .ai/
│   ├── HELPERS.md            # Formal signature reference for every helper.
│   ├── EXAMPLES.md           # Scenario-driven recipes.
│   ├── SCAFFOLDS.md          # Copy-paste page templates.
│   ├── PATTERNS.md           # When-to-use decision trees.
│   ├── PITFALLS.md           # Footguns + fixes.
│   └── ARCHITECTURE.md       # This file.
├── assets/basecoat/
│   ├── basecoat.min.css                       # Bundled basecoat-css 0.3.11.
│   ├── wheels-basecoat-extras.min.css          # Defaults for components basecoat-css doesn't style.
│   └── js/
│       ├── all.min.js                          # All basecoat-js modules concatenated.
│       ├── basecoat.min.js                     # Component registration kernel.
│       ├── tabs / dropdown-menu / popover / select / command / sidebar / toast .min.js
│       └── wheels-basecoat-ui.min.js           # CSP-safe shim for dialog/theme/sidebar/slider.
├── examples/showcase/                          # Mountable live-render showcase
├── scripts/install.cfm                          # CommandBox post-install hook (publishes assets to public/)
└── tests/Basecoat*Spec.cfc                      # One spec per major version
```

## Coding conventions

- **CFScript**, no tag-based components. Every public method is a `public string function ...`.
- **Typed parameters with sensible defaults.** Signatures self-document.
- **`var local = {};`** at the top of any helper that uses local scope.
- **`savecontent variable="local.html" { writeOutput(...) }`** for multi-line HTML.
- **Always returns a string.** No helper writes to the response — that lets composition work cleanly and makes testing trivial.
- **Double quotes for HTML attributes.**
- **Unique IDs** via `replace(left(createUUID(), 8), "-", "", "all")` (wrapped in `$uiBuildId()`).

## Naming patterns

| Prefix | Meaning |
|---|---|
| `ui*` | Visible component helper. Returns HTML. |
| `ui*End` | Closing tag for a block component. |
| `uiBound*` | Wheels-bound variant. Auto-resolves model value/error/name. |
| `basecoat*` | Package-level infrastructure (`basecoatIncludes`, etc.). |
| `turbo*` | Turbo Stream helpers. |
| `$uiX` / `$X` | Internal helper. **Still PUBLIC** (PackageLoader only carries public methods) but `$` signals "don't call from app code". |

## The PackageLoader mixin gotcha

Wheels' `PackageLoader.$collectMixins` integrates only PUBLIC methods of the package CFC into the target controller scope. Private methods stay on the CFC and aren't visible from the mixed-in `variables` scope where helpers run when called from views.

Any internal helper called by a public mixed-in helper must itself be `public`. The `$` prefix is the convention for signaling internal-but-still-public:

```cfml
public string function uiButton(...) {
    $validateEnum(...);   // ← called from mixed-in scope, must be public
}

public void function $validateEnum(...) { /* implementation */ }
```

Past PRs that fixed this: #3 (`$uiBuildId` / `$uiLucideIcon`).

## Argument validation

Every enum-typed argument (`variant`, `size`, `type`, `action`, `side`, `orientation`, `status`) is validated via `$validateEnum`. Bad values throw `WheelsBasecoat.InvalidArgument` with the helper name, the bad value, and the allowed list:

```
WheelsBasecoat.InvalidArgument:
    uiButton() received an unsupported variant value: 'primay'.
    Allowed values are: primary,secondary,destructive,outline,ghost,link.
```

Goal: typos surface as errors at the call site, not as silent unstyled markup.

## Wheels integration

Three layers:

### Layer 1 — Form helpers
The `uiBound*` family reads from the controller-scoped model:
- `value` from `obj[property]` (with date coercion to ISO format)
- `errorMessage` from `obj.errorsOn(property)[1].message` if `obj.hasErrors(property)`
- `name` constructed as `<objectName>[<property>]`
- `label` humanized from the property name (`firstName` → `First name`)

For checkbox/switch types: a hidden `value="0"` companion input under the same name solves the "unchecked submits nothing" footgun.

### Layer 2 — Flash messages
`basecoatFlashToasts()` reads `flash()` and renders a toaster + a toast per entry. Standard keys (`success`, `error`, `warning`, `info`, `notice`) map to corresponding variants.

### Layer 3 — Resource conventions (v3.0)
`uiResourceForm(model)` and `uiResourceTable(query)` introspect Wheels models to scaffold full UIs. Read property metadata, `enum()` declarations (rendered as select fields), `validatesPresenceOf` (rendered as `required`).

For polished public-facing pages, hand-author with `uiBound*`. Use the resource family for admin scaffolds and prototypes.

## CSP safety

Inline event handlers (`onclick="..."`) require `unsafe-inline` in CSP. The plugin avoids them via `wheels-basecoat-ui.min.js` — a small delegated handler bundle that listens at `document` for clicks on elements carrying `data-ui-*` attributes:
- `data-ui-dialog-open` / `data-ui-dialog-close` (uiDialog)
- `data-ui-theme-toggle` (uiThemeToggle)
- `data-ui-sidebar-toggle` (uiSidebarToggle)
- `<input type="range">` `input` event (uiSlider live mirror)

The basecoat-js modules themselves attach via delegation too — they're CSP-clean.

## Hotwire / Turbo integration

Three primary patterns:

1. **Frame-scoped form swap on validation failure.** Wrap the form in `<turbo-frame id="post_form">`. On failure, controller does `renderPartial(partial="form", layout=false)`. Turbo finds and swaps the frame.

2. **Turbo Stream remove on delete.** Each row wrapped in `<article id="post_X">`. Delete button form has `data_turbo_stream="true"` so Turbo advertises the stream Accept header. Controller detects, renders `_postRemoved.cfm` emitting `<turbo-stream action="remove" target="post_X">`. Row vanishes; no reload.

3. **Turbo Stream append on create.** New comment form wrapped in `<turbo-frame id="new_comment">`. Comments controller success returns a partial emitting `<turbo-stream action="append" target="comments">` + rendered comment + fresh empty form replacing the frame.

The `turboStream(...)` / `turboStreamEnd()` / `turboStreamHeader()` helpers compose these responses.

## Versioning

| Version | Theme |
|---|---|
| 1.x | Initial helpers (single CFC, basic coverage) |
| 1.1 | Cards/alerts markup aligned with basecoat-css 0.3.x semantic structure |
| 2.0 | Bundled assets, uiBoundField, toasts, popover, dark mode, Turbo helpers, arg validation, CSP-safe dialog |
| 2.1 | Tabs/Dropdown/Sidebar reworked to ARIA roles + basecoat-js contracts |
| 2.2 | Extras CSS (breadcrumb, pagination), uiCommand family, uiSelect |
| 2.3 | uiSlider, uiSteps wizard, uiBoundSelect |
| 2.4 | Bound checkbox/multi-checkbox/radio, uiErrorSummary, uiRating |
| 3.0 | AI/dev experience (CLAUDE.md + .ai/ docs + showcase + install script), uiTagInput, uiAccordion, uiCallout, uiEmptyState, uiCodeBlock, uiTimeline, uiFileUpload, uiBoundFile, uiDatePicker, uiResourceForm, uiResourceTable, uiPaginationFor |

basecoat-css version is pinned in `package.json::basecoatCSSVersion`. When upstream ships a new minor version, run the bundled-asset refresh playbook: download new CSS+JS, run the test suite, update CLAUDE.md if markup contracts shifted, bump.

## Testing

Snapshot-style: every helper has tests asserting canonical output for canonical args. Split by version (`BasecoatSimpleSpec.cfc`, `BasecoatV*Spec.cfc`). Tests run inside a Wheels app context (extends `wheels.WheelsTest`).

The `index.cfm` doc page also serves as a visual regression target — every helper appears there with a version pill.

## Future considerations

- **Type definitions** — a `helpers.d.ts`-style document for IDE/AI parameter completion. `.ai/HELPERS.md` is a step toward this.
- **Component-level i18n.** Most strings are hard-coded English. A `basecoat:translations` configuration map would make localization easy.
- **Per-component configuration defaults.** `set("uiButton.defaults.variant", "outline")` for app-level overrides.
- **Animation primitives.** A `uiTransition(...)` block helper for orchestrated reveals.
