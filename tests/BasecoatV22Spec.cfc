/**
 * v2.2 — coverage for the command palette family, the rich select combobox,
 * and the basecoatIncludes extras-CSS opt-in.
 */
component extends="wheels.WheelsTest" {

	function beforeAll() {
		variables.bc = createObject("component", "plugins.basecoat.Basecoat").init();
	}

	function run() {
		describe("v2.2 — basecoatIncludes extras CSS", () => {

			it("loads wheels-basecoat-extras.min.css by default", () => {
				var html = variables.bc.basecoatIncludes();
				expect(html).toMatch('href="/assets/basecoat/wheels-basecoat-extras\.min\.css"');
			});

			it("can be disabled via extrasCSS=false", () => {
				var html = variables.bc.basecoatIncludes(extrasCSS=false);
				expect(html).notToMatch("wheels-basecoat-extras");
			});

		});

		describe("v2.2 — Command palette family (command.js contract)", () => {

			it("uiCommand opens .command div", () => {
				expect(variables.bc.uiCommand()).toBe('<div class="command">');
			});

			it("uiCommandInput renders a header > input[type=text]", () => {
				var html = variables.bc.uiCommandInput(placeholder="Search…");
				expect(html).toMatch('<header><input type="text"');
				expect(html).toMatch('placeholder="Search…"');
				expect(html).toMatch('</header>');
			});

			it("uiCommandList opens role=menu (matches command.js's selector)", () => {
				expect(variables.bc.uiCommandList()).toBe('<div role="menu">');
			});

			it("uiCommandGroup opens role=group with aria-label", () => {
				expect(variables.bc.uiCommandGroup(label="Suggestions")).toBe('<div role="group" aria-label="Suggestions">');
			});

			it("uiCommandItem renders <button role=menuitem> when no href", () => {
				var html = variables.bc.uiCommandItem(text="Toggle theme");
				expect(html).toMatch('<button type="button" role="menuitem"');
				expect(html).toMatch('<span>Toggle theme</span>');
			});

			it("uiCommandItem renders <a role=menuitem> when href provided", () => {
				var html = variables.bc.uiCommandItem(text="Settings", href="/settings");
				expect(html).toMatch('<a href="/settings" role="menuitem"');
			});

			it("uiCommandItem(keywords=) emits data-keywords for the JS filter", () => {
				var html = variables.bc.uiCommandItem(text="Profile", keywords="account user");
				expect(html).toMatch('data-keywords="account user"');
			});

			it("uiCommandItem(force=true) emits data-force to bypass filtering", () => {
				var html = variables.bc.uiCommandItem(text="Help", force=true);
				expect(html).toMatch('data-force');
			});

			it("uiCommandItem(keepOpen=true) emits data-keep-command-open", () => {
				var html = variables.bc.uiCommandItem(text="Toggle theme", keepOpen=true);
				expect(html).toMatch('data-keep-command-open');
			});

			it("uiCommandItem(disabled=true) sets aria-disabled", () => {
				var html = variables.bc.uiCommandItem(text="Delete", disabled=true);
				expect(html).toMatch('aria-disabled="true"');
			});

			it("uiCommandItem(icon=, kbd=) renders both adornments", () => {
				var html = variables.bc.uiCommandItem(text="Search", icon="search", kbd="⌘K");
				expect(html).toMatch('<svg');                // icon
				expect(html).toMatch('<kbd class="kbd">⌘K</kbd>');
			});

			it("uiCommandSeparator emits hr role=separator", () => {
				expect(variables.bc.uiCommandSeparator()).toBe('<hr role="separator">');
			});

			it("uiCommandEmpty defaults to 'No results.' and is force-shown", () => {
				var html = variables.bc.uiCommandEmpty();
				expect(html).toMatch('class="command-empty"');
				expect(html).toMatch('data-force');
				expect(html).toMatch('>No results\.<');
			});

			it("uiCommandDialog wraps the palette in <dialog class='command-dialog'>", () => {
				var html = variables.bc.uiCommandDialog(triggerText="Open palette");
				// Trigger uses CSP-safe data-attr (no inline onclick).
				expect(html).toMatch('data-ui-dialog-open=');
				expect(html).notToMatch('onclick=');
				expect(html).toMatch('<dialog');
				expect(html).toMatch('class="dialog command-dialog"');
				expect(html).toMatch('aria-label="Command palette"');
			});

		});

		describe("v2.2 — uiSelect (select.js combobox)", () => {

			it("emits .select wrapper with data-placeholder", () => {
				var html = variables.bc.uiSelect(name="fruit", options="a:Apple,b:Banana", placeholder="Pick fruit");
				expect(html).toMatch('class="select"');
				expect(html).toMatch('data-placeholder="Pick fruit"');
			});

			it("renders trigger button + popover + listbox + hidden input — all four parts that select.js queries", () => {
				var html = variables.bc.uiSelect(name="fruit", options="a:Apple");
				expect(html).toMatch('<button type="button" aria-expanded="false"');
				expect(html).toMatch('aria-haspopup="listbox"');
				expect(html).toMatch('data-popover');
				expect(html).toMatch('aria-hidden="true"');
				expect(html).toMatch('role="listbox"');
				expect(html).toMatch('<input type="hidden"');
			});

			it("each option carries role=option + data-value + a unique id", () => {
				var html = variables.bc.uiSelect(name="fruit", options="a:Apple,b:Banana");
				expect(html).toMatch('role="option"');
				expect(html).toMatch('data-value="a"');
				expect(html).toMatch('data-value="b"');
				// The first option should get id ending in "-opt-1"
				expect(html).toMatch('-opt-1');
				expect(html).toMatch('-opt-2');
			});

			it("pre-renders the selected option's label in the trigger (no FOUC)", () => {
				var html = variables.bc.uiSelect(name="fruit", options="a:Apple,b:Banana", value="b");
				expect(html).toMatch('<span>Banana</span>');
				expect(html).toMatch('aria-selected="true"');
			});

			it("falls back to placeholder span when value is empty", () => {
				var html = variables.bc.uiSelect(name="fruit", options="a:Apple", placeholder="Choose…");
				expect(html).toMatch('<span class="text-muted-foreground">Choose…</span>');
			});

			it("renders the disabled flag from the third options segment", () => {
				var html = variables.bc.uiSelect(name="fruit", options="a:Apple,c:Coconut:disabled");
				expect(html).toMatch('data-value="c" aria-disabled="true"');
			});

			it("multiselect=true sets aria-multiselectable on the listbox", () => {
				var html = variables.bc.uiSelect(name="tags", options="a:Alpha,b:Beta", multiselect=true);
				expect(html).toMatch('aria-multiselectable="true"');
			});

			it("multiselect joins selected labels in the trigger", () => {
				var html = variables.bc.uiSelect(name="tags", options="a:Alpha,b:Beta,c:Gamma", multiselect=true, value='["a","c"]');
				expect(html).toMatch('<span>Alpha, Gamma</span>');
			});

			it("search=true renders the popover search input", () => {
				var html = variables.bc.uiSelect(name="x", options="a:A", search=true);
				expect(html).toMatch('<header><input type="text"');
				expect(html).toMatch('placeholder="Search\.\.\."');
			});

			it("closeOnSelect=true sets data-close-on-select", () => {
				var html = variables.bc.uiSelect(name="x", options="a:A", closeOnSelect=true);
				expect(html).toMatch('data-close-on-select="true"');
			});

		});

	}

}
