# Helpers — formal signature reference

Every public helper, alphabetical-ish by category, with full signature + one-line description. The source of truth is `Basecoat.cfc` itself; this file is a quick lookup.

> Notation: `?` after a name = optional. Default values shown after `=`. All helpers return `string`.

## Setup / infrastructure

```
basecoatIncludes(
    cssPath = "/assets/basecoat/basecoat.min.css",
    extrasCssPath = "/assets/basecoat/wheels-basecoat-extras.min.css",
    jsPath = "/assets/basecoat/js/all.min.js",
    uiJsPath = "/assets/basecoat/js/wheels-basecoat-ui.min.js",
    basecoatJS = true,
    uiJS = true,
    extrasCSS = true,
    alpine = false,
    alpineVersion = "3",
    turboAware = true
) → <link>+<script> tags for the layout <head>
```

```
basecoatThemeScript(storageKey = "basecoat:theme")
    → inline pre-paint script that applies the saved theme to <html>

basecoatFlashToasts(toasterId = "toaster")
    → renders Wheels' flash() map as toasts inside a toaster
```

## Buttons & display

```
uiButton(text = "", variant = "primary", size = "md",
         icon = "", href = "", type = "button",
         disabled = false, loading = false, close = false,
         class = "", id = "", ariaLabel = "",
         turboConfirm = "", turboMethod = "")
    → <button> or <a> if href is set
    variant: primary | secondary | destructive | outline | ghost | link
    size:    sm | md | lg
    close=true → onclick="this.closest('dialog').close()" (for use inside uiDialog)

uiButtonGroup(orientation = "horizontal", class = "")  → <div class="button-group" role="group">
uiButtonGroupSeparator()                                → <hr role="separator">
uiButtonGroupEnd()                                       → </div>

uiBadge(text, variant = "default", class = "")  → <span class="badge*">
    variant: default | secondary | destructive | outline

uiAvatar(src = "", text = "?", alt = "", size = 40, class = "")
    → image avatar with text-initial fallback

uiKbd(text, class = "")  → <kbd class="kbd">

uiIcon(name, size = 24, strokeWidth = 2, class = "")
    → Lucide SVG. Available names: plus, trash, pencil, x, check, chevron-right,
      chevron-left, search, loader, alert-triangle, info, check-circle, send,
      ellipsis, external-link, sun, moon, log-out, log-in, user, settings, menu,
      home, file-text, star

uiSpinner(class = "")            → <div class="spinner">
uiSkeleton(lines = 1, height = "h-4", width = "w-full", class = "")
                                  → loading placeholder
uiProgress(value, class = "")    → <div class="progress"><div class="progress-indicator" style="width: X%">
uiSeparator(class = "")          → <hr class="separator">
```

## Feedback

```
uiAlert(title = "", description = "", variant = "default", icon = "", class = "")
    → self-closing <div class="alert"><svg/><h5/><section><p/></section></div>
    variant: default | destructive

uiCallout(title = "", body = "", variant = "info", icon = "", class = "")
    → boxed inline note for body content (lighter than alert)
    variant: info | tip | warning | success

uiTooltip(tip, class = "")       → <span class="tooltip" data-tip="...">
uiTooltipEnd()                   → </span>

uiToaster(id = "toaster", class = "")  → <div id="toaster" class="toaster">
uiToast(title = "", description = "", variant = "info", duration = -1, class = "")
    → server-rendered toast inside a toaster
    variant: info | success | warning | error
    duration -1: basecoat-js default (3s normal, 5s error)

uiEmptyState(title = "", description = "", icon = "info",
             actionText = "", actionHref = "", actionIcon = "plus", class = "")
    → centered empty placeholder with optional CTA button
```

## Containers

```
uiCard(class = "")                                        → <div class="card">
uiCardHeader(title = "", description = "", class = "")     → <header><h2/><p/></header>
uiCardContent(class = "")                                 → <section>
uiCardContentEnd()                                         → </section>
uiCardFooter(class = "")                                  → <footer>
uiCardFooterEnd()                                          → </footer>
uiCardEnd()                                                → </div>

uiFieldset(legend = "", description = "", class = "")     → <fieldset class="fieldset">
uiFieldsetEnd()                                            → </fieldset>

uiAccordion(class = "")                                   → <div class="ui-accordion">
uiAccordionItem(title, open = false, class = "")          → <details><summary>...</summary>
uiAccordionItemEnd()                                       → </details>
uiAccordionEnd()                                           → </div>

uiTimeline(class = "")                                    → <ol class="ui-timeline">
uiTimelineItem(title, time = "", icon = "", description = "", class = "")
                                                          → <li><span/><div/></li>
uiTimelineEnd()                                            → </ol>
```

## Overlays

```
uiDialog(title, description = "", triggerText = "",
         triggerClass = "btn-outline", id = "",
         maxWidth = "sm:max-w-[425px]", class = "")
    → optional trigger + <dialog> + <header> + opens <section>
uiDialogFooter()  → </section><footer>
uiDialogEnd()     → </footer><button aria-label="Close">×</button></div></dialog>

uiPopover(class = "")                                            → <div class="popover">
uiPopoverTrigger(text, triggerClass = "btn-outline", class = "")  → <button aria-expanded="false">
uiPopoverContent(class = "")                                     → <div data-popover aria-hidden="true">
uiPopoverContentEnd()                                             → </div>
uiPopoverEnd()                                                    → </div>

uiCommand(class = "")                                                              → <div class="command">
uiCommandInput(placeholder = "Search...", ariaLabel = "...", class = "")           → <header><input>
uiCommandList(class = "")                                                          → <div role="menu">
uiCommandListEnd()                                                                  → </div>
uiCommandGroup(label, class = "")                                                  → <div role="group">
uiCommandGroupEnd()                                                                 → </div>
uiCommandItem(text, href = "", keywords = "", icon = "", kbd = "",
              force = false, keepOpen = false, disabled = false, class = "")
                                                                                    → <button|a role="menuitem">
uiCommandSeparator()                                                                → <hr role="separator">
uiCommandEmpty(text = "No results.", class = "")                                   → static "no results" placeholder
uiCommandEnd()                                                                      → </div>
uiCommandDialog(triggerText = "", triggerClass = "btn-outline", id = "", class = "")
                                                                                    → <button>+<dialog class="dialog command-dialog">
uiCommandDialogEnd()                                                                → </dialog>
```

## Forms (unbound)

```
uiField(label, name, type = "text", value = "", id = "",
        placeholder = "", description = "", errorMessage = "",
        required = false, disabled = false, checked = false,
        options = "", rows = 4, class = "")
    → <div><label/><input|textarea|select/><p.description/><p.error/></div>
    type: text | email | password | number | tel | url | date |
          datetime-local | time | search | textarea | select | checkbox | switch
    options: "value:Label,value:Label" (for type=select)

uiSelect(name, options, value = "", placeholder = "Select an option",
         search = false, multiselect = false, closeOnSelect = false,
         id = "", class = "")
    → <div class="select"><button><span/></button><div data-popover><...><input hidden/></div>
    Driven by basecoat-js's select.js (popover, search, multi-select).

uiSlider(name, value = "", min = 0, max = 100, step = 1,
         label = "", showValue = false, disabled = false,
         id = "", class = "")
    → <input type="range" style="--slider-value: X%"> + optional <output>

uiCheckboxGroup(name, options, value = "", legend = "",
                description = "", inline = false, class = "")
    → <fieldset><legend/><p/><div class="grid|flex"><div><input type="checkbox" name="X[]"/><label/></div>...</div></fieldset>
    options: "value:Label[:disabled],..."
    value: comma-separated string, JSON array, or real CFML array

uiRadioGroup(name, options, value = "", legend = "",
             description = "", inline = false, class = "")
    → <fieldset><legend/><div role="radiogroup"><div><input type="radio"/><label/></div>...</div></fieldset>

uiTagInput(name, value = "", suggestions = "", placeholder = "Add a tag...",
           label = "", description = "", maxTags = 0, allowFree = true,
           id = "", class = "")
    → multi-value chip entry with optional suggestion list + free-form add

uiFileUpload(name, accept = "", multiple = false, dragDrop = true,
             label = "", description = "", id = "", class = "")
    → <label class="ui-file-upload"><input type="file"/><span class="ui-file-upload-prompt"/></label>

uiDatePicker(name, value = "", label = "", description = "",
             min = "", max = "", id = "", class = "")
    → basecoat-styled <input type="date"> with optional min/max bounds

uiRating(value = 0, max = 5, name = "", ariaLabel = "Rating", class = "")
    → read-only <span> stars OR interactive <fieldset> radios when name= is set
```

## Forms (Wheels-bound)

```
uiBoundField(objectName, property, label = "", type = "text",
             id = "", placeholder = "", description = "",
             required = false, disabled = false,
             options = "", rows = 4, class = "")
    → uiField composed from variables[objectName][property]
       + variables[objectName].errorsOn(property)

uiBoundSelect(objectName, property, options, placeholder = "Select an option",
              search = false, multiselect = false, closeOnSelect = false,
              id = "", class = "")

uiBoundSlider(objectName, property, min = 0, max = 100, step = 1,
              label = "", showValue = false, disabled = false,
              id = "", class = "")

uiBoundCheckbox(objectName, property, label = "", switch = false,
                description = "", disabled = false, id = "", class = "")
    → emits a hidden falsy companion input + the checkbox; round-trip-safe
       so params.<obj>.<prop> is always defined as 0 or 1

uiBoundCheckboxGroup(objectName, property, options,
                     legend = "", description = "", inline = false, class = "")

uiBoundRadioGroup(objectName, property, options,
                  legend = "", description = "", inline = false, class = "")

uiBoundFile(objectName, property, accept = "", multiple = false,
            dragDrop = true, label = "", description = "", id = "", class = "")

uiErrorSummary(model, title = "", description = "")
    → "" if model has no errors; otherwise destructive alert with bullet list of field-prefixed messages
```

## Tables

```
uiTable(class = "")               → <div class="table-container"><table>
uiTableHeader()                   → <thead><tr>
uiTableHeaderEnd()                → </tr></thead>
uiTableBody()                     → <tbody>
uiTableBodyEnd()                  → </tbody>
uiTableRow(class = "")            → <tr>
uiTableRowEnd()                   → </tr>
uiTableHead(text = "", class = "") → <th>...</th>
uiTableCell(text = "", class = "") → <td>...</td>
uiTableEnd()                      → </table></div>

uiResourceTable(query, columns = "", editRoute = "", deleteRoute = "",
                showRoute = "", keyColumn = "id", class = "")
    → auto-builds a basecoat table from a Wheels query result.
       columns="title,status" picks specific columns; "" means all.
       editRoute / deleteRoute / showRoute opt-in row actions.
```

## Navigation

```
uiTabs(defaultTab = "", id = "", class = "")        → <div class="tabs">  (stashes context in request)
uiTabList(ariaLabel = "Tabs", class = "")          → <div role="tablist">
uiTabListEnd()                                       → </div>
uiTabTrigger(value, text, class = "")              → <button role="tab" aria-controls="..." aria-selected="...">
uiTabContent(value, class = "")                    → <div role="tabpanel" hidden|"">
uiTabContentEnd()                                    → </div>
uiTabsEnd()                                          → </div>

uiDropdown(text, triggerClass = "btn-outline", class = "")  → <div class="dropdown-menu"><button><div data-popover><div role="menu">
uiDropdownItem(text, href = "", class = "", disabled = false)
                                                            → <a|button role="menuitem">
uiDropdownSeparator()                                       → <hr role="separator">
uiDropdownEnd()                                              → </div></div></div>

uiBreadcrumb(class = "")                            → <nav aria-label="Breadcrumb"><ol class="breadcrumb">
uiBreadcrumbItem(text, href = "")                  → <li><a> (with href) or <li><span aria-current="page">
uiBreadcrumbSeparator()                              → <li aria-hidden><svg/></li>
uiBreadcrumbEnd()                                    → </ol></nav>

uiPagination(currentPage, totalPages, baseUrl, pageParam = "page",
             windowSize = 2, class = "")
uiPaginationFor(query, baseUrl, pageParam = "page", windowSize = 2, class = "")
    → reads `query.totalpages` / `query.currentpage` from a Wheels-paginated query

uiSidebar(side = "left", initialOpen = true, initialMobileOpen = false,
          breakpoint = 768, id = "", class = "")
    → <aside class="sidebar" data-side="..." ...><nav>
uiSidebarHeader(class = "")                                 → <header>
uiSidebarHeaderEnd()                                         → </header>
uiSidebarBody(class = "")                                   → <section>
uiSidebarBodyEnd()                                           → </section>
uiSidebarGroup(title = "", class = "")                      → <div role="group"><h3>title</h3>
uiSidebarGroupEnd()                                          → </div>
uiSidebarItem(text, href = "##", icon = "", active = false, class = "")
                                                             → <a aria-current="page"|"">
uiSidebarSeparator()                                         → <hr role="separator">
uiSidebarFooter(class = "")                                 → <footer>
uiSidebarFooterEnd()                                         → </footer>
uiSidebarEnd()                                               → </nav></aside>
uiSidebarToggle(text = "", sidebarId = "", action = "toggle",
                icon = "menu", class = "btn-icon-ghost",
                ariaLabel = "Toggle sidebar")
    → CSP-safe button that dispatches the basecoat:sidebar CustomEvent
    action: toggle | open | close

uiSteps(ariaLabel = "Progress", class = "")          → <nav><ol class="ui-steps">
uiStep(text, status = "upcoming", number = "",
       description = "", href = "")
    → <li data-status="..."><span class="ui-step-marker"/><span class="ui-step-text"/></li>
    status: complete | current | upcoming
    Auto-numbers via a request-scoped counter when number is omitted.
uiStepsEnd()                                          → </ol></nav>
```

## Code display

```
uiCodeBlock(content = "", language = "", filename = "",
            showCopy = true, class = "")
    → <pre><code> with optional title bar (filename + language) + copy button
```

## Theme

```
uiThemeToggle(size = "sm", class = "",
              storageKey = "basecoat:theme",
              ariaLabel = "Toggle theme")
    → CSP-safe button (data-ui-theme-toggle) that flips .dark on <html>
```

## Hotwire / Turbo

```
turboStreamHeader()
    → sets Content-Type: text/vnd.turbo-stream.html (returns "")

turboStream(action, target = "", targets = "", method = "")
    → <turbo-stream action="..."> ... follow with HTML content + turboStreamEnd()
       OR returns self-closing element for action=remove|refresh
    action: append | prepend | replace | update | before | after | morph | remove | refresh

turboStreamEnd()  → </template></turbo-stream>
```

## Wheels conventions

```
uiResourceForm(model, submitRoute = "", submitMethod = "create|update",
               class = "", excludeFields = "id,createdAt,updatedAt,deletedAt")
    → auto-builds a uiBoundField-per-property form from the model's introspected
      properties. Reads enum() declarations to pick select fields, validatesPresenceOf
      for required flags, type metadata for input type.
```

## Validation

```
$validateEnum(value, allowed, helper, argument)
    → throws WheelsBasecoat.InvalidArgument when value not in the comma-separated allowed list.
       Used internally by every helper that takes an enum-typed argument.
```
