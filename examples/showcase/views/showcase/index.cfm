<!---
	wheels-basecoat live showcase view.
	Every helper rendered with a real call. Drop the controller + this view
	into your app and visit the mounted URL (recommend /basecoat-showcase).
--->
<cfoutput>
<style>
	.bcs-page { max-width: 76rem; margin: 0 auto; padding: 1.5rem 1rem 6rem; }
	.bcs-hero { padding: 1.5rem 0; display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
	.bcs-hero h1 { font-size: 2rem; font-weight: 700; letter-spacing: -.02em; margin: 0; }
	.bcs-hero p { margin: .25rem 0 0; color: var(--color-muted-foreground); }
	.bcs-grid { display: grid; grid-template-columns: 1fr; gap: 1.25rem; }
	@media (min-width: 1024px) { .bcs-grid { grid-template-columns: repeat(2, 1fr); } }
	.bcs-section { padding: 1.25rem; border: 1px solid var(--color-border); border-radius: .75rem; display: flex; flex-direction: column; gap: 1rem; background: var(--color-card); }
	.bcs-section h3 { font-weight: 600; font-size: 1rem; margin: 0; }
	.bcs-section p.lead { font-size: .85rem; color: var(--color-muted-foreground); margin: .25rem 0 0; }
	.bcs-preview { padding: 1rem; border: 1px dashed var(--color-border); border-radius: .5rem; background: var(--color-background); display: flex; flex-direction: column; gap: .75rem; align-items: flex-start; min-height: 4rem; }
	.bcs-preview.row { flex-direction: row; flex-wrap: wrap; align-items: center; }
</style>

<div class="bcs-page">
	<header class="bcs-hero">
		<div>
			<h1>wheels-basecoat showcase</h1>
			<p>Every helper rendered live. Source in your repo: <code>vendor/wheels-basecoat/Basecoat.cfc</code>.</p>
		</div>
		<div style="display:flex;gap:.5rem;align-items:center">
			#uiBadge(text="basecoat-css 0.3.x", variant="secondary")#
			#uiThemeToggle()#
		</div>
	</header>

	<div class="bcs-grid">

		<!-- Buttons -->
		<section class="bcs-section">
			<div><h3>Buttons</h3><p class="lead">Six variants × three sizes × optional icon.</p></div>
			<div class="bcs-preview row">
				#uiButton(text="Primary")#
				#uiButton(text="Secondary", variant="secondary")#
				#uiButton(text="Outline", variant="outline")#
				#uiButton(text="Ghost", variant="ghost")#
				#uiButton(text="Destructive", variant="destructive", icon="trash")#
				#uiButton(text="Link", variant="link")#
			</div>
			<div class="bcs-preview row">
				#uiButton(text="Small", size="sm")#
				#uiButton(text="Medium")#
				#uiButton(text="Large", size="lg")#
				#uiButton(icon="plus", ariaLabel="Add")#
				#uiButton(icon="trash", ariaLabel="Delete", variant="destructive", size="sm")#
			</div>
		</section>

		<!-- Badges + Avatar + Kbd -->
		<section class="bcs-section">
			<div><h3>Badges, avatar, kbd</h3><p class="lead">Inline labels, image+initial avatar, keyboard hints.</p></div>
			<div class="bcs-preview row">
				#uiBadge(text="Default")#
				#uiBadge(text="Secondary", variant="secondary")#
				#uiBadge(text="Outline", variant="outline")#
				#uiBadge(text="Destructive", variant="destructive")#
			</div>
			<div class="bcs-preview row">
				#uiAvatar(text="AB", alt="Ada B")#
				#uiAvatar(text="MK", alt="Marie K", size=32)#
				<span>Press #uiKbd(text="⌘K")# to search</span>
			</div>
		</section>

		<!-- Card -->
		<section class="bcs-section">
			<div><h3>Card</h3><p class="lead">Semantic header / section / footer.</p></div>
			<div class="bcs-preview" style="display:block">
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
		</section>

		<!-- Alert + Callout -->
		<section class="bcs-section">
			<div><h3>Alert &amp; callout</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiAlert(title="Heads up", description="Your trial ends in 3 days.")#
				<div style="height: .5rem"></div>
				#uiAlert(title="Couldn't save", description="Title is required.", variant="destructive")#
				<div style="height: .5rem"></div>
				#uiCallout(title="Pro tip", body="Use ##uiBoundField## with a Wheels model to skip 80% of form boilerplate.", variant="tip")#
			</div>
		</section>

		<!-- Forms -->
		<section class="bcs-section">
			<div><h3>Form fields</h3><p class="lead">uiField for ad-hoc, uiBoundField for Wheels-bound.</p></div>
			<div class="bcs-preview" style="display:block">
				#uiField(label="Email", name="email", type="email", placeholder="you@example.com", required=true, description="We'll never share your email.")#
				<div style="height: .75rem"></div>
				#uiField(label="Plan", name="plan", type="select", options="free:Free,pro:Pro,team:Team")#
				<div style="height: .75rem"></div>
				#uiField(label="Bio", name="bio", type="textarea", rows=3, errorMessage="Please tell us a bit about yourself.")#
			</div>
		</section>

		<!-- Bound form (uses demoPost) -->
		<section class="bcs-section">
			<div><h3>uiBoundField</h3><p class="lead">Wheels-bound: name + value + label + error all auto-resolved.</p></div>
			<div class="bcs-preview" style="display:block">
				#uiBoundField(objectName="demoPost", property="title")#
				<div style="height: .75rem"></div>
				#uiBoundField(objectName="demoPost", property="body", type="textarea", rows=3)#
				<div style="height: .75rem"></div>
				#uiBoundField(objectName="demoPost", property="status", type="select",
					options="draft:Draft,published:Published,archived:Archived")#
			</div>
		</section>

		<!-- Slider + Rating -->
		<section class="bcs-section">
			<div><h3>Slider &amp; rating</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiSlider(name="volume", value=64, label="Volume", showValue=true)#
				<div style="height: 1rem"></div>
				#uiRating(value=4)#
				<div style="height: .5rem"></div>
				#uiRating(value=3, name="post[rating]")#
			</div>
		</section>

		<!-- Bound checkbox / group / radio -->
		<section class="bcs-section">
			<div><h3>Bound checkbox / group / radio</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiBoundCheckbox(objectName="demoPost", property="featured", switch=true,
					description="Featured posts appear at the top of the index.")#
				<div style="height: 1rem"></div>
				#uiBoundCheckboxGroup(objectName="demoPost", property="tags",
					options="design:Design,eng:Engineering,ops:Ops",
					legend="Tags", inline=true)#
				<div style="height: 1rem"></div>
				#uiBoundRadioGroup(objectName="demoPost", property="status",
					options="draft:Draft,published:Published,archived:Archived",
					legend="Status", inline=true)#
			</div>
		</section>

		<!-- Error summary -->
		<section class="bcs-section">
			<div><h3>Error summary</h3><p class="lead">Drop-in for errorMessagesFor(); reads model.allErrors().</p></div>
			<div class="bcs-preview" style="display:block">
				#uiErrorSummary(demoErroredPost)#
			</div>
		</section>

		<!-- Tabs -->
		<section class="bcs-section">
			<div><h3>Tabs</h3><p class="lead">ARIA-driven; keyboard navigable.</p></div>
			<div class="bcs-preview" style="display:block">
				#uiTabs(defaultTab="overview", id="bcs-tabs")#
					#uiTabList()#
						#uiTabTrigger(value="overview", text="Overview")#
						#uiTabTrigger(value="activity", text="Activity")#
						#uiTabTrigger(value="settings", text="Settings")#
					#uiTabListEnd()#
					#uiTabContent(value="overview")#<p>High-level stats.</p>#uiTabContentEnd()#
					#uiTabContent(value="activity")#<p>Timeline of events.</p>#uiTabContentEnd()#
					#uiTabContent(value="settings")#<p>Workspace name, timezone, etc.</p>#uiTabContentEnd()#
				#uiTabsEnd()#
			</div>
		</section>

		<!-- Dropdown + Popover -->
		<section class="bcs-section">
			<div><h3>Dropdown &amp; popover</h3></div>
			<div class="bcs-preview row">
				#uiDropdown(text="Actions")#
					#uiDropdownItem(text="Edit", href="##")#
					#uiDropdownItem(text="Duplicate", href="##")#
					#uiDropdownSeparator()#
					#uiDropdownItem(text="Delete", class="text-destructive")#
				#uiDropdownEnd()#

				#uiPopover()#
					#uiPopoverTrigger(text="Filters")#
					#uiPopoverContent()#
						<p style="margin:0;font-size:.875rem">Status, date range, author.</p>
					#uiPopoverContentEnd()#
				#uiPopoverEnd()#
			</div>
		</section>

		<!-- Dialog -->
		<section class="bcs-section">
			<div><h3>Dialog</h3><p class="lead">Native &lt;dialog&gt; with CSP-safe open/close.</p></div>
			<div class="bcs-preview">
				#uiDialog(title="Delete post?",
					description="This will permanently delete the post and all its comments.",
					triggerText="Delete post", triggerClass="btn-destructive")#
					<p>Are you sure?</p>
				#uiDialogFooter()#
					#uiButton(text="Cancel", variant="ghost", close=true)#
					#uiButton(text="Yes, delete", variant="destructive")#
				#uiDialogEnd()#
			</div>
		</section>

		<!-- Steps -->
		<section class="bcs-section">
			<div><h3>Steps</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiSteps()#
					#uiStep(text="Account", status="complete")#
					#uiStep(text="Profile", status="current")#
					#uiStep(text="Plan", status="upcoming")#
					#uiStep(text="Confirm", status="upcoming")#
				#uiStepsEnd()#
			</div>
		</section>

		<!-- Empty state -->
		<section class="bcs-section">
			<div><h3>Empty state</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiEmptyState(icon="info", title="No posts yet",
					description="Be the first to publish.",
					actionText="Write the first post", actionHref="##")#
			</div>
		</section>

		<!-- Accordion + Timeline + Code block -->
		<section class="bcs-section">
			<div><h3>Accordion, timeline, code block</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiAccordion()#
					#uiAccordionItem(title="What is this?", open=true)#
						<p>A live showcase of every helper.</p>
					#uiAccordionItemEnd()#
					#uiAccordionItem(title="Where's the source?")#
						<p>Drop these files into your app — see <code>examples/showcase/README.md</code>.</p>
					#uiAccordionItemEnd()#
				#uiAccordionEnd()#
				<div style="height: 1rem"></div>
				#uiTimeline()#
					#uiTimelineItem(title="Post published", time="2:14 PM", icon="check-circle", description="Hello world is now live.")#
					#uiTimelineItem(title="Comment added", time="2:42 PM", icon="send", description="Diana: Basecoat looks good.")#
					#uiTimelineItem(title="Post edited", time="3:01 PM", icon="pencil")#
				#uiTimelineEnd()#
				<div style="height: 1rem"></div>
				#uiCodeBlock(content='#chr(35)#uiBoundField(objectName="post", property="title", required=true)#chr(35)#', language="cfml", filename="_form.cfm")#
			</div>
		</section>

		<!-- Tag input + File upload + Date picker -->
		<section class="bcs-section">
			<div><h3>Tag input, file upload, date picker</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiTagInput(name="tags", value="design,ops", suggestions="design,engineering,marketing,ops,sales", label="Tags")#
				<div style="height: 1rem"></div>
				#uiFileUpload(name="cover", accept="image/*", label="Cover image", description="PNG, JPG up to 4MB.")#
				<div style="height: 1rem"></div>
				#uiDatePicker(name="publishedAt", label="Published at")#
			</div>
		</section>

		<!-- Pagination + Breadcrumb + Toast (live) -->
		<section class="bcs-section">
			<div><h3>Breadcrumb &amp; pagination</h3></div>
			<div class="bcs-preview" style="display:block">
				#uiBreadcrumb()#
					#uiBreadcrumbItem(text="Home", href="##")#
					#uiBreadcrumbSeparator()#
					#uiBreadcrumbItem(text="Posts", href="##")#
					#uiBreadcrumbSeparator()#
					#uiBreadcrumbItem(text="Hello world")#
				#uiBreadcrumbEnd()#
				<div style="height: 1rem"></div>
				#uiPagination(currentPage=3, totalPages=12, baseUrl="##posts")#
			</div>
		</section>

		<!-- Toaster -->
		<section class="bcs-section">
			<div><h3>Toaster (server-rendered)</h3></div>
			<div class="bcs-preview" style="display:block">
				<div class="toaster" style="position:relative;inset:auto;padding:0;background:transparent;">
					#uiToast(title="Saved", description="Your post is live.", variant="success")#
					<div style="height:.5rem"></div>
					#uiToast(title="Heads up", description="Your trial ends in 3 days.", variant="warning")#
					<div style="height:.5rem"></div>
					#uiToast(title="Couldn't reach the server", variant="error")#
				</div>
			</div>
		</section>

	</div>
</div>

<!-- Live toaster slot -->
#uiToaster()#
</cfoutput>
