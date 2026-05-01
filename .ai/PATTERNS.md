# Patterns

Decision trees for "which helper do I use?" Each section is a single question with a one-line answer.

## Form fields

**Is there a Wheels model object exposed to the view?**
- Yes → `uiBoundField` (or another `uiBound*` helper for richer types).
- No  → `uiField` (or `uiSelect` / `uiSlider` / `uiCheckboxGroup` / `uiRadioGroup`).

**Single text input?**
- Bound → `uiBoundField(objectName="post", property="title")`.
- Unbound → `uiField(label="Email", name="email", type="email")`.

**Multi-line text?**
- `uiBoundField(... type="textarea", rows=10)` or `uiField(... type="textarea")`.

**Single-choice from a small fixed list?**
- Native `<select>` is fine → `uiBoundField(... type="select", options="a:Alpha,b:Beta")`.
- Want a popover-driven combobox with search → `uiBoundSelect`.

**Single-choice with always-visible options?**
- `uiBoundRadioGroup(objectName="post", property="status", options="...")`.

**Multi-choice from a small fixed list?**
- `uiBoundCheckboxGroup(objectName="post", property="tags", options="...")`.

**Multi-choice with search / auto-complete?**
- `uiBoundSelect(objectName=, property=, options=, multiselect=true, search=true)`.
- For free-form chip entry → `uiTagInput` / `uiBoundTagInput`.

**Single boolean (on/off, agree to terms, etc.)?**
- `uiBoundCheckbox(objectName="user", property="dark_mode", switch=true)`.
- The `switch=true` variant renders as a basecoat `.switch`; default is a checkbox.

**Date / time?**
- Native pickers are fine for most cases → `uiBoundField(... type="date")` (also `datetime-local`, `time`).
- For a richer popover calendar → `uiDatePicker`.

**Numeric range slider?**
- `uiBoundSlider(objectName=, property=, min=0, max=100, step=1)`.

**File upload?**
- Single → `uiBoundFile(objectName="post", property="cover")`.
- Multiple → `uiBoundFile(... multiple=true)`.
- Drag-and-drop zone → `uiFileUpload(... dragDrop=true)`.

**Star rating?**
- Read-only display → `uiRating(value=4)`.
- Form input → `uiRating(value=4, name="post[rating]")`.

## Feedback / notification

**Inline notice for the current page?**
- `uiAlert(title=, description=, variant="default|destructive")`.

**Inline note / tip / warning callout in body content?**
- `uiCallout(variant="info|tip|warning|success", title=, body=)`.

**Transient notification (auto-dismissing)?**
- Server-rendered after a redirect → `basecoatFlashToasts()` in the layout (renders Wheels' `flash()` map).
- Server-rendered for SSR cases → `uiToast(title=, description=, variant=)` inside a `uiToaster()`.
- Client-driven → dispatch a `basecoat:toast` CustomEvent on `document`.

**Validation errors at the top of a form?**
- Model-level rollup → `uiErrorSummary(model)`.
- Per-field error → already handled by `uiBoundField` / `uiBoundSelect` / etc.

**Empty state (zero data placeholder)?**
- `uiEmptyState(title="No posts yet", description="...", icon="info", action=uiButton(...))`.

**Tooltip on hover?**
- `uiTooltip(tip="text")` ... `uiTooltipEnd()` around the trigger element.

## Containers

**Page header + content + actions?**
- `uiCard()` + `uiCardHeader(title=, description=)` + `uiCardContent()` + `uiCardFooter()` + ends.

**Group of related form fields?**
- `uiFieldset(legend=, description=)` + ends.

**Collapsible sections?**
- `uiAccordion()` + `uiAccordionItem(title=, open=false)` ... `uiAccordionItemEnd()` per section + `uiAccordionEnd()`.

**Vertical timeline of events?**
- `uiTimeline()` + `uiTimelineItem(title=, time=, icon=, description=)` per entry + `uiTimelineEnd()`.

## Overlays

**Confirmation modal for destructive actions?**
- Inline `data-turbo-confirm` on the destructive button (native browser confirm).
- Rich modal → `uiDialog(title=, triggerText=, triggerClass=)` + body + `uiDialogFooter()` + buttons + `uiDialogEnd()`.

**Hover-triggered popover with rich content?**
- `uiPopover()` + `uiPopoverTrigger(text=)` + `uiPopoverContent()` + `uiPopoverEnd()`.

**Command / quick-search palette (⌘K)?**
- Inline → `uiCommand()` + `uiCommandInput()` + `uiCommandList()` + groups + items + ends.
- Modal → wrap the inline command in `uiCommandDialog(triggerText=)` ... `uiCommandDialogEnd()`.

## Lists / tables

**Display tabular data?**
- Quick scaffold from a Wheels query → `uiResourceTable(query, columns="title,status")`.
- Hand-authored → `uiTable()` + headers + rows + cells + ends.

**Pagination UI?**
- For a Wheels paginated `findAll(page=, perPage=)` query → `uiPaginationFor(query, baseUrl=)`.
- Manual → `uiPagination(currentPage=, totalPages=, baseUrl=)`.

**Card list (e.g. blog posts)?**
- Hand-author each as `uiCard()` inside a `<div class="grid gap-4">`. The blog tutorial is the canonical example.

## Navigation

**Top-of-page breadcrumb?**
- `uiBreadcrumb()` + items + separators + end. Trailing item (no `href`) becomes the current page.

**Tabbed sections?**
- `uiTabs(defaultTab=)` + `uiTabList()` + `uiTabTrigger()`s + `uiTabListEnd()` + `uiTabContent()`s + `uiTabsEnd()`.

**Action-menu (kebab / triple-dot)?**
- `uiDropdown(text="Actions")` + `uiDropdownItem`s + `uiDropdownEnd`. Use icon-only `uiButton(icon="ellipsis")` for the trigger if you'd rather, but the default `text="..."` works.

**App-level sidebar?**
- `uiSidebar()` + header + body + groups (with optional title) + items + footer + end. Pair with `uiSidebarToggle()` in your topbar for mobile collapse.

**Multi-step / wizard progress?**
- `uiSteps()` + per-step `uiStep(text=, status="complete|current|upcoming")` + `uiStepsEnd()`.

## Buttons

**Primary action?**
- `uiButton(text="Save", icon="check")` (primary is the default variant).

**Destructive action?**
- `uiButton(text="Delete", variant="destructive", icon="trash", turboConfirm="Are you sure?")`.

**Cancel / secondary?**
- Plain link via `<a class="btn-ghost" data-turbo-frame="_top">Cancel</a>` (the `data-turbo-frame="_top"` is required if it's inside a `<turbo-frame>`).

**Icon-only?**
- `uiButton(icon="trash", ariaLabel="Delete", variant="destructive", size="sm")` — the helper auto-detects icon-only when `text` is empty.

**Several related buttons (segmented)?**
- `uiButtonGroup()` + buttons + `uiButtonGroupEnd()`.

## Hotwire / Turbo

**Form whose validation errors should swap in-place?**
- Wrap the form in `<turbo-frame id="X">`, controller does `renderPartial(partial="form", layout=false)` on failure. (Don't put chrome inside the partial — see PITFALLS #3.)

**Delete that should remove a row from a list without a page reload?**
- Wrap each row in a frame `<article id="post_X">`. Controller's delete action emits a `<turbo-stream action="remove" target="post_X">` partial when the request advertises stream Accept. Form needs `data_turbo_stream="true"` to advertise.

**New comment that should append to a list without a page reload?**
- Comments controller success path: `turboStreamHeader()` + `turboStream(action="append", target="comments")` + content + `turboStreamEnd()`.

**Cancel link inside a form frame that should navigate the whole page?**
- `<a href="..." data-turbo-frame="_top">Cancel</a>`.

## Theme

**Dark mode toggle?**
- Add `basecoatThemeScript()` in `<head>` BEFORE `basecoatIncludes()`.
- Drop `uiThemeToggle()` somewhere in the layout (typically the topbar).
- The class flips on `<html>`, persists to `localStorage["basecoat:theme"]`, respects `prefers-color-scheme` on first visit.

## Authoring conventions

**Naming:**
- `uiX` — visible component helper (returns a string of HTML).
- `uiXEnd` — closer for a block component.
- `uiBoundX` — Wheels-bound variant.
- `basecoatX` — package-level infrastructure (includes, theme, flash).
- `turboX` — Turbo Stream helpers.
- `$xyz` — internal-only helper (still PUBLIC because of the PackageLoader mixin rule, just signaled as "don't call from app code").

**Argument order:** required positional first, then optional named with sensible defaults. Always typed.

**Output:** always returns a string. Helpers don't `writeOutput` directly — that lets composition work cleanly.

**Validation:** every enum-typed argument (variant, size, type, action, side, orientation) is validated via `$validateEnum` and throws `WheelsBasecoat.InvalidArgument` with the allowed list on a bad value.

**ARIA:** every interactive helper emits the matching ARIA attributes that basecoat-js expects (`aria-expanded`, `aria-hidden`, `aria-selected`, `role=...`). Don't strip these.

**CSP:** no inline event handlers. Dialog open/close, theme toggle, sidebar toggle, slider mirror — all delegated via `data-ui-*` attributes handled by `wheels-basecoat-ui.js`.
