/**
 * v3.0 — coverage for layout/display helpers (callout, empty state,
 * accordion, timeline, code block, tag input), file upload, date picker,
 * and the Wheels resource conventions (uiPaginationFor, uiResourceTable).
 */
component extends="wheels.WheelsTest" {

	function beforeAll() {
		variables.bc = createObject("component", "plugins.basecoat.Basecoat").init();
	}

	function run() {
		describe("v3.0 — uiCallout", () => {

			it("renders with role=note and variant class", () => {
				var html = variables.bc.uiCallout(title="Pro tip", body="Try this.", variant="tip");
				expect(html).toMatch('class="ui-callout ui-callout-tip"');
				expect(html).toMatch('role="note"');
				expect(html).toMatch('<p class="ui-callout-title">Pro tip</p>');
				expect(html).toMatch('Try this\.');
			});

			it("rejects unknown variant", () => {
				expect(() => variables.bc.uiCallout(variant="bogus"))
					.toThrow(type="WheelsBasecoat.InvalidArgument");
			});

		});

		describe("v3.0 — uiEmptyState", () => {

			it("renders title + description + optional CTA", () => {
				var html = variables.bc.uiEmptyState(
					title="No posts yet", description="Be the first.",
					actionText="Write the first post", actionHref="/posts/new"
				);
				expect(html).toMatch('class="ui-empty-state"');
				expect(html).toMatch('<h3>No posts yet</h3>');
				expect(html).toMatch('href="/posts/new"');
				expect(html).toMatch('>Write the first post<');
			});

			it("omits CTA when actionText empty", () => {
				var html = variables.bc.uiEmptyState(title="Empty");
				expect(html).notToMatch('class="btn');
			});

		});

		describe("v3.0 — uiAccordion family", () => {

			it("renders <details>/<summary> structure", () => {
				var open = variables.bc.uiAccordion();
				var item = variables.bc.uiAccordionItem(title="Q1", open=true);
				expect(open).toBe('<div class="ui-accordion">');
				expect(item).toMatch('<details open>');
				expect(item).toMatch('<summary>');
				expect(item).toMatch('<span>Q1</span>');
			});

			it("non-open item has no `open` attribute", () => {
				var item = variables.bc.uiAccordionItem(title="Q2");
				expect(item).notToMatch(' open>');
			});

		});

		describe("v3.0 — uiTimeline", () => {

			it("renders ol.ui-timeline + items with marker + content", () => {
				var open = variables.bc.uiTimeline();
				var item = variables.bc.uiTimelineItem(title="Post published", time="2:14 PM", icon="check-circle");
				expect(open).toBe('<ol class="ui-timeline">');
				expect(item).toMatch('<span class="ui-timeline-marker">');
				expect(item).toMatch('<svg');                       // icon
				expect(item).toMatch('Post published');
				expect(item).toMatch('<time class="ui-timeline-time">2:14 PM</time>');
			});

		});

		describe("v3.0 — uiCodeBlock", () => {

			it("renders header (filename + copy) + pre><code with language class", () => {
				var html = variables.bc.uiCodeBlock(content="<p>x</p>", language="html", filename="post.html");
				expect(html).toMatch('class="ui-code-block"');
				expect(html).toMatch('class="ui-code-block-filename">post\.html');
				expect(html).toMatch('class="language-html"');
				expect(html).toMatch('data-ui-code-copy');
				// Default escape=true escapes the < and >
				expect(html).toMatch('&lt;p&gt;x&lt;/p&gt;');
			});

			it("escape=false leaves content as-is for pre-highlighted markup", () => {
				var html = variables.bc.uiCodeBlock(content='<span class="hl">x</span>', escape=false);
				expect(html).toMatch('<span class="hl">x</span>');
			});

			it("showCopy=false omits the copy button", () => {
				var html = variables.bc.uiCodeBlock(content="x", showCopy=false);
				expect(html).notToMatch('data-ui-code-copy');
			});

		});

		describe("v3.0 — uiTagInput", () => {

			it("renders pills for initial values, an entry input, and a hidden CSV input", () => {
				var html = variables.bc.uiTagInput(name="tags", value="design,ops");
				expect(html).toMatch('class="ui-tag-input"');
				expect(html).toMatch('class="ui-tag-pill" data-value="design"');
				expect(html).toMatch('class="ui-tag-pill" data-value="ops"');
				expect(html).toMatch('<input type="text" id=');
				expect(html).toMatch('class="ui-tag-input-entry"');
				expect(html).toMatch('<input type="hidden" class="ui-tag-input-hidden" name="tags" value="design,ops">');
			});

			it("accepts a real CFML array as value", () => {
				var html = variables.bc.uiTagInput(name="tags", value=["a","b"]);
				expect(html).toMatch('data-value="a"');
				expect(html).toMatch('data-value="b"');
			});

			it("renders datalist when suggestions provided", () => {
				var html = variables.bc.uiTagInput(name="tags", suggestions="design,engineering,marketing");
				expect(html).toMatch('<datalist');
				expect(html).toMatch('<option value="design">');
				expect(html).toMatch('<option value="engineering">');
			});

			it("multipleHidden=true emits one hidden per tag with `[]` name", () => {
				var html = variables.bc.uiTagInput(name="tags", value="a,b", multipleHidden=true);
				expect(html).toMatch('name="tags\[\]" value="a"');
				expect(html).toMatch('name="tags\[\]" value="b"');
			});

			it("uiBoundTagInput throws when object missing", () => {
				expect(() => variables.bc.uiBoundTagInput(objectName="ghost", property="x"))
					.toThrow(type="WheelsBasecoat.ObjectNotFound");
			});

		});

		describe("v3.0 — uiFileUpload", () => {

			it("renders the drag-and-drop zone with hidden file input", () => {
				var html = variables.bc.uiFileUpload(name="cover", accept="image/*");
				expect(html).toMatch('class="ui-file-upload"');
				expect(html).toMatch('data-ui-file-upload');
				expect(html).toMatch('type="file"');
				expect(html).toMatch('name="cover"');
				expect(html).toMatch('accept="image/\*"');
			});

			it("multiple=true sets the multiple attribute", () => {
				var html = variables.bc.uiFileUpload(name="files", multiple=true);
				expect(html).toMatch('multiple');
			});

			it("uiBoundFile multiplies the property name with `[]` for multi-uploads", () => {
				variables.post = { covers: "" };
				var html = variables.bc.uiBoundFile(objectName="post", property="covers", multiple=true);
				expect(html).toMatch('name="post\[covers\]\[\]"');
			});

		});

		describe("v3.0 — uiDatePicker", () => {

			it("emits input[type=date] with min/max + label", () => {
				var html = variables.bc.uiDatePicker(name="publishedAt", value="2026-05-01",
					label="Published at", min="2025-01-01", max="2027-12-31");
				expect(html).toMatch('type="date"');
				expect(html).toMatch('value="2026-05-01"');
				expect(html).toMatch('min="2025-01-01"');
				expect(html).toMatch('max="2027-12-31"');
				expect(html).toMatch('>Published at</label>');
			});

			it("coerces a quote-wrapped Lucee datetime to yyyy-mm-dd", () => {
				var html = variables.bc.uiDatePicker(name="d", value="'2026-05-01 14:00:00'");
				expect(html).toMatch('value="2026-05-01"');
			});

		});

		describe("v3.0 — uiPaginationFor", () => {

			it("returns empty string when totalpages <= 1", () => {
				var q = queryNew("currentpage,totalpages", "integer,integer", [[1, 1]]);
				expect(variables.bc.uiPaginationFor(query=q, baseUrl="/posts")).toBe("");
			});

			it("renders pagination for a paginated query", () => {
				var q = queryNew("currentpage,totalpages", "integer,integer", [[3, 12]]);
				var html = variables.bc.uiPaginationFor(query=q, baseUrl="/posts");
				expect(html).toMatch('class="pagination"');
				// Active page = 3
				expect(html).toMatch('aria-current="page"');
				// Has page 12 link somewhere
				expect(html).toMatch('page=12');
			});

		});

		describe("v3.0 — uiResourceTable", () => {

			it("auto-builds a basecoat table from a query result", () => {
				var q = queryNew("id,title,status", "integer,varchar,varchar", [
					[1, "Hello", "published"],
					[2, "Draft", "draft"]
				]);
				var html = variables.bc.uiResourceTable(query=q, columns="title,status");
				expect(html).toMatch('<table class="table"');
				expect(html).toMatch('<th>Title</th>');
				expect(html).toMatch('<th>Status</th>');
				expect(html).toMatch('<td>Hello</td>');
				expect(html).toMatch('<td>Draft</td>');
			});

			it("renders Edit + Delete actions when routes provided", () => {
				var q = queryNew("id,title", "integer,varchar", [[1, "Hello"]]);
				var html = variables.bc.uiResourceTable(query=q, columns="title",
					editRoute="editPost", deleteRoute="post");
				expect(html).toMatch('Edit');
				expect(html).toMatch('Delete');
				expect(html).toMatch('data-turbo-confirm');
			});

			it("returns nicely-formatted booleans + dates via $formatCell", () => {
				var html = variables.bc.$formatCell(true);
				expect(html).toBe("✓");
				var html2 = variables.bc.$formatCell("2026-05-01 14:00:00");
				expect(html2).toMatch("May 1, 2026");
			});

		});

	}

}
