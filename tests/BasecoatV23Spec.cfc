/**
 * v2.3 — coverage for the slider, steps progress indicator, and the
 * Wheels-bound select/slider helpers.
 */
component extends="wheels.WheelsTest" {

	function beforeAll() {
		variables.bc = createObject("component", "plugins.basecoat.Basecoat").init();
	}

	function run() {
		describe("v2.3 — uiSlider", () => {

			it("emits input[type=range] with min/max/step + value attrs", () => {
				var html = variables.bc.uiSlider(name="vol", value=42, min=0, max=100);
				expect(html).toMatch('type="range"');
				expect(html).toMatch('name="vol"');
				expect(html).toMatch('min="0"');
				expect(html).toMatch('max="100"');
				expect(html).toMatch('value="42"');
			});

			it("computes --slider-value percentage from value/min/max", () => {
				var html = variables.bc.uiSlider(name="x", value=25, min=0, max=100);
				expect(html).toMatch('--slider-value: 25%');
			});

			it("clamps the percentage when value falls outside min/max", () => {
				var html = variables.bc.uiSlider(name="x", value=999, min=0, max=100);
				expect(html).toMatch('--slider-value: 100%');
			});

			it("defaults the value to halfway when not provided", () => {
				var html = variables.bc.uiSlider(name="x", min=0, max=10);
				expect(html).toMatch('value="5"');
			});

			it("renders the optional output mirror with data-ui-slider-output", () => {
				var html = variables.bc.uiSlider(name="x", value=33, showValue=true);
				expect(html).toMatch('<output for=');
				expect(html).toMatch('data-ui-slider-output');
				expect(html).toMatch('>33</output>');
			});

			it("renders an optional label", () => {
				var html = variables.bc.uiSlider(name="x", label="Volume");
				expect(html).toMatch('<label for=');
				expect(html).toMatch('>Volume</label>');
			});

			it("emits aria-valuemin/max/now for assistive tech", () => {
				var html = variables.bc.uiSlider(name="x", value=12, min=10, max=20);
				expect(html).toMatch('aria-valuemin="10"');
				expect(html).toMatch('aria-valuemax="20"');
				expect(html).toMatch('aria-valuenow="12"');
			});

		});

		describe("v2.3 — uiSteps + uiStep", () => {

			it("uiSteps wraps an <ol class='ui-steps'> in a labeled nav", () => {
				expect(variables.bc.uiSteps()).toMatch('<nav aria-label="Progress"><ol class="ui-steps">');
			});

			it("uiStep emits data-status + ARIA based on status", () => {
				variables.bc.uiSteps();  // initialize counter
				var current = variables.bc.uiStep(text="Account", status="current");
				expect(current).toMatch('data-status="current"');
				expect(current).toMatch('aria-current="step"');
				variables.bc.uiStepsEnd();
			});

			it("complete steps render a check icon in place of the number", () => {
				variables.bc.uiSteps();
				var done = variables.bc.uiStep(text="Welcome", status="complete");
				expect(done).toMatch('data-status="complete"');
				expect(done).toMatch('<svg');
				variables.bc.uiStepsEnd();
			});

			it("auto-numbers steps when number arg omitted", () => {
				variables.bc.uiSteps();
				var first = variables.bc.uiStep(text="A");
				var second = variables.bc.uiStep(text="B");
				expect(first).toMatch('>1</span>');
				expect(second).toMatch('>2</span>');
				variables.bc.uiStepsEnd();
			});

			it("uiStep rejects unknown status", () => {
				expect(() => variables.bc.uiStep(text="x", status="bogus"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("complete + non-current step with href wraps content in a link", () => {
				variables.bc.uiSteps();
				var html = variables.bc.uiStep(text="Done", status="complete", href="/back");
				expect(html).toMatch('<a href="/back" class="ui-step-link">');
				variables.bc.uiStepsEnd();
			});

			it("current step does NOT wrap in a link even with href", () => {
				variables.bc.uiSteps();
				var html = variables.bc.uiStep(text="Now", status="current", href="/x");
				expect(html).notToMatch('<a href');
				variables.bc.uiStepsEnd();
			});

		});

		describe("v2.3 — uiBoundSelect", () => {

			it("auto-resolves value from the named object", () => {
				variables.post = { status: "published" };
				var html = variables.bc.uiBoundSelect(
					objectName="post", property="status",
					options="draft:Draft,published:Published"
				);
				// Pre-rendered trigger label reflects the bound value.
				expect(html).toMatch('<span>Published</span>');
				expect(html).toMatch('aria-selected="true"');
				expect(html).toMatch('name="post\[status\]"');
			});

			it("handles a multiselect array on the model", () => {
				variables.post = { tags: ["a", "c"] };
				var html = variables.bc.uiBoundSelect(
					objectName="post", property="tags",
					options="a:Alpha,b:Beta,c:Gamma",
					multiselect=true
				);
				// Trigger label is the comma-joined labels of selected items.
				expect(html).toMatch('<span>Alpha, Gamma</span>');
				expect(html).toMatch('aria-multiselectable="true"');
			});

			it("throws when the named object isn't in scope", () => {
				expect(() => variables.bc.uiBoundSelect(objectName="ghost", property="x", options="a:A"))
					.toThrow(type="WheelsBasecoat.ObjectNotFound");
			});

		});

		describe("v2.3 — uiBoundSlider", () => {

			it("resolves the value from the model + emits the bound name", () => {
				variables.profile = { volume: 73 };
				var html = variables.bc.uiBoundSlider(objectName="profile", property="volume", min=0, max=100);
				expect(html).toMatch('value="73"');
				expect(html).toMatch('name="profile\[volume\]"');
			});

			it("auto-derives label from the property name", () => {
				variables.profile = { volume: 50 };
				var html = variables.bc.uiBoundSlider(objectName="profile", property="volume");
				expect(html).toMatch('>Volume</label>');
			});

			it("throws when the named object isn't in scope", () => {
				expect(() => variables.bc.uiBoundSlider(objectName="ghost", property="x"))
					.toThrow(type="WheelsBasecoat.ObjectNotFound");
			});

		});

	}

}
