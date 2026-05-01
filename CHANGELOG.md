# Changelog

All notable changes to this package will be documented in this file.

## [3.0.0] — 2026-05-01

This release positions wheels-basecoat as the killer feature of Wheels 4.0 — every common UI pattern has a one-line helper, every form has a Wheels-bound variant, and every AI coding assistant can pick up the package and write idiomatic code on the first try without trial-and-error.

### Added — AI / dev experience

- **Comprehensive `CLAUDE.md`** rewrite — read order, package architecture, full helper category overview, the 14 coding rules every generated CFML must follow.
- **`.ai/HELPERS.md`** — formal signature reference for every public helper, alphabetical-ish by category.
- **`.ai/EXAMPLES.md`** — scenario-driven recipes: layout, posts index/new/edit/show, login/signup, settings, wizard, dashboard, ⌘K palette, Turbo Stream delete, resource scaffold.
- **`.ai/SCAFFOLDS.md`** — copy-paste page templates for index/show/new/edit/layout/base controller/resource controller/turbo-stream-remove partial.
- **`.ai/PATTERNS.md`** — when-to-use decision trees for every helper family.
- **`.ai/PITFALLS.md`** — 14 known footguns surfaced in real Wheels-tutorial use, each with symptom + cause + fix.
- **`.ai/ARCHITECTURE.md`** updated — design rationale, naming, the PackageLoader mixin gotcha, CSP safety, Hotwire integration patterns, version history.
- **`examples/showcase/`** — drop-in controller + view + route snippet that mounts a live `/basecoat-showcase` URL in the host app. Renders every helper with real demo data. Solves the "package's `index.cfm` runs in admin scope where helpers aren't mixed in" limitation.
- **`INSTALL.md`** + `box.json` `instructionsFile` pointer — three-step install guide, asset publishing, optional showcase mount, troubleshooting.

### Added — Layout / display helpers

- **`uiCallout(title, body, variant)`** — boxed inline note for body content. Variants: info, tip, warning, success. Lighter visual weight than `uiAlert` (which is for page-level notices).
- **`uiEmptyState(title, description, icon, actionText, actionHref, actionIcon)`** — centered placeholder for zero-data scenarios with optional CTA button.
- **`uiAccordion`** family (`uiAccordion`, `uiAccordionItem(title, open)`, `uiAccordionItemEnd`, `uiAccordionEnd`) — CSS-only via `<details>/<summary>`. Animated chevron rotation, hover state, semantic disclosure.
- **`uiTimeline`** family (`uiTimeline`, `uiTimelineItem(title, time, icon, description)`, `uiTimelineEnd`) — vertical timeline with marker icons + connecting line.
- **`uiCodeBlock(content, language, filename, showCopy, escape)`** — styled code display with optional title bar (filename + language) + copy-to-clipboard button. Auto-escapes HTML by default; pass `escape=false` for pre-highlighted markup.
- **`uiTagInput(name, value, suggestions, placeholder, label, maxTags, allowFree, multipleHidden)`** — multi-value chip entry with optional `<datalist>` autocomplete. Enter / comma adds a pill; Backspace removes the last; pill `×` button removes individual. Hidden input(s) kept in sync by `wheels-basecoat-ui.js`. Supports CSV or `name[]` hidden output.
- **`uiBoundTagInput(objectName, property, ...)`** — Wheels-bound variant that resolves array/JSON/CSV from the model.

### Added — File upload + date picker

- **`uiFileUpload(name, accept, multiple, dragDrop, label, description)`** — basecoat-styled file input with drag-and-drop zone (handled by `wheels-basecoat-ui.js`). File list mirror updates on selection. Clean fallback when JS is disabled.
- **`uiBoundFile(objectName, property, ...)`** — Wheels-bound variant; multi-upload variants get `name="<obj>[<prop>][]"`.
- **`uiDatePicker(name, value, label, min, max, required)`** — basecoat-styled `<input type="date">` with auto-coercion of Lucee-quoted datetime values to ISO `yyyy-mm-dd` so edit forms pre-populate cleanly.

### Added — Wheels resource conventions

- **`uiPaginationFor(query, baseUrl)`** — pagination UI for a Wheels paginated query result. Reads `currentpage` and `totalpages` columns directly. Returns `""` when there's nothing to paginate.
- **`uiResourceTable(query, columns, editRoute, deleteRoute, showRoute, keyColumn)`** — auto-builds a basecoat table from a Wheels query result. Picks columns, formats cells (booleans → ✓/—, dates → "Mmm D, YYYY"), wraps the first cell in a show-route link if provided, renders Edit + Delete row-action buttons when routes are configured.
- **`uiResourceForm(model, submitRoute, submitMethod, excludeFields)`** — auto-builds a Wheels-bound form from a model's properties. Reads `properties()`, `enum()` declarations, and column types to pick input types per property. For polished public-facing pages, hand-author with `uiBound*`. For admin scaffolds and prototypes, this is the fastest path to a rendered form.
- **Helper utilities exposed:** `$formatCell`, `$inferInputType`, `$optionsFromEnum` (public for PackageLoader reachability — see `.ai/PITFALLS.md` #11).

### Added — Extras CSS + UI shim updates

- **`wheels-basecoat-extras.min.css`** extended with `.ui-callout` (4 variants), `.ui-empty-state`, `.ui-accordion` + chevron rotation, `.ui-timeline`, `.ui-code-block` (header + copy button), `.ui-tag-input` + `.ui-tag-pill`, `.ui-file-upload` + drag-and-drop styling.
- **`wheels-basecoat-ui.js`** extended with:
  - `data-ui-tag-remove` click handler (removes pills, keeps hidden inputs in sync).
  - `data-ui-code-copy` click handler (`navigator.clipboard.writeText` on the `<code>` content; visual confirmation via `data-copied` attribute for 1.2s).
  - `data-ui-file-upload` `dragover` / `dragleave` / `drop` handlers (assigns dropped files to the underlying input + dispatches `change`).
  - File `change` handler (mirrors the file list inside the upload zone).
  - Tag input keyboard handlers (Enter/comma adds, Backspace removes from empty entry).
- **Four new icons:** `copy`, `upload`, `calendar` (plus `star` from v2.4).

### Changed

- `box.json` repository URL fixed to point at `wheels-dev/wheels-basecoat` (was pointing at the old monorepo URL); version aligned with `package.json`; expanded keywords (hotwire, turbo, dark-mode); `instructionsFile: INSTALL.md`.

## [2.4.0-rc.1] — 2026-05-01

### Added
- **`uiBoundCheckbox(objectName, property, label, switch, description, ...)`** — single bound checkbox or switch. Solves the standard "unchecked checkbox submits nothing" footgun by emitting a hidden `value="0"` companion input under the same name BEFORE the checkbox, so `params.<obj>.<prop>` is always defined as `0` or `1`. Pass `switch=true` to render as a basecoat `.switch` instead.
- **`uiCheckboxGroup(name, options, value, legend, description, inline)`** — multi-checkbox collection emitting `name="<name>[]"` so Wheels arrays the values. Same `options="value:Label[:disabled],..."` shape as `uiSelect` / `uiRadioGroup`. Tolerates a real CFML array, a JSON-array string, or a CSV string for `value`.
- **`uiBoundCheckboxGroup(objectName, property, options, ...)`** — Wheels-bound variant. Auto-resolves the array/JSON/CSV value from `obj[property]`, humanizes the property into the legend.
- **`uiRadioGroup(name, options, value, legend, description, inline)`** — radio-group container with `role="radiogroup"`. Same options syntax as the checkbox group.
- **`uiBoundRadioGroup(objectName, property, options, ...)`** — Wheels-bound variant.
- **`uiErrorSummary(model, title, description)`** — drop-in replacement for Wheels' `errorMessagesFor()`. Renders the model's full validation error list as a basecoat destructive alert with a bullet list of field-prefixed messages from `model.allErrors()`. Returns "" when no errors so it's safe to call unconditionally at the top of a form. Auto-pluralizes the title (`"1 error"` vs `"3 errors"`).
- **`uiRating(value, max, name, ariaLabel, class)`** — 1-to-N star rating. Read-only display by default; pass `name=` to render as an interactive radio group (CSS-only highlight via the bundled extras stylesheet — no JS required). Renders highest-first internally so the CSS sibling combinator can light earlier stars on hover/check.
- **One new icon**: `star`.
- **`wheels-basecoat-extras.min.css` extended** with `.ui-rating` rules (display + interactive variants) plus a `.radio` rule (basecoat-css 0.3.x ships `.checkbox` and `.switch` but no radio styling — the new helpers add a sized circle that matches the checkbox treatment).

### Form-binding round-trip is now complete
With v2.4, every common form input type has a Wheels-bound helper that reads the current value, emits the canonical `<obj>[<prop>]` name, surfaces validation errors, and humanizes the label:

| Input | Helper |
|---|---|
| Text / textarea / select / date / etc. | `uiBoundField` |
| Rich combobox (search, multi-select) | `uiBoundSelect` |
| Range slider | `uiBoundSlider` |
| Single boolean | `uiBoundCheckbox` (with hidden companion for unchecked submissions) |
| Multi-checkbox collection | `uiBoundCheckboxGroup` |
| Single-choice radio | `uiBoundRadioGroup` |

Plus `uiErrorSummary(model)` to render model-level validation results without manually iterating `errorMessagesFor()`.

## [2.3.0-rc.1] — 2026-05-01

### Added
- **`uiSlider(name, value, min, max, step, label, showValue, disabled, id, class)`** — basecoat-styled `<input type="range">` wrapper. Computes the `--slider-value` CSS variable percentage server-side from the current value so the filled portion of the track renders correctly on first paint (no JS required for the initial render). Optional `showValue=true` renders an `<output data-ui-slider-output>` mirror that the bundled `wheels-basecoat-ui.js` keeps in sync as the user drags. Emits `aria-valuemin/max/now`. Pairs cleanly with `uiBoundSlider`.
- **`uiBoundSlider(objectName, property, ...)`** — Wheels-bound variant that auto-resolves the value from `obj[property]`, emits `name="<objectName>[<property>]"`, and humanizes the property name into the default label. Mirrors `uiBoundField`'s ergonomics for slider use.
- **`uiSelect`'s Wheels-bound sibling: `uiBoundSelect(objectName, property, options, ...)`** — same options syntax + tolerates a real array on the model for multi-select (auto-serializes to JSON for the hidden input). Throws `WheelsBasecoat.ObjectNotFound` if the named object isn't in scope.
- **Steps / wizard progress indicator**: `uiSteps(ariaLabel, class)` opens a labeled `<nav><ol class="ui-steps">`; `uiStep(text, status="complete|current|upcoming", number, description, href)` renders each `<li data-status="...">`; `uiStepsEnd()` closes. Auto-numbers steps via a request-scoped counter when no `number` is passed. Complete steps render a check icon in the marker; current steps emit `aria-current="step"`. Optional `href` wraps complete/upcoming markers in a link (current never links). Visual defaults shipped in `wheels-basecoat-extras.min.css` — numbered circles connected by a colored progress line, mobile-stacked layout below 640px.
- **`wheels-basecoat-extras.min.css` extended** with `.ui-steps` rules to match.
- **`wheels-basecoat-ui.js` extended** to keep slider `--slider-value` in sync as the user drags + mirror the live value into any matching `<output data-ui-slider-output>`. CSP-safe; no inline event handlers needed.

## [2.2.0-rc.1] — 2026-05-01

### Added
- **Bundled `wheels-basecoat-extras.min.css`** — visual defaults for the components that basecoat-css 0.3.x doesn't ship CSS for (`.breadcrumb`, `.pagination`). Loaded automatically by `basecoatIncludes()` (toggle via the new `extrasCSS` arg, default `true`). Closes the gap that previously left `uiBreadcrumb` and `uiPagination` rendering unstyled — their helpers were correct, the upstream stylesheet just had nothing for them.
- **Command palette family** — `uiCommand` / `uiCommandInput` / `uiCommandList` / `uiCommandGroup` / `uiCommandItem` / `uiCommandSeparator` / `uiCommandEmpty` / `uiCommandEnd` plus the modal wrapper `uiCommandDialog` / `uiCommandDialogEnd`. Drives basecoat-js's `command.js` for the live search filter (matches by `data-filter` / textContent / `data-keywords`), arrow-key + Home/End + Enter navigation, and click-to-close behavior when nested inside a `<dialog class="command-dialog">`. Items support `keywords`, `icon`, `kbd`, `force`, `keepOpen`, `disabled`, and either `<a href>` or `<button>` rendering.
- **`uiSelect`** — basecoat-css 0.3.x's rich combobox component (popover, optional search, multi-select). Distinct from `uiField(type="select")` which renders a plain native `<select>`. Single-call helper that takes the same `options="value:Label[:disabled],..."` shape as `uiField`, pre-renders the trigger label so there's no FOUC before `select.js` initializes, and emits the four parts the JS queries (trigger button, popover, listbox, hidden input). Multi-select serializes the value as a JSON array in the hidden input.
- **`basecoatIncludes(extrasCSS=true)`** — the new opt-in that loads the extras CSS. New args: `extrasCssPath`, `extrasCSS`. The default extras-css path mirrors the recommended publish location.

## [2.1.0-rc.1] — 2026-05-01

### Changed (BREAKING)
- **`uiTabs` family rewritten** to emit the ARIA-role markup that basecoat-css 0.3.x styles and that basecoat-js's `tabs.js` drives. Previously emitted `<button class="tabs-trigger" data-value="...">` and `<div class="tabs-content" data-value="...">` — neither of which had matching CSS in 0.3.x, leaving the component visually unstyled and JS-unaware. New output uses `[role=tablist]` + `[role=tab]` (with `aria-controls`, `aria-selected`, `tabindex`) + `[role=tabpanel]` (with `aria-labelledby` + `hidden`). `uiTabs(defaultTab=)` is stashed in the request scope so child triggers and panels can auto-pair their IDs and active state. Helper API (function names, parameters) is unchanged.
- **`uiDropdown` family rewritten** from `<details>/<summary>` to the popover-driven `.dropdown-menu` markup that basecoat-css 0.3.x styles and `dropdown-menu.js` drives. Previously emitted `<details><summary>...</summary><ul>...</ul></details>` which had no matching CSS in 0.3.x. New output: `<div class="dropdown-menu"><button aria-expanded aria-haspopup="menu">...</button><div data-popover aria-hidden="true"><div role="menu">...items...</div></div></div>`. Items now carry `role="menuitem"`, separators emit `<hr role="separator">`, and `uiDropdownItem` renders an `<a>` with `href` or a `<button>` without — both keyboard-navigable. New `disabled` arg toggles `aria-disabled`.
- **`uiSidebar` family rewritten** to the semantic-element structure that basecoat-css 0.3.x styles and `sidebar.js` drives. Old API was `uiSidebar()` / `uiSidebarSection(title=)` / `uiSidebarItem()`. New API: `uiSidebar(side=, initialOpen=, initialMobileOpen=, breakpoint=, id=)` opens an `<aside class="sidebar" data-side="..." ...><nav>`, then `uiSidebarHeader/End`, `uiSidebarBody/End` (the scrollable `<section>`), `uiSidebarGroup(title=)/End` (the `<div role="group">` with optional `<h3>`), `uiSidebarItem(text=, href=, icon=, active=)` (now an `<a>` with `aria-current="page"` when active), `uiSidebarSeparator()`, and `uiSidebarFooter/End`. Apps using `uiSidebarSection`/`uiSidebarSectionEnd` must rename to `uiSidebarBody`/`uiSidebarBodyEnd` (plus `uiSidebarGroup` for the heading-bearing inner block).

### Added
- **`uiSidebarToggle(action=, sidebarId=)`** — CSP-safe toggle button that dispatches the `basecoat:sidebar` CustomEvent (open / close / toggle) which `sidebar.js` listens for. Handled via `data-ui-sidebar-toggle` data-attribute through the bundled `wheels-basecoat-ui.js` shim.
- **Four new icons** in the Lucide map: `menu`, `home`, `file-text` (in addition to the v2.0 additions).
- **`tests/BasecoatV21Spec.cfc`** — comprehensive snapshot-style coverage for the reworked Tabs / Dropdown / Sidebar markup and the new sidebar toggle.

### Documentation
- `index.cfm` rewritten as a structured documentation page (helper tables grouped by category, with v2 / v2.1 pills marking new helpers). The previous attempt at a live showcase doesn't work in the Wheels admin view scope (helpers aren't mixed in there); the README hosts the rendered examples instead.

## [2.0.0-rc.1] — 2026-05-01

### Added
- **Bundled assets.** The package now ships `assets/basecoat/basecoat.min.css` and the basecoat-js component scripts (`all.min.js`, plus per-component modules for tabs/dropdown/popover/select/command/sidebar/toast). Pinned to basecoat-css 0.3.11. Recommended install: `cp -r vendor/wheels-basecoat/assets/basecoat public/assets/basecoat`.
- **`uiBoundField(objectName, property)`** — model-bound form field that mirrors Wheels' built-in `textField` ergonomics. Auto-resolves the input value from `obj[property]`, the error message from `obj.errorsOn(property)[1].message`, the input `name` (`<objectName>[<property>]`), and the `<label>` text (humanized from the property name — `firstName` → `First name`). Includes datetime coercion to ISO format for `type="date"` / `datetime-local` / `time`. Throws `WheelsBasecoat.ObjectNotFound` if the named object isn't in scope.
- **`uiToast` + `uiToaster` + `basecoatFlashToasts`** — toast notifications driven by basecoat-js's `toast.js`. `basecoatFlashToasts()` is a one-call drop-in that reads Wheels' `flash()` map and renders a toaster + a toast per entry, mapping the standard keys (`success`, `error`, `warning`, `info`, `notice`) to the matching variant.
- **`uiPopover` family** (`uiPopover` / `uiPopoverTrigger` / `uiPopoverContent` / `uiPopoverContentEnd` / `uiPopoverEnd`) — driven by basecoat-js's `popover.js`. Toggles `aria-expanded` on the trigger and `aria-hidden` on the content, dismisses on outside click + Escape.
- **`uiAvatar`** — image avatar with text-initial fallback, configurable size.
- **`uiKbd`** — keyboard key indicator for menu labels and command palettes.
- **`uiButtonGroup` family** (`uiButtonGroup` / `uiButtonGroupSeparator` / `uiButtonGroupEnd`) — joined-border button cluster, horizontal or vertical.
- **`uiFieldset` / `uiFieldsetEnd`** — `<fieldset>` wrapper with optional legend + description, styled by basecoat-css's `.fieldset` rule.
- **`uiThemeToggle` + `basecoatThemeScript`** — light/dark theme toggle with localStorage persistence and `prefers-color-scheme` fallback. Pre-paint script applies the saved theme synchronously to avoid the FOUC.
- **`turboStream` / `turboStreamEnd` / `turboStreamHeader`** — compose Turbo Stream responses from CFML. `turboStream(action="remove", target="x")` returns a self-closing element; content actions (`append`, `prepend`, `replace`, etc.) open `<turbo-stream><template>` and pair with `turboStreamEnd()`. `turboStreamHeader()` sets `Content-Type: text/vnd.turbo-stream.html`, which Turbo 8 strictly requires for stream processing.
- **Argument validation** via the new internal `$validateEnum` — typos in `variant` / `size` / `type` / `action` / `orientation` throw `WheelsBasecoat.InvalidArgument` naming the helper, the bad value, and the allowed list. Wired into `uiButton`, `uiBadge`, `uiAlert`, `uiField`, `uiToast`, `uiButtonGroup`, `uiThemeToggle`, and `turboStream`.
- **Live `index.cfm` showcase** — the Wheels package debug panel page now renders every helper with its source. Doubles as a visual regression target.
- **Comprehensive `BasecoatV2Spec.cfc`** — snapshot-style tests for every new helper plus the validation throw cases.
- **Eight new icons** in the Lucide map: `sun`, `moon`, `log-out`, `log-in`, `user`, `settings` (plus the existing 16).

### Changed (BREAKING)
- `init()` now reads its `version` field from `package.json`, replacing the hard-coded `"3.0"` literal that drifted from the manifest. Callers reading `pluginObj.version` will see `2.0.0-rc.1` from this release on.
- `basecoatIncludes()` argument list reorganized:
  - Renamed `basecoatCSSPath` → `cssPath`.
  - Added `jsPath`, `uiJsPath`, `basecoatJS` (default `true`), `uiJS` (default `true`).
  - **`alpine` default flipped from `true` to `false`.** Alpine.js is no longer required by any built-in helper. Apps that depend on Alpine should pass `alpine=true` explicitly.
  - Default `cssPath` changed to `/assets/basecoat/basecoat.min.css` (the new bundled-asset publish location).
- `uiDialog` and `uiDialogEnd` no longer emit inline `onclick` attributes. Open/close is now delegated via `data-ui-dialog-open` / `data-ui-dialog-close` attributes handled by `wheels-basecoat-ui.js` (loaded by default by `basecoatIncludes()`). Apps with strict CSP can now use the dialog without an `unsafe-inline` allowance. **If you've disabled `uiJS`** in `basecoatIncludes()`, dialogs will no longer open without your own delegated handler.

### Fixed
- `init() this.version` no longer reports `"3.0"` while `package.json` says something else. The two are now the same string.

## [1.1.0] — 2026-05-01

### Changed (BREAKING)
- `uiCardHeader`, `uiCardContent`, `uiCardFooter` (and matching `*End`) now emit semantic `<header>` / `<section>` / `<footer>` elements instead of `<div class="card-header">` / `<div class="card-content">` / `<div class="card-footer">`. `uiCardHeader` also emits `<h2>` for the title (was `<h3>`). Reason: basecoat-css 0.3.x dropped the older class hooks and now styles cards exclusively via the semantic-element selectors `.card > header`, `.card > section`, `.card > footer`, with the title typography targeted at `.card > header h2`. Apps using the unmodified helpers under basecoat-css 0.3.x rendered cards with no internal padding, no header/title typography, and no flex footer — the visible bug surfaced as edge-to-edge text inside an outlined box. Helper API (function names, parameters) is unchanged. Apps that wrote custom CSS targeting `.card-header` / `.card-content` / `.card-footer` will need to re-target the semantic selectors. (Discovered during a Wheels Tutorial fresh-VM bake against basecoat-css 0.3.11.)
- `uiAlert` no longer wraps the title and description in an extra `<div>` and now renders the description inside a `<section>` rather than a nested `<div>`. The new output is `<div class="alert"><svg/><h5>Title</h5><section><p>Description</p></section></div>`. Reason: basecoat-css 0.3.x targets `.alert > h5` (or h2-h6 / strong / `[data-title]`) and `.alert > section` as direct children of the alert; the previous wrapper-div nesting prevented those rules from matching, which left alert titles unstyled and descriptions un-padded. Helper API is unchanged.

### Documentation
- Updated the Cards and Alerts markup samples in `CLAUDE.md` to reflect the basecoat-css 0.3.x semantic-element structure. Future helpers extending these patterns should follow the new shape.

## [1.0.5] — 2026-04-30

### Changed
- `uiButton` now always emits the variant suffix in its CSS class, including the default `primary` variant. A bare `uiButton(text="Save")` previously rendered `<button class="btn">`; it now renders `<button class="btn-primary">`. Sized primary buttons follow the same rule (`size="sm"` → `class="btn-sm-primary"` instead of `class="btn-sm"`). Rationale: the rendered HTML now self-documents the variant — inspecting `class="btn"` in DevTools could previously mean either "explicit primary" or "the author forgot to set the variant," and the two were indistinguishable. basecoat-css ships matching selectors for every size×variant combination (`.btn-primary`, `.btn-sm-primary`, `.btn-lg-primary`, `.btn-icon-primary`, etc.), so visual rendering is unchanged. Discovered during a Wheels Tutorial fresh-VM bake — the chapter-8 checkpoint asserted `class="btn btn-primary"` against rendered output, and the silent-skip behavior made the assertion impossible to satisfy. Wheels Tutorial Finding #5.

## [1.0.4] — 2026-04-30

### Fixed
- Drop `mixin="controller"` from the `Basecoat.cfc` component declaration. The 1.0.3 changelog claimed this attribute was a no-op — that was wrong. Lucee 7.0.0.395 enforces native trait composition on `component mixin="..."` and tries to resolve `controller` as a CFML component path; on a clean install with empty Lucee class caches, that resolution fails and the whole component bombs out with the misleading error `invalid component definition, can't find component [vendor.wheels-basecoat.Basecoat]`. Net effect on a fresh `wheels packages add wheels-basecoat`: `application.wheels.failedPackages` carries the package, every helper call (`uiCard`, `uiField`, `uiButton`, etc.) blows up with `No matching function [...] found`, and the bonus chapter is unreachable. Cached-class reproductions appeared to load the package fine, which masked the bug during 1.0.2/1.0.3 release testing. The authoritative source for the mixin target is the `provides.mixins: "controller"` field in `package.json`, which `PackageLoader` already reads — the component-level attribute is genuinely redundant and now also actively breaks Lucee 7. (Verified end-to-end on a fresh VM with `wheels stop && rm -rf vendor/wheels-basecoat ~/.wheels/servers/<app>/lucee-server/context/cfclasses/* && wheels packages add wheels-basecoat && wheels start` — without this fix, `application.wheels.failedPackages` is non-empty; with it, `application.wheels.packages.wheels-basecoat` is populated and all 57 helpers resolve.)

### Retraction
- The 1.0.3 changelog included a "Note on the 1.0.2 changelog" stating that the `mixin="controller"` attribute compiles fine on Lucee 7.0.0.395 and is a no-op. That note was based on testing against a Lucee class cache that already had the package compiled — the actual fresh-install behavior is the failure described above. The 1.0.2 changelog's original diagnosis (Lucee 7 rejecting the `mixin` attribute) was directionally correct; what was wrong was its claim that 1.0.2 "fixed" it by removing only `view` from the comma list. Removing `controller` was also required, and is what 1.0.4 does.

## [1.0.3] — 2026-04-29

### Fixed
- Switch `$uiBuildId` and `$uiLucideIcon` from `private` → `public` on `Basecoat.cfc`. Wheels' `PackageLoader.$collectMixins` integrates only PUBLIC methods of the package CFC into the target scope (controllers in our case), so when public sibling helpers like `uiField`, `uiInput`, `uiCheckbox`, `uiButton(icon=...)`, `uiAlert`, and `uiPagination` invoked the `$`-prefixed helpers from the mixed-in scope they blew up at runtime with `No matching function [$UIBUILDID] found` (and the symmetrical icon variant). Hitting *any* page that rendered a form via `uiField` therefore 500'd on a fresh install. The leading `$` keeps signalling "internal — don't call from app code"; the access-modifier change just lets `PackageLoader` carry the helpers across the mixin boundary alongside the public callers that depend on them. (Discovered during a Wheels Tutorial fresh-VM bake; see Wheels Tutorial Finding #14.)

### Note on the 1.0.2 changelog
The 1.0.2 changelog asserted that Lucee 7 was rejecting the `mixin="controller"` component-level attribute outright, blocking compilation. That diagnosis was incorrect — verified post-release on Lucee 7.0.0.395, the package compiles fine and `PackageLoader` loads it successfully with the attribute in place. The actual blocker preventing helper rendering was the private-helper visibility issue fixed in 1.0.3 above. The `mixin="controller"` attribute on the component declaration is a no-op (the authoritative source for mixin targets is `package.json`'s `provides.mixins` field), and was already simplified to just `"controller"` in 1.0.2. No further changes to the attribute are required.

## [1.0.2] — 2026-04-29

### Fixed
- Drop `view` from the component-level `mixin` attribute on `Basecoat.cfc`. Lucee 7 enforces native trait composition on `component mixin="..."` and tries to load each comma-separated value as a CFML component path; there is no `view.cfc` on the path, so the whole component failed to compile with a misleading `can't find component [vendor.wheels-basecoat.Basecoat]` error. Net effect on Lucee 7: every `wheels packages add wheels-basecoat` install resulted in a successful extract but no helper activation. Helpers like `#uiButton(...)#`, `#uiCard(...)#`, `#uiField(...)#` all returned `function not found`. After this fix the package activates cleanly. The `package.json`'s `provides.mixins: "controller"` field remains the actual source of truth — the component-level attribute was a legacy convention obsolete on Lucee 7. Lucee 5/6 don't enforce native mixin composition the same way, which is why this went undetected until Wheels 4.0 made Lucee 7 the default. (See [#2](https://github.com/wheels-dev/wheels-basecoat/pull/2).)

## [1.0.1] — 2026-04-24

### Added
- Patch release. (Original entry omitted from the changelog at release time.)

## [1.0.0] — 2026-04-23

### Added
- Initial standalone release, extracted from the Wheels monorepo at `packages/basecoat`.
- Git history preserved from the monorepo's package directory.
- Published to the `wheels-dev/wheels-packages` registry for installation via `wheels packages install` (coming in Wheels 4.1).
