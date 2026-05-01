<!---
	Live showcase rendered by Wheels at /wheels/packages/wheels-basecoat.
	Every component below is rendered with a real helper call; the snippet
	you see beside it is the literal source. Use this as your visual reference
	and as a regression target — anything that drifts here is a bug.
--->
<cfoutput>
<style>
	.demo-grid { display: grid; grid-template-columns: 1fr; gap: 1.25rem; max-width: 64rem; margin: 0 auto; padding: 2rem 1rem; }
	@media (min-width: 900px) { .demo-grid > .demo { grid-template-columns: 1fr 1fr; } }
	.demo { display: grid; grid-template-columns: 1fr; gap: 1rem; padding: 1.25rem; border: 1px solid var(--border); border-radius: 0.75rem; }
	.demo h3 { font-weight: 600; font-size: 1rem; margin: 0 0 .25rem; }
	.demo p.lead { font-size: 0.875rem; color: var(--muted-foreground); margin: 0 0 .5rem; }
	.demo .preview { padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem; background: var(--background); display: flex; flex-direction: column; gap: 0.75rem; align-items: flex-start; min-height: 4rem; }
	.demo pre { background: var(--muted); border-radius: 0.5rem; padding: 0.75rem 0.875rem; font-size: 0.78rem; overflow-x: auto; margin: 0; }
	.demo pre code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
	.demo-hero { padding: 2rem 1rem; max-width: 64rem; margin: 0 auto 1rem; display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
	.demo-hero h1 { font-size: 1.875rem; line-height: 1.15; font-weight: 700; letter-spacing: -0.02em; margin: 0; }
	.demo-hero p { color: var(--muted-foreground); margin: 0.25rem 0 0; }
</style>

<header class="demo-hero">
	<div>
		<h1>wheels-basecoat showcase</h1>
		<p>Every helper rendered live, with the source it came from.</p>
	</div>
	<div style="display:flex;gap:.5rem;align-items:center">
		#uiBadge(text="basecoat-css 0.3.x", variant="secondary")#
		#uiThemeToggle()#
	</div>
</header>

<div class="demo-grid">

	<!-- Buttons -->
	<section class="demo">
		<div>
			<h3>Buttons</h3>
			<p class="lead">Six variants × three sizes × optional icon. Every variant emits an explicit <code>btn-*</code> class so the rendered HTML is self-documenting.</p>
		</div>
		<div class="preview">
			#uiButton(text="Primary")#
			#uiButton(text="Secondary", variant="secondary")#
			#uiButton(text="Outline", variant="outline")#
			#uiButton(text="Ghost", variant="ghost")#
			#uiButton(text="Destructive", variant="destructive", icon="trash")#
			#uiButton(text="Link", variant="link")#
		</div>
		<pre><code>###uiButton(text="Primary")##
###uiButton(text="Destructive", variant="destructive", icon="trash")##</code></pre>
	</section>

	<!-- Badges -->
	<section class="demo">
		<div>
			<h3>Badges</h3>
			<p class="lead">Inline labels for status and metadata.</p>
		</div>
		<div class="preview">
			#uiBadge(text="Default")#
			#uiBadge(text="Secondary", variant="secondary")#
			#uiBadge(text="Outline", variant="outline")#
			#uiBadge(text="Destructive", variant="destructive")#
		</div>
		<pre><code>###uiBadge(text="Published")##</code></pre>
	</section>

	<!-- Avatar / Kbd -->
	<section class="demo">
		<div>
			<h3>Avatar &amp; keyboard key</h3>
			<p class="lead">Image avatars with text-initial fallback; keyboard hints for menus and command palettes.</p>
		</div>
		<div class="preview" style="flex-direction:row;align-items:center;flex-wrap:wrap;gap:1rem;">
			#uiAvatar(text="AB", alt="Ada Beth")#
			#uiAvatar(text="MK", alt="Marie K", size=32)#
			<span>Press #uiKbd(text="⌘K")# to search</span>
		</div>
		<pre><code>###uiAvatar(text="AB")##
###uiKbd(text="⌘K")##</code></pre>
	</section>

	<!-- Card -->
	<section class="demo">
		<div>
			<h3>Card</h3>
			<p class="lead">Semantic <code>&lt;header&gt; / &lt;section&gt; / &lt;footer&gt;</code> children — basecoat-css 0.3.x styles them via direct-child selectors.</p>
		</div>
		<div class="preview" style="display:block">
			#uiCard()#
				#uiCardHeader(title="Order ##1024", description="Placed 2 days ago.")#
				#uiCardContent()#
					<p>Total: $42.00 · 3 items · Express shipping</p>
				#uiCardContentEnd()#
				#uiCardFooter()#
					#uiButton(text="View order", variant="outline", size="sm")#
				#uiCardFooterEnd()#
			#uiCardEnd()#
		</div>
		<pre><code>###uiCard()##
  ###uiCardHeader(title="Order ##1024", description="...")##
  ###uiCardContent()##  ...  ###uiCardContentEnd()##
  ###uiCardFooter()##   ...  ###uiCardFooterEnd()##
###uiCardEnd()##</code></pre>
	</section>

	<!-- Alert -->
	<section class="demo">
		<div>
			<h3>Alert</h3>
			<p class="lead">Inline notice for the current page. Use <code>uiToast()</code> for transient feedback.</p>
		</div>
		<div class="preview" style="display:block">
			#uiAlert(title="Heads up", description="Your trial ends in 3 days.")#
			<div style="height: .5rem"></div>
			#uiAlert(title="Couldn't save", description="Title is required.", variant="destructive")#
		</div>
		<pre><code>###uiAlert(title="Heads up", description="...")##
###uiAlert(variant="destructive", title="Couldn't save", ...)##</code></pre>
	</section>

	<!-- Form fields -->
	<section class="demo">
		<div>
			<h3>Form fields</h3>
			<p class="lead">Use <code>uiField()</code> for ad-hoc inputs, <code>uiBoundField()</code> for Wheels model binding.</p>
		</div>
		<div class="preview" style="display:block">
			#uiField(label="Email", name="email", type="email", placeholder="you@example.com", required=true, description="We'll never share your email.")#
			<div style="height: .75rem"></div>
			#uiField(label="Plan", name="plan", type="select", options="free:Free,pro:Pro,team:Team")#
			<div style="height: .75rem"></div>
			#uiField(label="Bio", name="bio", type="textarea", rows=3, errorMessage="Please tell us a bit about yourself.")#
		</div>
		<pre><code>###uiField(label="Email", name="email", type="email", required=true)##
###uiBoundField(objectName="post", property="title", required=true)##</code></pre>
	</section>

	<!-- Field state: error -->
	<section class="demo">
		<div>
			<h3>Form field — error state</h3>
			<p class="lead">Pass <code>errorMessage=</code> and the input gets the destructive border + ARIA wiring automatically.</p>
		</div>
		<div class="preview" style="display:block">
			#uiField(label="Title", name="post[title]", value="", required=true, errorMessage="Title can't be empty.")#
		</div>
		<pre><code>###uiField(label="Title", name="post[title]",
         errorMessage="Title can't be empty.")##</code></pre>
	</section>

	<!-- Toast -->
	<section class="demo">
		<div>
			<h3>Toast</h3>
			<p class="lead">Server-rendered toasts inside <code>&lt;div id="toaster" class="toaster"&gt;</code>. Use <code>basecoatFlashToasts()</code> to auto-render Wheels' <code>flash()</code> entries.</p>
		</div>
		<div class="preview" style="display:block">
			<div class="toaster" style="position:relative;inset:auto;padding:0;background:transparent;">
				#uiToast(title="Saved", description="Your post is live.", variant="success")#
				<div style="height:.5rem"></div>
				#uiToast(title="Couldn't reach the server", variant="error")#
			</div>
		</div>
		<pre><code>###basecoatFlashToasts()##  &lt;!-- in layout --&gt;
###uiToast(title="Saved", variant="success")##</code></pre>
	</section>

	<!-- Button group -->
	<section class="demo">
		<div>
			<h3>Button group</h3>
			<p class="lead">Joined-border button cluster. Horizontal by default, vertical via <code>orientation="vertical"</code>.</p>
		</div>
		<div class="preview">
			#uiButtonGroup()#
				#uiButton(text="Day", variant="outline")#
				#uiButton(text="Week", variant="outline")#
				#uiButton(text="Month", variant="outline")#
			#uiButtonGroupEnd()#
		</div>
		<pre><code>###uiButtonGroup()##
  ###uiButton(text="Day", variant="outline")##
  ###uiButton(text="Week", variant="outline")##
###uiButtonGroupEnd()##</code></pre>
	</section>

	<!-- Spinner / Skeleton / Progress -->
	<section class="demo">
		<div>
			<h3>Loading indicators</h3>
			<p class="lead">Spinner, skeleton placeholder, and progress bar.</p>
		</div>
		<div class="preview" style="flex-direction:row;align-items:center;gap:1.5rem;">
			#uiSpinner()#
			<div style="flex:1">#uiProgress(value=64)#</div>
		</div>
		<div class="preview" style="display:block">
			#uiSkeleton(lines=3)#
		</div>
		<pre><code>###uiSpinner()##
###uiProgress(value=64)##
###uiSkeleton(lines=3)##</code></pre>
	</section>

	<!-- Dialog -->
	<section class="demo">
		<div>
			<h3>Dialog</h3>
			<p class="lead">Native <code>&lt;dialog&gt;</code> with CSP-safe open/close (delegated by <code>wheels-basecoat-ui.js</code>).</p>
		</div>
		<div class="preview">
			#uiDialog(
				title="Delete post?",
				description="This will permanently delete the post and all its comments.",
				triggerText="Delete post",
				triggerClass="btn-destructive"
			)#
				<p>Are you sure? This cannot be undone.</p>
			#uiDialogFooter()#
				#uiButton(text="Cancel", variant="ghost", close=true)#
				#uiButton(text="Yes, delete", variant="destructive")#
			#uiDialogEnd()#
		</div>
		<pre><code>###uiDialog(title="Delete?", triggerText="Delete")##
  &lt;p&gt;Are you sure?&lt;/p&gt;
###uiDialogFooter()##
  ###uiButton(text="Cancel", close=true)##
###uiDialogEnd()##</code></pre>
	</section>

	<!-- Popover -->
	<section class="demo">
		<div>
			<h3>Popover</h3>
			<p class="lead">basecoat-js–driven popover that toggles <code>aria-expanded</code> on the trigger and <code>aria-hidden</code> on the content.</p>
		</div>
		<div class="preview">
			#uiPopover()#
				#uiPopoverTrigger(text="Filters")#
				#uiPopoverContent()#
					<p style="font-size:.875rem;margin:0">Refine the list. Status, date range, author.</p>
				#uiPopoverContentEnd()#
			#uiPopoverEnd()#
		</div>
		<pre><code>###uiPopover()##
  ###uiPopoverTrigger(text="Filters")##
  ###uiPopoverContent()##
    &lt;p&gt;...&lt;/p&gt;
  ###uiPopoverContentEnd()##
###uiPopoverEnd()##</code></pre>
	</section>

	<!-- Breadcrumb -->
	<section class="demo">
		<div>
			<h3>Breadcrumb</h3>
			<p class="lead">Trailing item with no <code>href</code> renders as the current page.</p>
		</div>
		<div class="preview">
			#uiBreadcrumb()#
				#uiBreadcrumbItem(text="Home", href="##")#
				#uiBreadcrumbSeparator()#
				#uiBreadcrumbItem(text="Posts", href="##")#
				#uiBreadcrumbSeparator()#
				#uiBreadcrumbItem(text="Hello world")#
			#uiBreadcrumbEnd()#
		</div>
		<pre><code>###uiBreadcrumb()##
  ###uiBreadcrumbItem(text="Home", href="/")##
  ###uiBreadcrumbSeparator()##
  ###uiBreadcrumbItem(text="Hello world")##
###uiBreadcrumbEnd()##</code></pre>
	</section>

	<!-- Turbo helpers -->
	<section class="demo">
		<div>
			<h3>Turbo Stream helpers</h3>
			<p class="lead">Compose Turbo Stream responses from CFML. Always pair the body with <code>turboStreamHeader()</code> to set the Content-Type.</p>
		</div>
		<div class="preview" style="display:block;font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:.85rem;">
			<div>#htmlEditFormat(turboStream(action="remove", target="post_42"))#</div>
			<div style="margin-top:.5rem">#htmlEditFormat(turboStream(action="append", target="comments"))#&hellip;#htmlEditFormat(turboStreamEnd())#</div>
		</div>
		<pre><code>###turboStreamHeader()##
###turboStream(action="remove", target="post_##post.id##")##

###turboStream(action="append", target="comments")##
  &lt;article id="comment_##c.id##"&gt;...&lt;/article&gt;
###turboStreamEnd()##</code></pre>
	</section>

	<!-- Argument validation -->
	<section class="demo">
		<div>
			<h3>Argument validation</h3>
			<p class="lead">Typos throw <code>WheelsBasecoat.InvalidArgument</code> with the allowed list — instead of silently rendering broken markup.</p>
		</div>
		<div class="preview" style="display:block">
			#uiAlert(
				title="uiButton(variant='primay')",
				description="WheelsBasecoat.InvalidArgument: uiButton() received an unsupported variant value: 'primay'. Allowed: primary,secondary,destructive,outline,ghost,link.",
				variant="destructive"
			)#
		</div>
		<pre><code>###uiButton(variant="primay")##  &lt;!-- throws --&gt;</code></pre>
	</section>

</div>

<!-- Toaster slot — drop-in target for client-rendered toasts. -->
#uiToaster()#
</cfoutput>
