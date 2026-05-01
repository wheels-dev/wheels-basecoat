<!---
	Documentation page rendered by Wheels at /wheels/packages/wheels-basecoat.
	Helper mixins aren't in scope here (the page renders in the Wheels admin
	view context, not in an app controller), so this is a static reference —
	for live rendered examples open the README or run the helpers in your
	own app and inspect.
--->
<style>
	.wbc-doc { max-width: 64rem; margin: 0 auto; padding: 1rem; }
	.wbc-doc h2 { font-size: 1.25rem; font-weight: 600; margin: 2rem 0 .5rem; padding-bottom: .25rem; border-bottom: 1px solid rgba(255,255,255,.1); }
	.wbc-doc h3 { font-size: 1rem; font-weight: 600; margin: 1.25rem 0 .25rem; }
	.wbc-doc p.lead { color: rgba(255,255,255,.6); font-size: .9rem; margin: .25rem 0 .75rem; }
	.wbc-doc pre { background: rgba(0,0,0,.25); border-radius: .5rem; padding: .75rem .9rem; font-size: .8rem; overflow-x: auto; }
	.wbc-doc code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
	.wbc-doc :not(pre) > code { background: rgba(255,255,255,.08); padding: .1rem .35rem; border-radius: .25rem; font-size: .85em; }
	.wbc-doc table { width: 100%; border-collapse: collapse; margin: .5rem 0 1rem; }
	.wbc-doc th, .wbc-doc td { text-align: left; padding: .35rem .6rem; border-bottom: 1px solid rgba(255,255,255,.08); font-size: .85rem; vertical-align: top; }
	.wbc-doc th { font-weight: 600; }
	.wbc-doc ul { margin: .25rem 0 .5rem 1.25rem; padding: 0; }
	.wbc-doc li { font-size: .9rem; margin: .25rem 0; }
	.wbc-doc .pill { display: inline-block; padding: .15rem .5rem; border-radius: .25rem; background: rgba(102, 126, 234, .25); color: rgba(180, 200, 255, 1); font-size: .75rem; font-weight: 600; vertical-align: middle; margin-left: .25rem; }
	.wbc-doc .pill-new { background: rgba(34, 197, 94, .2); color: rgb(134, 239, 172); }
	.wbc-doc .pill-bcv { background: rgba(168, 85, 247, .2); color: rgb(216, 180, 254); }
</style>

<div class="wbc-doc">

	<h2>wheels-basecoat <span class="pill pill-bcv">basecoat-css 0.3.x</span></h2>
	<p class="lead">
		<a href="https://basecoatui.com/" target="_blank">Basecoat UI</a> component helpers for Wheels —
		shadcn/ui-quality design as plain HTML, no React, no build step. Bundled
		basecoat-css + basecoat-js. Wheels model-bound form fields. Native
		Hotwire/Turbo integration. Dark mode out of the box.
	</p>

	<h2>Quickstart</h2>
	<p class="lead">Three steps from <code>wheels packages add wheels-basecoat</code> to rendered components:</p>
	<ol>
		<li>Publish the bundled assets: <code>cp -r vendor/wheels-basecoat/assets/basecoat public/assets/basecoat</code></li>
		<li>In <code>app/views/layout.cfm &lt;head&gt;</code>: <code>basecoatThemeScript() basecoatIncludes()</code></li>
		<li>In any view: <code>uiButton(text="Save", icon="check")</code> etc.</li>
	</ol>
	<p class="lead">See the <a href="https://github.com/wheels-dev/wheels-basecoat/blob/main/README.md" target="_blank">README</a> for the full component reference, integration guides, and rendered examples.</p>

	<h2>Helpers</h2>

	<h3>Setup</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>basecoatIncludes</code></td><td>Render the &lt;link&gt; / &lt;script&gt; tags for basecoat-css + basecoat-js + the wheels-basecoat-ui shim.</td></tr>
		<tr><td><code>basecoatThemeScript</code> <span class="pill pill-new">v2</span></td><td>Inline pre-paint script that applies the saved theme (light/dark) before first paint.</td></tr>
	</table>

	<h3>Buttons &amp; display</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>uiButton</code></td><td>Variants: primary, secondary, destructive, outline, ghost, link. Sizes: sm, md, lg. Optional Lucide icon.</td></tr>
		<tr><td><code>uiButtonGroup</code> + <code>uiButtonGroupSeparator</code> + <code>uiButtonGroupEnd</code> <span class="pill pill-new">v2</span></td><td>Joined-border button cluster. Horizontal or vertical.</td></tr>
		<tr><td><code>uiBadge</code></td><td>Variants: default, secondary, destructive, outline.</td></tr>
		<tr><td><code>uiAvatar</code> <span class="pill pill-new">v2</span></td><td>Image avatar with text-initial fallback.</td></tr>
		<tr><td><code>uiKbd</code> <span class="pill pill-new">v2</span></td><td>Keyboard-key indicator for menus and command palettes.</td></tr>
		<tr><td><code>uiIcon</code></td><td>Lucide SVG icon by name. Size + stroke configurable.</td></tr>
		<tr><td><code>uiSpinner</code></td><td>CSS-animated loading spinner.</td></tr>
		<tr><td><code>uiSkeleton</code></td><td>Loading placeholder. Configurable lines / dimensions.</td></tr>
		<tr><td><code>uiProgress</code></td><td>Linear progress bar with explicit value.</td></tr>
		<tr><td><code>uiSeparator</code></td><td>Horizontal rule (&lt;hr&gt;).</td></tr>
	</table>

	<h3>Feedback</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>uiAlert</code></td><td>Inline notice. Variants: default, destructive.</td></tr>
		<tr><td><code>uiTooltip</code> + <code>uiTooltipEnd</code></td><td>Wrap a trigger element in a tooltip.</td></tr>
		<tr><td><code>uiToaster</code> <span class="pill pill-new">v2</span></td><td>Singleton toast container. Place once per layout.</td></tr>
		<tr><td><code>uiToast</code> <span class="pill pill-new">v2</span></td><td>Server-rendered toast inside a toaster. Variants: info, success, warning, error.</td></tr>
		<tr><td><code>basecoatFlashToasts</code> <span class="pill pill-new">v2</span></td><td>One-call replacement for <code>flashMessages()</code> — renders Wheels' flash() map as toasts.</td></tr>
	</table>

	<h3>Containers</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>uiCard</code> + <code>uiCardHeader</code> + <code>uiCardContent</code> + <code>uiCardFooter</code> + <code>uiCardEnd</code></td><td>Semantic &lt;header&gt; / &lt;section&gt; / &lt;footer&gt; children styled by basecoat-css 0.3.x.</td></tr>
		<tr><td><code>uiFieldset</code> + <code>uiFieldsetEnd</code> <span class="pill pill-new">v2</span></td><td>&lt;fieldset&gt; wrapper with optional legend + description.</td></tr>
	</table>

	<h3>Overlays</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>uiDialog</code> + <code>uiDialogFooter</code> + <code>uiDialogEnd</code></td><td>Native &lt;dialog&gt; modal. CSP-safe open/close (data-attribute delegated).</td></tr>
		<tr><td><code>uiPopover</code> + <code>uiPopoverTrigger</code> + <code>uiPopoverContent</code> + <code>uiPopoverEnd</code> <span class="pill pill-new">v2</span></td><td>basecoat-js–driven popover with aria-expanded / aria-hidden toggle, outside-click + Escape dismissal.</td></tr>
		<tr><td><code>uiCommand</code> family + <code>uiCommandDialog</code> <span class="pill pill-new">v2.2</span></td><td>Command palette with live filter, keyboard navigation, and optional ⌘K-style modal wrapper. Driven by <code>command.js</code>. Items support keywords, icons, kbd hints.</td></tr>
	</table>

	<h3>Forms</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>uiField</code></td><td>Label + input + description + error. Types: text, email, password, number, tel, url, date, datetime-local, time, search, textarea, select, checkbox, switch.</td></tr>
		<tr><td><code>uiBoundField</code> <span class="pill pill-new">v2</span></td><td>Wheels model-bound field — auto-resolves value, name, label, and error from the controller-scoped model object. Mirrors <code>textField(objectName=, property=)</code>'s API.</td></tr>
		<tr><td><code>uiSelect</code> <span class="pill pill-new">v2.2</span></td><td>Rich combobox (popover, optional search, multi-select). Distinct from <code>uiField(type=select)</code> which renders a native &lt;select&gt;. Driven by <code>select.js</code>.</td></tr>
		<tr><td><code>uiBoundSelect</code> <span class="pill pill-new">v2.3</span></td><td>Wheels-bound variant of <code>uiSelect</code> — same ergonomics as <code>uiBoundField</code>, with multiselect-array auto-serialization.</td></tr>
		<tr><td><code>uiSlider</code> <span class="pill pill-new">v2.3</span></td><td>basecoat-styled range slider with --slider-value fill computed server-side. Optional output mirror kept live by wheels-basecoat-ui.js.</td></tr>
		<tr><td><code>uiBoundSlider</code> <span class="pill pill-new">v2.3</span></td><td>Wheels-bound variant of <code>uiSlider</code>.</td></tr>
	</table>

	<pre><code>uiBoundField(objectName="post", property="title", required=true)
uiBoundField(objectName="post", property="body", type="textarea", rows=10)
uiBoundField(objectName="post", property="status", type="select",
             options="draft:Draft,published:Published,archived:Archived")</code></pre>

	<h3>Tables</h3>
	<p class="lead">Block helpers: <code>uiTable</code> · <code>uiTableHeader</code> · <code>uiTableBody</code> · <code>uiTableRow</code> · <code>uiTableHead</code> · <code>uiTableCell</code> + matching <code>*End</code> closers.</p>

	<h3>Navigation</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>uiTabs</code> + <code>uiTabList</code> + <code>uiTabTrigger</code> + <code>uiTabContent</code> <span class="pill pill-new">v2.1</span></td><td>ARIA tabs ([role=tablist] / [role=tab] / [role=tabpanel]) driven by basecoat-js. Auto-pairs aria-controls / aria-labelledby across triggers and panels.</td></tr>
		<tr><td><code>uiDropdown</code> + <code>uiDropdownItem</code> + <code>uiDropdownSeparator</code> + <code>uiDropdownEnd</code> <span class="pill pill-new">v2.1</span></td><td>.dropdown-menu wrapper + popover-driven menu with [role=menuitem] children. Keyboard navigation, outside-click + Escape dismissal.</td></tr>
		<tr><td><code>uiBreadcrumb</code> + <code>uiBreadcrumbItem</code> + <code>uiBreadcrumbSeparator</code> + <code>uiBreadcrumbEnd</code> <span class="pill pill-new">CSS in v2.2</span></td><td>Semantic &lt;nav&gt;&lt;ol&gt; trail. Trailing item with no href becomes the current page (aria-current). v2.2 ships visual defaults via the bundled <code>wheels-basecoat-extras.min.css</code>.</td></tr>
		<tr><td><code>uiPagination</code> <span class="pill pill-new">CSS in v2.2</span></td><td>Full prev/next + page-number nav with ellipsis windows. ARIA-compliant. v2.2 ships visual defaults.</td></tr>
		<tr><td><code>uiSteps</code> + <code>uiStep</code> + <code>uiStepsEnd</code> <span class="pill pill-new">v2.3</span></td><td>Multi-step / wizard progress indicator. Status: complete / current / upcoming. Auto-numbered. Mobile-stacked.</td></tr>
		<tr><td><code>uiSidebar</code> + <code>uiSidebarHeader</code> + <code>uiSidebarBody</code> + <code>uiSidebarGroup</code> + <code>uiSidebarItem</code> + <code>uiSidebarFooter</code> <span class="pill pill-new">v2.1</span></td><td>Semantic &lt;aside&gt;&lt;nav&gt;&lt;header&gt;/&lt;section&gt;/&lt;footer&gt; structure with mobile-collapse + open/close events handled by basecoat-js.</td></tr>
		<tr><td><code>uiSidebarToggle</code> <span class="pill pill-new">v2.1</span></td><td>CSP-safe button that dispatches the basecoat:sidebar CustomEvent (open / close / toggle).</td></tr>
	</table>

	<pre><code>uiSidebar()
  uiSidebarHeader()
    &lt;strong&gt;Acme Co.&lt;/strong&gt;
  uiSidebarHeaderEnd()
  uiSidebarBody()
    uiSidebarGroup(title="Workspace")
      uiSidebarItem(text="Home",   href="/",       icon="home", active=true)
      uiSidebarItem(text="Posts",  href="/posts",  icon="file-text")
      uiSidebarItem(text="People", href="/people", icon="user")
    uiSidebarGroupEnd()
  uiSidebarBodyEnd()
uiSidebarEnd()</code></pre>

	<h3>Theme</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>uiThemeToggle</code> <span class="pill pill-new">v2</span></td><td>Sun/moon toggle button. Flips .dark on &lt;html&gt; and persists to localStorage. CSP-safe.</td></tr>
	</table>

	<h3>Hotwire / Turbo</h3>
	<table>
		<tr><th>Helper</th><th>Purpose</th></tr>
		<tr><td><code>turboStream</code> + <code>turboStreamEnd</code> <span class="pill pill-new">v2</span></td><td>Compose &lt;turbo-stream&gt; responses. Actions: append, prepend, replace, update, before, after, morph, remove, refresh.</td></tr>
		<tr><td><code>turboStreamHeader</code> <span class="pill pill-new">v2</span></td><td>Set the Content-Type header (Turbo 8 strictly requires it).</td></tr>
	</table>

	<pre><code>turboStreamHeader()
turboStream(action="remove", target="post_<id>")

turboStream(action="append", target="comments")
  &lt;article id="comment_<id>"&gt;...&lt;/article&gt;
turboStreamEnd()</code></pre>

	<h2>Argument validation <span class="pill pill-new">v2</span></h2>
	<p class="lead">
		Typos throw <code>WheelsBasecoat.InvalidArgument</code> with the helper name,
		the bad value, and the allowed list. Wired into <code>uiButton</code>,
		<code>uiBadge</code>, <code>uiAlert</code>, <code>uiField</code>,
		<code>uiToast</code>, <code>uiButtonGroup</code>, <code>uiSidebar</code>,
		<code>uiSidebarToggle</code>, <code>uiThemeToggle</code>, <code>turboStream</code>.
	</p>

	<h2>What's new</h2>
	<ul>
		<li><strong>v2.0</strong>: bundled CSS+JS, <code>uiBoundField</code>, toasts, popover, avatar, kbd, button group, fieldset, dark mode, Turbo Stream helpers, argument validation, CSP-safe dialog.</li>
		<li><strong>v2.1</strong>: tabs / dropdown / sidebar reworked to match basecoat-css 0.3.x's ARIA selectors and basecoat-js's contracts.</li>
		<li><strong>v2.2</strong>: bundled <code>wheels-basecoat-extras.min.css</code> (breadcrumb + pagination defaults), <code>uiCommand</code> family + <code>uiCommandDialog</code> (⌘K-style palette), <code>uiSelect</code> (rich combobox).</li>
		<li><strong>v2.3</strong>: <code>uiSlider</code> + <code>uiBoundSlider</code>, <code>uiSteps</code> family for wizards, <code>uiBoundSelect</code> Wheels integration for the rich combobox.</li>
	</ul>

	<h2>Links</h2>
	<ul>
		<li><a href="https://basecoatui.com/" target="_blank">Basecoat UI</a> · <a href="https://ui.shadcn.com/themes" target="_blank">Theme generator</a> · <a href="https://lucide.dev/icons" target="_blank">Lucide icons</a> · <a href="https://turbo.hotwired.dev/" target="_blank">Turbo</a></li>
		<li><a href="https://github.com/wheels-dev/wheels-basecoat" target="_blank">GitHub</a> · <a href="https://github.com/wheels-dev/wheels-basecoat/blob/main/README.md" target="_blank">README</a> · <a href="https://github.com/wheels-dev/wheels-basecoat/blob/main/CHANGELOG.md" target="_blank">Changelog</a></li>
	</ul>

</div>
