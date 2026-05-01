/**
 * v2.4 — coverage for the bound collection form helpers (single bound
 * checkbox, multi-checkbox group + bound, radio group + bound), the
 * model error summary helper, and the star-rating widget.
 */
component extends="wheels.WheelsTest" {

	function beforeAll() {
		variables.bc = createObject("component", "plugins.basecoat.Basecoat").init();
	}

	function run() {
		describe("v2.4 — uiBoundCheckbox", () => {

			it("emits the falsy-companion hidden input + the checkbox itself", () => {
				variables.user = { admin: false };
				var html = variables.bc.uiBoundCheckbox(objectName="user", property="admin");
				// Both inputs share the same name. Browser submits in order;
				// controllers see the later (checkbox) value when checked.
				expect(html).toMatch('<input type="hidden" name="user\[admin\]" value="0">');
				expect(html).toMatch('<input type="checkbox"');
				expect(html).toMatch('name="user\[admin\]" value="1"');
				expect(html).notToMatch('checked');
			});

			it("renders checked when the model value is truthy", () => {
				variables.user = { admin: true };
				var html = variables.bc.uiBoundCheckbox(objectName="user", property="admin");
				expect(html).toMatch('checked');
			});

			it("supports switch=true to render as a basecoat .switch", () => {
				variables.user = { dark_mode: true };
				var html = variables.bc.uiBoundCheckbox(objectName="user", property="dark_mode", switch=true);
				expect(html).toMatch('class="switch"');
				expect(html).toMatch('role="switch"');
			});

			it("humanizes the property into the label by default", () => {
				variables.user = { dark_mode: true };
				var html = variables.bc.uiBoundCheckbox(objectName="user", property="dark_mode");
				expect(html).toMatch('>Dark mode</label>');
			});

			it("throws when the named object isn't in scope", () => {
				expect(() => variables.bc.uiBoundCheckbox(objectName="ghost", property="x"))
					.toThrow(type="WheelsBasecoat.ObjectNotFound");
			});

		});

		describe("v2.4 — uiCheckboxGroup", () => {

			it("renders inputs with name='<name>[]' so Wheels arrays them", () => {
				var html = variables.bc.uiCheckboxGroup(name="tags", options="a:Alpha,b:Beta");
				expect(html).toMatch('name="tags\[\]"');
			});

			it("checks options whose value matches the comma-separated value arg", () => {
				var html = variables.bc.uiCheckboxGroup(name="tags", options="a:Alpha,b:Beta,c:Gamma", value="a,c");
				// 'Alpha' should be checked, 'Beta' not, 'Gamma' checked.
				expect(html).toMatch('value="a" class="checkbox" checked');
				expect(html).toMatch('value="c" class="checkbox" checked');
				// Beta should NOT have ' checked'
				expect(html).notToMatch('value="b"[^/]*\schecked');
			});

			it("accepts a real CFML array as the value", () => {
				var html = variables.bc.uiCheckboxGroup(name="tags", options="a:Alpha,b:Beta", value=["b"]);
				expect(html).toMatch('value="b" class="checkbox" checked');
			});

			it("accepts a JSON-array string as the value", () => {
				var html = variables.bc.uiCheckboxGroup(name="tags", options="a:Alpha,b:Beta", value='["a","b"]');
				expect(html).toMatch('value="a" class="checkbox" checked');
				expect(html).toMatch('value="b" class="checkbox" checked');
			});

			it("respects the disabled flag in the third options segment", () => {
				var html = variables.bc.uiCheckboxGroup(name="tags", options="a:A,b:B:disabled");
				expect(html).toMatch('value="b" class="checkbox" disabled');
			});

		});

		describe("v2.4 — uiBoundCheckboxGroup", () => {

			it("auto-resolves an array property on the model", () => {
				variables.post = { tags: ["a", "c"] };
				var html = variables.bc.uiBoundCheckboxGroup(
					objectName="post", property="tags",
					options="a:Alpha,b:Beta,c:Gamma"
				);
				expect(html).toMatch('name="post\[tags\]\[\]"');
				expect(html).toMatch('value="a" class="checkbox" checked');
				expect(html).toMatch('value="c" class="checkbox" checked');
			});

			it("falls back to humanized property as legend", () => {
				variables.post = { selected_tags: [] };
				var html = variables.bc.uiBoundCheckboxGroup(
					objectName="post", property="selected_tags",
					options="a:A"
				);
				expect(html).toMatch('<legend>Selected tags</legend>');
			});

		});

		describe("v2.4 — uiRadioGroup", () => {

			it("renders inputs with role=radiogroup and a single name", () => {
				var html = variables.bc.uiRadioGroup(name="plan", options="free:Free,pro:Pro");
				expect(html).toMatch('role="radiogroup"');
				expect(html).toMatch('name="plan"');
				expect(html).toMatch('value="free"');
				expect(html).toMatch('value="pro"');
			});

			it("checks the matching value option", () => {
				var html = variables.bc.uiRadioGroup(name="plan", options="free:Free,pro:Pro", value="pro");
				expect(html).toMatch('value="pro" class="radio" checked');
				expect(html).notToMatch('value="free"[^/]*\schecked');
			});

			it("respects disabled flag on options", () => {
				var html = variables.bc.uiRadioGroup(name="plan", options="free:Free,vip:VIP:disabled");
				expect(html).toMatch('value="vip" class="radio" disabled');
			});

		});

		describe("v2.4 — uiBoundRadioGroup", () => {

			it("auto-resolves the value from the model", () => {
				variables.post = { status: "published" };
				var html = variables.bc.uiBoundRadioGroup(
					objectName="post", property="status",
					options="draft:Draft,published:Published"
				);
				expect(html).toMatch('name="post\[status\]"');
				expect(html).toMatch('value="published" class="radio" checked');
			});

			it("throws when the named object isn't in scope", () => {
				expect(() => variables.bc.uiBoundRadioGroup(objectName="ghost", property="x", options="a:A"))
					.toThrow(type="WheelsBasecoat.ObjectNotFound");
			});

		});

		describe("v2.4 — uiErrorSummary", () => {

			// A minimal stand-in for a Wheels model — has the methods we call.
			function makeModel(boolean hasErr, array errs = []) {
				var m = {};
				m.hasErrors = function() { return arguments.hasErr; };
				m.allErrors = function() { return arguments.errs; };
				return m;
			}

			it("returns empty string when the model has no errors", () => {
				var m = makeModel(false, []);
				expect(variables.bc.uiErrorSummary(model=m)).toBe("");
			});

			it("renders a destructive alert with each error in an <li>", () => {
				var m = makeModel(true, [
					{ property: "title", message: "can't be empty" },
					{ property: "body",  message: "is too short" }
				]);
				var html = variables.bc.uiErrorSummary(model=m);
				expect(html).toMatch('class="alert alert-destructive"');
				expect(html).toMatch('Couldn''t save — 2 errors');
				expect(html).toMatch('<strong>Title</strong> can''t be empty');
				expect(html).toMatch('<strong>Body</strong> is too short');
			});

			it("uses singular 'error' wording for a single failure", () => {
				var m = makeModel(true, [{ property: "title", message: "is required" }]);
				var html = variables.bc.uiErrorSummary(model=m);
				expect(html).toMatch('Couldn''t save — 1 error');
			});

			it("falls back gracefully when the model lacks the methods", () => {
				expect(variables.bc.uiErrorSummary(model={})).toBe("");
			});

		});

		describe("v2.4 — uiRating", () => {

			it("read-only mode highlights filled stars up to value", () => {
				var html = variables.bc.uiRating(value=3, max=5);
				expect(html).toMatch('data-rating="3"');
				// Three is-filled stars then two without
				var matches = reMatch('is-filled', html);
				expect(arrayLen(matches)).toBe(3);
			});

			it("interactive mode emits a fieldset with N radio inputs", () => {
				var html = variables.bc.uiRating(value=4, max=5, name="post[rating]");
				expect(html).toMatch('<fieldset class="ui-rating"');
				expect(html).toMatch('role="radiogroup"');
				// Five radios, one checked at 4
				expect(arrayLen(reMatch('type="radio"', html))).toBe(5);
				expect(html).toMatch('value="4"\s+checked');
			});

			it("interactive mode renders highest-first so CSS sibling combinator can light earlier stars", () => {
				var html = variables.bc.uiRating(value=2, max=3, name="r");
				// First radio in the rendered output should be value="3", then 2, then 1.
				var first = reFind('value="(\d+)"', html, 1, true);
				expect(first.match[2]).toBe("3");
			});

		});

	}

}
