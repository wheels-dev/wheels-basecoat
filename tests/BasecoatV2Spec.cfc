/**
 * Coverage for the v2.0 additions: arg validation, uiBoundField, toast/popover/
 * avatar/kbd/button-group/fieldset/theme-toggle, and the Turbo Stream helpers.
 *
 * Tests assert the canonical rendered output for each helper. Any markup
 * change should require a test update in this file — that's the point.
 */
component extends="wheels.WheelsTest" {

	function beforeAll() {
		variables.bc = createObject("component", "plugins.basecoat.Basecoat").init();
	}

	function run() {
		describe("Basecoat v2 — arg validation", () => {

			it("uiButton rejects unknown variant", () => {
				expect(() => variables.bc.uiButton(text="x", variant="bogus"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("uiButton rejects unknown size", () => {
				expect(() => variables.bc.uiButton(text="x", size="huge"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("uiBadge rejects unknown variant", () => {
				expect(() => variables.bc.uiBadge(text="x", variant="primary"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("uiAlert rejects unknown variant", () => {
				expect(() => variables.bc.uiAlert(title="x", variant="warning"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("uiField rejects unknown type", () => {
				expect(() => variables.bc.uiField(label="x", name="y", type="bogus"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("uiToast rejects unknown variant", () => {
				expect(() => variables.bc.uiToast(title="x", variant="default"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("turboStream rejects unknown action", () => {
				expect(() => variables.bc.turboStream(action="explode"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

			it("uiButtonGroup rejects unknown orientation", () => {
				expect(() => variables.bc.uiButtonGroup(orientation="diagonal"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

		});

		describe("Basecoat v2 — uiBoundField", () => {

			it("auto-derives label from camelCase property", () => {
				// Plain struct stand-in — uiBoundField tolerates non-Wheels objects
				// for the value lookup but skips error resolution.
				variables.post = { title: "Hello" };
				var html = variables.bc.uiBoundField(objectName="post", property="title");
				expect(html).toMatch('>Title<');
				expect(html).toMatch('value="Hello"');
				expect(html).toMatch('name="post\[title\]"');
			});

			it("humanizes snake_case property", () => {
				variables.user = { first_name: "Ada" };
				var html = variables.bc.uiBoundField(objectName="user", property="first_name");
				expect(html).toMatch('>First name<');
			});

			it("respects explicit label override", () => {
				variables.post = { title: "" };
				var html = variables.bc.uiBoundField(objectName="post", property="title", label="Headline");
				expect(html).toMatch('>Headline<');
			});

			it("renders the textarea variant", () => {
				variables.post = { body: "Lorem" };
				var html = variables.bc.uiBoundField(objectName="post", property="body", type="textarea", rows=8);
				expect(html).toMatch('<textarea');
				expect(html).toMatch('rows="8"');
				expect(html).toMatch('>Lorem</textarea>');
			});

			it("renders the select variant with options", () => {
				variables.post = { status: "published" };
				var html = variables.bc.uiBoundField(
					objectName="post", property="status", type="select",
					options="draft:Draft,published:Published"
				);
				expect(html).toMatch('<select');
				expect(html).toMatch('value="published" selected');
			});

			it("throws a clear error when the named object is missing from scope", () => {
				expect(() => variables.bc.uiBoundField(objectName="ghost", property="x"))
					.toThrow(type="WheelsBasecoat.ObjectNotFound");
			});

		});

		describe("Basecoat v2 — uiToast / uiToaster / basecoatFlashToasts", () => {

			it("uiToaster renders a #toaster live region", () => {
				expect(variables.bc.uiToaster()).toBe('<div id="toaster" class="toaster" aria-live="polite" aria-atomic="true"></div>');
			});

			it("uiToast renders a status role for non-error variants", () => {
				var html = variables.bc.uiToast(title="Saved", description="Your post is live.", variant="success");
				expect(html).toMatch('role="status"');
				expect(html).toMatch('data-category="success"');
				expect(html).toMatch('<h2>Saved</h2>');
				expect(html).toMatch('<p>Your post is live\.</p>');
			});

			it("uiToast renders an alert role for the error variant", () => {
				var html = variables.bc.uiToast(title="Oops", variant="error");
				expect(html).toMatch('role="alert"');
				expect(html).toMatch('data-category="error"');
			});

			it("uiToast forwards a custom duration via data-duration", () => {
				var html = variables.bc.uiToast(title="x", duration=8000);
				expect(html).toMatch('data-duration="8000"');
			});

		});

		describe("Basecoat v2 — uiPopover family", () => {

			it("uiPopover opens with .popover class", () => {
				expect(variables.bc.uiPopover()).toBe('<div class="popover">');
			});

			it("uiPopoverTrigger emits aria-expanded=false (basecoat-js sets true on click)", () => {
				var html = variables.bc.uiPopoverTrigger(text="Open");
				expect(html).toMatch('aria-expanded="false"');
				expect(html).toMatch('class="btn-outline"');
			});

			it("uiPopoverContent emits data-popover and aria-hidden=true", () => {
				var html = variables.bc.uiPopoverContent();
				expect(html).toMatch('data-popover');
				expect(html).toMatch('aria-hidden="true"');
			});

		});

		describe("Basecoat v2 — uiAvatar / uiKbd", () => {

			it("uiAvatar renders an image when src is given", () => {
				var html = variables.bc.uiAvatar(src="/u.png", alt="Ada");
				expect(html).toMatch('<img src="/u.png" alt="Ada"');
			});

			it("uiAvatar renders a text fallback when src is empty", () => {
				var html = variables.bc.uiAvatar(text="AB", alt="Ada Beth");
				expect(html).toMatch('aria-label="Ada Beth"');
				expect(html).toMatch('>AB<');
				expect(html).notToMatch('<img');
			});

			it("uiKbd wraps content in <kbd class=\"kbd\">", () => {
				expect(variables.bc.uiKbd(text="⌘K")).toBe('<kbd class="kbd">⌘K</kbd>');
			});

		});

		describe("Basecoat v2 — uiButtonGroup / uiFieldset", () => {

			it("uiButtonGroup defaults to horizontal (no data-orientation)", () => {
				expect(variables.bc.uiButtonGroup()).toBe('<div class="button-group" role="group">');
			});

			it("uiButtonGroup vertical adds data-orientation", () => {
				expect(variables.bc.uiButtonGroup(orientation="vertical")).toBe('<div class="button-group" data-orientation="vertical" role="group">');
			});

			it("uiFieldset renders legend and description", () => {
				var html = variables.bc.uiFieldset(legend="Profile", description="Visible to your team.");
				expect(html).toMatch('<fieldset class="fieldset">');
				expect(html).toMatch('<legend>Profile</legend>');
				expect(html).toMatch('<p>Visible to your team\.</p>');
			});

		});

		describe("Basecoat v2 — uiThemeToggle / basecoatThemeScript", () => {

			it("basecoatThemeScript emits an inline pre-paint script", () => {
				var html = variables.bc.basecoatThemeScript();
				expect(html).toMatch('<script>');
				expect(html).toMatch('classList\.add\("dark"\)');
				expect(html).toMatch('basecoat:theme');
			});

			it("uiThemeToggle uses delegated data-attribute (no inline onclick)", () => {
				var html = variables.bc.uiThemeToggle();
				expect(html).toMatch('data-ui-theme-toggle="basecoat:theme"');
				expect(html).notToMatch('onclick=');
			});

		});

		describe("Basecoat v2 — Turbo Stream helpers", () => {

			it("turboStream(action='remove') renders a self-closing element", () => {
				expect(variables.bc.turboStream(action="remove", target="post_1")).toBe('<turbo-stream action="remove" target="post_1"></turbo-stream>');
			});

			it("turboStream(action='append') opens with a <template>", () => {
				expect(variables.bc.turboStream(action="append", target="comments")).toBe('<turbo-stream action="append" target="comments"><template>');
			});

			it("turboStreamEnd closes both the template and stream tags", () => {
				expect(variables.bc.turboStreamEnd()).toBe('</template></turbo-stream>');
			});

			it("turboStream supports a CSS-selector targets attribute", () => {
				var html = variables.bc.turboStream(action="replace", targets=".note");
				expect(html).toMatch('targets="\.note"');
			});

			it("turboStream(action='replace', method='morph') opts into morph", () => {
				var html = variables.bc.turboStream(action="replace", target="x", method="morph");
				expect(html).toMatch('method="morph"');
			});

		});

		describe("Basecoat v2 — basecoatIncludes", () => {

			it("loads the bundled basecoat-js by default", () => {
				var html = variables.bc.basecoatIncludes();
				expect(html).toMatch('href="/assets/basecoat/basecoat\.min\.css"');
				expect(html).toMatch('src="/assets/basecoat/js/all\.min\.js"');
				expect(html).toMatch('src="/assets/basecoat/js/wheels-basecoat-ui\.min\.js"');
			});

			it("Alpine is opt-in (not loaded by default)", () => {
				var html = variables.bc.basecoatIncludes();
				expect(html).notToMatch("alpinejs");
			});

			it("loads Alpine when requested", () => {
				var html = variables.bc.basecoatIncludes(alpine=true);
				expect(html).toMatch("alpinejs");
			});

			it("emits the turbo-cache-control meta tag", () => {
				var html = variables.bc.basecoatIncludes();
				expect(html).toMatch('name="turbo-cache-control"');
			});

		});

	}

}
