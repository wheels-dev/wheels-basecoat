# Changelog

All notable changes to this package will be documented in this file.

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
