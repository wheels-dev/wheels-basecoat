/**
 * v2.1 — coverage for the reworked Tabs, Dropdown, and Sidebar helpers.
 * The pre-2.1 markup didn't match basecoat-css 0.3.x's selectors and
 * basecoat-js's expected contract; these assertions guard the new shape.
 */
component extends="wheels.WheelsTest" {

	function beforeAll() {
		variables.bc = createObject("component", "plugins.basecoat.Basecoat").init();
	}

	function run() {
		describe("v2.1 — Tabs (ARIA + tabs.js contract)", () => {

			it("uiTabs opens a .tabs container", () => {
				var html = variables.bc.uiTabs(defaultTab="overview");
				expect(html).toMatch('class="tabs"');
				// uiTabsEnd cleans up the request-scope context.
				variables.bc.uiTabsEnd();
			});

			it("uiTabList carries role=tablist + aria-label", () => {
				expect(variables.bc.uiTabList()).toMatch('role="tablist"');
				expect(variables.bc.uiTabList()).toMatch('aria-label="Tabs"');
			});

			it("uiTabTrigger marks the matching defaultTab as selected", () => {
				variables.bc.uiTabs(defaultTab="overview");
				var html = variables.bc.uiTabTrigger(value="overview", text="Overview");
				expect(html).toMatch('role="tab"');
				expect(html).toMatch('aria-selected="true"');
				expect(html).toMatch('tabindex="0"');
				variables.bc.uiTabsEnd();
			});

			it("uiTabTrigger marks non-matching values as inactive", () => {
				variables.bc.uiTabs(defaultTab="overview");
				var html = variables.bc.uiTabTrigger(value="details", text="Details");
				expect(html).toMatch('aria-selected="false"');
				expect(html).toMatch('tabindex="-1"');
				variables.bc.uiTabsEnd();
			});

			it("trigger and content auto-pair via aria-controls / aria-labelledby", () => {
				variables.bc.uiTabs(defaultTab="overview", id="ex");
				var trig = variables.bc.uiTabTrigger(value="overview", text="Overview");
				var ctnt = variables.bc.uiTabContent(value="overview");
				// IDs use the tabs id ("ex") + the value: tab id "ex-tab-overview", panel id "ex-panel-overview"
				expect(trig).toMatch('id="ex-tab-overview"');
				expect(trig).toMatch('aria-controls="ex-panel-overview"');
				expect(ctnt).toMatch('id="ex-panel-overview"');
				expect(ctnt).toMatch('aria-labelledby="ex-tab-overview"');
				variables.bc.uiTabsEnd();
			});

			it("inactive tabpanels carry the hidden attribute (tabs.js shows/hides via this)", () => {
				variables.bc.uiTabs(defaultTab="overview");
				var active = variables.bc.uiTabContent(value="overview");
				var inactive = variables.bc.uiTabContent(value="details");
				expect(active).notToMatch(' hidden');
				expect(inactive).toMatch(' hidden');
				variables.bc.uiTabsEnd();
			});

		});

		describe("v2.1 — Dropdown (.dropdown-menu + popover JS)", () => {

			it("uiDropdown emits the .dropdown-menu wrapper + trigger + popover content + role=menu", () => {
				var html = variables.bc.uiDropdown(text="Actions");
				expect(html).toMatch('class="dropdown-menu"');
				expect(html).toMatch('aria-expanded="false"');
				expect(html).toMatch('aria-haspopup="menu"');
				expect(html).toMatch('data-popover');
				expect(html).toMatch('aria-hidden="true"');
				expect(html).toMatch('role="menu"');
			});

			it("uiDropdownItem renders an <a role=menuitem> when href provided", () => {
				var html = variables.bc.uiDropdownItem(text="Edit", href="/edit");
				expect(html).toMatch('<a role="menuitem"');
				expect(html).toMatch('href="/edit"');
			});

			it("uiDropdownItem renders a <button role=menuitem> when href omitted", () => {
				var html = variables.bc.uiDropdownItem(text="Sign out");
				expect(html).toMatch('<button type="button" role="menuitem"');
			});

			it("uiDropdownItem(disabled=true) sets aria-disabled", () => {
				var html = variables.bc.uiDropdownItem(text="Locked", disabled=true);
				expect(html).toMatch('aria-disabled="true"');
			});

			it("uiDropdownSeparator emits hr role=separator (not the old <li><hr/></li>)", () => {
				expect(variables.bc.uiDropdownSeparator()).toBe('<hr role="separator">');
			});

			it("uiDropdownEnd closes all three wrappers", () => {
				expect(variables.bc.uiDropdownEnd()).toBe('</div></div></div>');
			});

		});

		describe("v2.1 — Sidebar (semantic nav + sidebar.js contract)", () => {

			it("uiSidebar emits aside.sidebar with data-side", () => {
				var html = variables.bc.uiSidebar();
				expect(html).toMatch('<aside class="sidebar"');
				expect(html).toMatch('data-side="left"');
				expect(html).toMatch('<nav>');
			});

			it("uiSidebar(side='right') reflects the data-side", () => {
				expect(variables.bc.uiSidebar(side="right")).toMatch('data-side="right"');
			});

			it("uiSidebar(initialOpen=false) opts out of default-open", () => {
				expect(variables.bc.uiSidebar(initialOpen=false)).toMatch('data-initial-open="false"');
			});

			it("uiSidebar(side='diagonal') throws for unknown side", () => {
				expect(() => variables.bc.uiSidebar(side="diagonal"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("uiSidebarHeader / uiSidebarBody / uiSidebarFooter emit semantic elements", () => {
				expect(variables.bc.uiSidebarHeader()).toBe('<header>');
				expect(variables.bc.uiSidebarBody()).toBe('<section>');
				expect(variables.bc.uiSidebarFooter()).toBe('<footer>');
			});

			it("uiSidebarGroup emits div role=group with optional h3 title", () => {
				var html = variables.bc.uiSidebarGroup(title="Workspace");
				expect(html).toMatch('role="group"');
				expect(html).toMatch('<h3>Workspace</h3>');
			});

			it("uiSidebarItem(active=true) sets aria-current=page", () => {
				var html = variables.bc.uiSidebarItem(text="Posts", href="/posts", active=true);
				expect(html).toMatch('aria-current="page"');
				expect(html).toMatch('href="/posts"');
				expect(html).toMatch('>Posts</a>');
			});

			it("uiSidebarItem renders an icon when provided", () => {
				var html = variables.bc.uiSidebarItem(text="Home", icon="home");
				expect(html).toMatch('<svg');
			});

			it("uiSidebarSeparator emits hr role=separator", () => {
				expect(variables.bc.uiSidebarSeparator()).toBe('<hr role="separator">');
			});

			it("uiSidebarToggle emits delegated data-attr (no inline onclick)", () => {
				var html = variables.bc.uiSidebarToggle();
				expect(html).toMatch('data-ui-sidebar-toggle="toggle"');
				expect(html).notToMatch('onclick=');
			});

			it("uiSidebarToggle(action='close', sidebarId='nav') passes through", () => {
				var html = variables.bc.uiSidebarToggle(action="close", sidebarId="nav");
				expect(html).toMatch('data-ui-sidebar-toggle="close"');
				expect(html).toMatch('data-ui-sidebar-target="nav"');
			});

		});

	}

}
