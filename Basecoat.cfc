/**
 * wheels-basecoat Plugin
 * Basecoat UI component helpers for Wheels.
 * Generates shadcn/ui-quality HTML using Basecoat CSS classes.
 * Works with or without wheels-hotwire.
 */
component output="false" {

	function init() {
		// Source of truth: package.json. Reading at init keeps init()'s
		// version field and the manifest from drifting (a recurring bug
		// pre-2.0 — see Wheels Tutorial Finding #N).
		this.version = $readPackageVersion();
		return this;
	}

	private string function $readPackageVersion() {
		try {
			var pkgPath = getDirectoryFromPath(getCurrentTemplatePath()) & "package.json";
			if (fileExists(pkgPath)) {
				var pkg = deserializeJSON(fileRead(pkgPath, "utf-8"));
				if (structKeyExists(pkg, "version") && len(pkg.version)) return pkg.version;
			}
		} catch (any e) {}
		return "0.0.0-unknown";
	}

	// ==============================================
	// INCLUDES
	// ==============================================

	/**
	 * Renders the <link>/<script> tags for Basecoat CSS + JS in the layout <head>.
	 *
	 * Defaults assume the package's bundled assets have been published to the
	 * app's public/ directory at `/assets/basecoat/...` — the recommended
	 * install does `cp -r vendor/wheels-basecoat/assets/basecoat public/assets/basecoat`.
	 * Override `cssPath` / `jsPath` if you've published them elsewhere or wish
	 * to use a CDN.
	 *
	 * @cssPath URL to basecoat.min.css. Default points at the published bundled asset.
	 * @jsPath URL to basecoat all-in-one JS bundle. Default points at the published bundled asset.
	 * @basecoatJS Load basecoat-js (drives tabs, dropdown, popover, select, command, sidebar, toast). Default true.
	 * @alpine Optionally load Alpine.js (no longer required for any built-in helper). Default false.
	 * @alpineVersion Alpine major version to load when alpine=true.
	 * @turboAware Emit `<meta name="turbo-cache-control" content="no-preview">` so Turbo doesn't cache stale dialog/popover snapshots.
	 */
	public string function basecoatIncludes(
		string cssPath = "/assets/basecoat/basecoat.min.css",
		string extrasCssPath = "/assets/basecoat/wheels-basecoat-extras.min.css",
		string jsPath = "/assets/basecoat/js/all.min.js",
		string uiJsPath = "/assets/basecoat/js/wheels-basecoat-ui.min.js",
		boolean basecoatJS = true,
		boolean uiJS = true,
		boolean extrasCSS = true,
		boolean alpine = false,
		string alpineVersion = "3",
		boolean turboAware = true
	) {
		var local = {};
		savecontent variable="local.html" {
			writeOutput(
				(arguments.turboAware ? '<meta name="turbo-cache-control" content="no-preview">' & chr(10) : '')
				& '<link rel="stylesheet" href="#arguments.cssPath#">' & chr(10)
				& (arguments.extrasCSS ? '<link rel="stylesheet" href="#arguments.extrasCssPath#">' & chr(10) : '')
				& (arguments.basecoatJS ? '<script defer src="#arguments.jsPath#"></script>' & chr(10) : '')
				& (arguments.uiJS ? '<script defer src="#arguments.uiJsPath#"></script>' & chr(10) : '')
				& (arguments.alpine ? '<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@#arguments.alpineVersion#/dist/cdn.min.js"></script>' & chr(10) : '')
			);
		}
		return trim(local.html);
	}

	// ==============================================
	// ARG VALIDATION
	// ==============================================

	/**
	 * Validates that `value` appears in `allowed` and throws a clear error
	 * naming both the helper and the bad value otherwise. The default
	 * Wheels behavior would silently produce e.g. `class="btn-primay"`
	 * (typo) and leave the developer puzzling at the unstyled button.
	 *
	 * Declared `public` despite the `$`-prefix-internal naming because
	 * Wheels' `PackageLoader` only mixes the package's PUBLIC methods into
	 * the target scope — and the public helpers that call this function
	 * (uiButton, uiBadge, uiAlert, uiField, uiToast, uiButtonGroup,
	 * uiThemeToggle, turboStream) all invoke it from the mixed-in
	 * variables-scope context. Same pattern as `$uiLucideIcon` /
	 * `$uiBuildId`. The leading `$` keeps signalling "internal — don't call
	 * from app code" while keeping the method visible across the mixin
	 * boundary.
	 */
	public void function $validateEnum(
		required string value,
		required string allowed,
		required string helper,
		required string argument
	) {
		if (!ListFindNoCase(arguments.allowed, arguments.value)) {
			throw(
				type = "WheelsBasecoat.InvalidArgument",
				message = "#arguments.helper#() received an unsupported #arguments.argument# value: '#arguments.value#'.",
				detail = "Allowed values are: #arguments.allowed#."
			);
		}
	}

	// ==============================================
	// BUTTONS
	// ==============================================

	/**
	 * Basecoat button. Variants: primary, secondary, destructive, outline, ghost, link. Sizes: sm, md, lg.
	 */
	public string function uiButton(
		string text = "",
		string variant = "primary",
		string size = "md",
		string icon = "",
		string href = "",
		string type = "button",
		boolean disabled = false,
		boolean loading = false,
		boolean close = false,
		string class = "",
		string id = "",
		string ariaLabel = "",
		string turboConfirm = "",
		string turboMethod = ""
	) {
		$validateEnum(arguments.variant, "primary,secondary,destructive,outline,ghost,link", "uiButton", "variant");
		$validateEnum(arguments.size, "sm,md,lg", "uiButton", "size");
		var local = {};

		// Build Basecoat compound class: btn[-size][-icon]-variant
		// Always emit the variant suffix so rendered HTML self-documents
		// (e.g. `btn-primary` instead of bare `btn`). basecoat-css ships
		// matching selectors for every size×variant combination.
		local.isIconOnly = len(arguments.icon) && !len(arguments.text);
		local.parts = [];
		if (arguments.size != "md") arrayAppend(local.parts, arguments.size);
		if (local.isIconOnly) arrayAppend(local.parts, "icon");
		arrayAppend(local.parts, arguments.variant);

		local.cls = "btn-" & arrayToList(local.parts, "-");
		if (len(arguments.class)) local.cls &= " " & arguments.class;

		// Inner content: icon + text
		local.inner = "";
		if (arguments.loading) {
			local.inner = $uiLucideIcon("loader", 24, 2, "animate-spin");
		} else if (len(arguments.icon)) {
			local.inner = $uiLucideIcon(arguments.icon, 24);
		}
		if (len(arguments.text)) {
			if (len(local.inner)) local.inner &= " ";
			local.inner &= arguments.text;
		}

		// Attributes
		local.attrs = 'class="#local.cls#"';
		if (len(arguments.id)) local.attrs &= ' id="#arguments.id#"';
		if (arguments.disabled || arguments.loading) local.attrs &= " disabled";
		if (len(arguments.ariaLabel)) local.attrs &= ' aria-label="#arguments.ariaLabel#"';
		if (arguments.close) local.attrs &= " onclick=""this.closest('dialog').close()""";
		if (len(arguments.turboConfirm)) local.attrs &= ' data-turbo-confirm="#arguments.turboConfirm#"';
		if (len(arguments.turboMethod)) local.attrs &= ' data-turbo-method="#arguments.turboMethod#"';

		if (len(arguments.href))
			return '<a href="#arguments.href#" #local.attrs#>#local.inner#</a>';
		return '<button type="#arguments.type#" #local.attrs#>#local.inner#</button>';
	}

	// ==============================================
	// BADGES
	// ==============================================

	/** Basecoat badge. Variants: default, secondary, destructive, outline. */
	public string function uiBadge(required string text, string variant = "default", string class = "") {
		$validateEnum(arguments.variant, "default,secondary,destructive,outline", "uiBadge", "variant");
		var cls = (arguments.variant == "default") ? "badge" : "badge-#arguments.variant#";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<span class="#cls#">#arguments.text#</span>';
	}

	// ==============================================
	// ICONS
	// ==============================================

	/** Renders a Lucide SVG icon by name. */
	public string function uiIcon(required string name, numeric size = 24, numeric strokeWidth = 2, string class = "") {
		return $uiLucideIcon(arguments.name, arguments.size, arguments.strokeWidth, arguments.class);
	}

	// ==============================================
	// SIMPLE COMPONENTS
	// ==============================================

	/** Basecoat loading spinner. */
	public string function uiSpinner(string class = "") {
		var cls = "spinner";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="#cls#"></div>';
	}

	/** Basecoat skeleton loading placeholder. Specify lines for multiple, or use height/width for custom. */
	public string function uiSkeleton(numeric lines = 1, string height = "h-4", string width = "w-full", string class = "") {
		var cls = "skeleton #arguments.height# #arguments.width#";
		if (len(arguments.class)) cls &= " " & arguments.class;

		if (arguments.lines == 1)
			return '<div class="#cls#"></div>';

		var html = "";
		for (var i = 1; i <= arguments.lines; i++) {
			html &= '<div class="#cls#"></div>';
			if (i < arguments.lines) html &= chr(10);
		}
		return html;
	}

	/** Basecoat progress bar. */
	public string function uiProgress(required numeric value, string class = "") {
		var cls = "progress";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="#cls#"><div class="progress-indicator" style="width: #arguments.value#%"></div></div>';
	}

	/** Basecoat horizontal separator. */
	public string function uiSeparator(string class = "") {
		var cls = "separator";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<hr class="#cls#" />';
	}

	/** Opens a Basecoat tooltip wrapper. Place trigger element inside, close with uiTooltipEnd(). */
	public string function uiTooltip(required string tip, string class = "") {
		var cls = "tooltip";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<span class="#cls#" data-tip="#arguments.tip#">';
	}

	public string function uiTooltipEnd() {
		return '</span>';
	}

	// ==============================================
	// ALERTS
	// ==============================================

	/**
	 * Basecoat alert. Self-closing (returns complete element). Variants: default, destructive.
	 */
	public string function uiAlert(
		string title = "",
		string description = "",
		string variant = "default",
		string icon = "",
		string class = ""
	) {
		$validateEnum(arguments.variant, "default,destructive", "uiAlert", "variant");
		var local = {};
		local.cls = "alert";
		if (arguments.variant == "destructive") local.cls &= " alert-destructive";
		if (len(arguments.class)) local.cls &= " " & arguments.class;

		// Default icons by variant
		local.iconName = len(arguments.icon) ? arguments.icon : (arguments.variant == "destructive" ? "alert-triangle" : "info");

		savecontent variable="local.html" {
			writeOutput(
				'<div class="#local.cls#" role="alert">' & chr(10)
				& $uiLucideIcon(local.iconName, 16) & chr(10)
				& (len(arguments.title) ? '<h5>#arguments.title#</h5>' & chr(10) : '')
				& (len(arguments.description) ? '<section><p>#arguments.description#</p></section>' & chr(10) : '')
				& '</div>'
			);
		}
		return trim(local.html);
	}

	// ==============================================
	// CARDS
	// ==============================================
	//
	// basecoat-css 0.3.x styles cards via the semantic-element selectors
	// `.card > header`, `.card > section`, `.card > footer` (rather than the
	// older `.card-header` / `.card-content` / `.card-footer` class hooks).
	// These helpers emit the matching semantic markup.

	/** Opens a Basecoat card. Close with uiCardEnd(). */
	public string function uiCard(string class = "") {
		var cls = "card";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="#cls#">';
	}

	/**
	 * Card header with optional title and description. Self-closing.
	 * Renders an <h2> for the title — basecoat-css 0.3.x targets `.card > header h2`
	 * for the title typography. The `description` renders as a `<p>` sibling.
	 */
	public string function uiCardHeader(string title = "", string description = "", string class = "") {
		var local = {};
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";

		savecontent variable="local.html" {
			writeOutput(
				'<header#classAttr#>' & chr(10)
				& (len(arguments.title) ? '<h2>#arguments.title#</h2>' & chr(10) : '')
				& (len(arguments.description) ? '<p>#arguments.description#</p>' & chr(10) : '')
				& '</header>'
			);
		}
		return trim(local.html);
	}

	/** Opens card content section. Close with uiCardContentEnd(). */
	public string function uiCardContent(string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<section#classAttr#>';
	}

	public string function uiCardContentEnd() {
		return '</section>';
	}

	/** Opens card footer section. Close with uiCardFooterEnd(). */
	public string function uiCardFooter(string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<footer#classAttr#>';
	}

	public string function uiCardFooterEnd() {
		return '</footer>';
	}

	public string function uiCardEnd() {
		return '</div>';
	}

	// ==============================================
	// LUCIDE ICON SVG HELPER (intentionally public — see note below)
	// ==============================================

	/**
	 * Returns SVG markup for a Lucide icon. Extend the icon map as needed.
	 *
	 * Declared `public` despite the `$`-prefix-internal naming because Wheels'
	 * `PackageLoader` only mixes the package's PUBLIC methods into the target
	 * scope (controllers in this case). Sibling helpers like `uiButton(icon=...)`,
	 * `uiAlert`, and `uiPagination` invoke `$uiLucideIcon` from within the
	 * mixed-in variables-scope context — if it stays `private`, those calls
	 * blow up with `No matching function [$UILUCIDEICON] found`. The leading
	 * `$` keeps signalling "internal — don't call from app code" while keeping
	 * the method visible across the package after PackageLoader integrates
	 * the methods. See wheels-basecoat#2 / Wheels Tutorial Finding #14.
	 */
	public string function $uiLucideIcon(required string name, numeric size = 24, numeric strokeWidth = 2, string class = "") {
		var icons = {
			"plus": '<line x1="12" x2="12" y1="5" y2="19"/><line x1="5" x2="19" y1="12" y2="12"/>',
			"trash": '<path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/>',
			"pencil": '<path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/><path d="m15 5 4 4"/>',
			"x": '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
			"check": '<path d="M20 6 9 17l-5-5"/>',
			"chevron-right": '<path d="m9 18 6-6-6-6"/>',
			"chevron-left": '<path d="m15 18-6-6 6-6"/>',
			"search": '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
			"loader": '<path d="M12 2v4"/><path d="m16.2 7.8 2.9-2.9"/><path d="M18 12h4"/><path d="m16.2 16.2 2.9 2.9"/><path d="M12 18v4"/><path d="m4.9 19.1 2.9-2.9"/><path d="M2 12h4"/><path d="m4.9 4.9 2.9 2.9"/>',
			"alert-triangle": '<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/><path d="M12 9v4"/><path d="M12 17h.01"/>',
			"info": '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/>',
			"check-circle": '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="m9 11 3 3L22 4"/>',
			"send": '<path d="M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z"/><path d="m21.854 2.147-10.94 10.939"/>',
			"ellipsis": '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>',
			"external-link": '<path d="M15 3h6v6"/><path d="M10 14 21 3"/><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>',
			"sun": '<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>',
			"moon": '<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>',
			"log-out": '<path d="m16 17 5-5-5-5"/><path d="M21 12H9"/><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>',
			"log-in": '<path d="m10 17 5-5-5-5"/><path d="M15 12H3"/><path d="M9 3h10a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H9"/>',
			"user": '<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
			"settings": '<path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/>',
			"menu": '<line x1="4" x2="20" y1="12" y2="12"/><line x1="4" x2="20" y1="6" y2="6"/><line x1="4" x2="20" y1="18" y2="18"/>',
			"home": '<path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>',
			"file-text": '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" x2="8" y1="13" y2="13"/><line x1="16" x2="8" y1="17" y2="17"/><polyline points="10 9 9 9 8 9"/>',
			"star": '<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>'
		};

		var paths = structKeyExists(icons, arguments.name) ? icons[arguments.name] : '<circle cx="12" cy="12" r="10"/>';
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<svg xmlns="http://www.w3.org/2000/svg" width="#arguments.size#" height="#arguments.size#" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="#arguments.strokeWidth#" stroke-linecap="round" stroke-linejoin="round"#classAttr#>#paths#</svg>';
	}

	// ==============================================
	// ID GENERATION (intentionally public — see $uiLucideIcon note above)
	// ==============================================

	/**
	 * Generates a short unique ID if none provided.
	 *
	 * Declared `public` for the same reason as `$uiLucideIcon` — `uiField`,
	 * `uiInput`, `uiCheckbox`, `uiTextarea`, etc. all call `$uiBuildId` from
	 * the mixed-in scope, and Wheels' `PackageLoader` only carries public
	 * methods across to the target. The `$` prefix still signals "internal".
	 */
	public string function $uiBuildId(string providedId = "", string prefix = "ui") {
		if (len(arguments.providedId))
			return arguments.providedId;
		return arguments.prefix & "-" & replace(left(createUUID(), 8), "-", "", "all");
	}

	// ==============================================
	// DIALOGS
	// ==============================================

	/**
	 * Opens a Basecoat dialog (native <dialog> element). Close with uiDialogEnd().
	 * Optionally renders a trigger button.
	 */
	public string function uiDialog(
		required string title,
		string description = "",
		string triggerText = "",
		string triggerClass = "btn-outline",
		string id = "",
		string maxWidth = "sm:max-w-[425px]",
		string class = ""
	) {
		var local = {};
		local.id = $uiBuildId(arguments.id, "dlg");
		local.cls = "dialog w-full #arguments.maxWidth# max-h-[612px]";
		if (len(arguments.class)) local.cls &= " " & arguments.class;

		savecontent variable="local.html" {
			// CSP-friendly trigger / close — handlers are delegated by
			// wheels-basecoat-ui.js (loaded by `basecoatIncludes()`) via
			// `data-ui-dialog-open` / `data-ui-dialog-close` and a
			// click-on-backdrop dispatcher. No inline `onclick` required.
			writeOutput(
				(len(arguments.triggerText) ? '<button type="button" data-ui-dialog-open="#local.id#" class="#arguments.triggerClass#">#arguments.triggerText#</button>' & chr(10) : '')
				& '<dialog id="#local.id#" class="#local.cls#" aria-labelledby="#local.id#-title"'
				& (len(arguments.description) ? ' aria-describedby="#local.id#-desc"' : '')
				& '>' & chr(10)
				& '<div>' & chr(10)
				& '<header>' & chr(10)
				& '<h2 id="#local.id#-title">#arguments.title#</h2>' & chr(10)
				& (len(arguments.description) ? '<p id="#local.id#-desc">#arguments.description#</p>' & chr(10) : '')
				& '</header>' & chr(10)
				& '<section>'
			);
		}
		return trim(local.html);
	}

	/** Closes the dialog content section and opens the footer section. */
	public string function uiDialogFooter() {
		return '</section><footer>';
	}

	/** Closes the dialog footer, adds the close (X) button, and closes the dialog element. */
	public string function uiDialogEnd() {
		var xIcon = $uiLucideIcon("x", 24, 2);
		return '</footer><button type="button" aria-label="Close dialog" data-ui-dialog-close>#xIcon#</button></div></dialog>';
	}

	// ==============================================
	// FORM FIELDS
	// ==============================================

	/**
	 * Basecoat form field. Handles text, email, password, number, tel, url, textarea, select, checkbox, switch.
	 */
	public string function uiField(
		required string label,
		required string name,
		string type = "text",
		string value = "",
		string id = "",
		string placeholder = "",
		string description = "",
		string errorMessage = "",
		boolean required = false,
		boolean disabled = false,
		boolean checked = false,
		string options = "",
		numeric rows = 4,
		string class = ""
	) {
		$validateEnum(arguments.type, "text,email,password,number,tel,url,date,datetime-local,time,search,textarea,select,checkbox,switch", "uiField", "type");
		var local = {};
		local.id = $uiBuildId(arguments.id, "fld");
		local.hasError = len(arguments.errorMessage);
		local.isToggle = (arguments.type == "checkbox" || arguments.type == "switch");

		// Build input attrs common to all types
		local.commonAttrs = 'id="#local.id#" name="#arguments.name#"';
		if (arguments.required) local.commonAttrs &= " required";
		if (arguments.disabled) local.commonAttrs &= " disabled";

		savecontent variable="local.html" {
			// Wrapper
			if (local.isToggle) {
				writeOutput('<div class="flex items-center gap-2">' & chr(10));
			} else {
				writeOutput('<div class="grid gap-2">' & chr(10));
			}

			// Label before input (non-toggle types)
			if (!local.isToggle)
				writeOutput('<label for="#local.id#">#arguments.label#</label>' & chr(10));

			// Input element by type
			if (arguments.type == "textarea") {
				writeOutput('<textarea #local.commonAttrs# class="textarea#local.hasError ? " border-destructive" : ""#"');
				if (len(arguments.placeholder)) writeOutput(' placeholder="#arguments.placeholder#"');
				writeOutput(' rows="#arguments.rows#"');
				if (local.hasError) writeOutput(' aria-invalid="true" aria-describedby="#local.id#-error"');
				writeOutput('>#arguments.value#</textarea>' & chr(10));
			} else if (arguments.type == "select") {
				writeOutput('<select #local.commonAttrs# class="select#local.hasError ? " border-destructive" : ""#"');
				if (local.hasError) writeOutput(' aria-invalid="true" aria-describedby="#local.id#-error"');
				writeOutput('>' & chr(10));
				if (len(arguments.options)) {
					for (var opt in listToArray(arguments.options)) {
						var optParts = listToArray(opt, ":");
						var optVal = optParts[1];
						var optLabel = (arrayLen(optParts) > 1) ? optParts[2] : optParts[1];
						writeOutput('<option value="#optVal#"#arguments.value == optVal ? " selected" : ""#>#optLabel#</option>' & chr(10));
					}
				}
				writeOutput('</select>' & chr(10));
			} else if (arguments.type == "checkbox") {
				writeOutput('<input type="checkbox" #local.commonAttrs# class="checkbox#len(arguments.class) ? " " & arguments.class : ""#"');
				if (arguments.checked) writeOutput(' checked');
				if (local.hasError) writeOutput(' aria-invalid="true" aria-describedby="#local.id#-error"');
				writeOutput(' />' & chr(10));
			} else if (arguments.type == "switch") {
				writeOutput('<input type="checkbox" #local.commonAttrs# class="switch#len(arguments.class) ? " " & arguments.class : ""#" role="switch"');
				if (arguments.checked) writeOutput(' checked');
				if (local.hasError) writeOutput(' aria-invalid="true" aria-describedby="#local.id#-error"');
				writeOutput(' />' & chr(10));
			} else {
				writeOutput('<input type="#arguments.type#" #local.commonAttrs# class="input#local.hasError ? " border-destructive" : ""#"');
				if (len(arguments.value)) writeOutput(' value="#arguments.value#"');
				if (len(arguments.placeholder)) writeOutput(' placeholder="#arguments.placeholder#"');
				if (local.hasError) writeOutput(' aria-invalid="true" aria-describedby="#local.id#-error"');
				if (len(arguments.class)) writeOutput(' #arguments.class#');
				writeOutput(' />' & chr(10));
			}

			// Label after input (toggle types)
			if (local.isToggle)
				writeOutput('<label for="#local.id#">#arguments.label#</label>' & chr(10));

			// Description (only when no error)
			if (len(arguments.description) && !local.hasError)
				writeOutput('<p class="text-sm text-muted-foreground">#arguments.description#</p>' & chr(10));

			// Error message
			if (local.hasError)
				writeOutput('<p id="#local.id#-error" class="text-sm text-destructive">#arguments.errorMessage#</p>' & chr(10));

			writeOutput('</div>');
		}
		return trim(local.html);
	}

	// ==============================================
	// MODEL-BOUND FORM FIELD (Wheels integration)
	// ==============================================

	/**
	 * Bind a Basecoat field to a Wheels model object — auto-resolves the
	 * input value, the error message (when validation has failed), and the
	 * `name` attribute (`<objectName>[<property>]`) from the controller-scoped
	 * object.
	 *
	 * Mirrors the ergonomics of Wheels' built-in `textField(objectName=,property=)`,
	 * but renders Basecoat-styled markup (with proper error highlighting and
	 * description) and supports every type that `uiField` does.
	 *
	 * <pre>
	 *   ##startFormTag(action="update", key=post.id)##
	 *     ##uiBoundField(objectName="post", property="title", required=true)##
	 *     ##uiBoundField(objectName="post", property="body", type="textarea", rows=12)##
	 *     ##uiBoundField(objectName="post", property="status", type="select",
	 *                    options="draft:Draft,published:Published")##
	 *   ##endFormTag()##
	 * </pre>
	 *
	 * On a failed save, Wheels surfaces validation errors on the model object;
	 * `uiBoundField` reads `obj.errorsOn(property)` automatically and applies
	 * the destructive border + error paragraph below the input. Description
	 * is hidden when an error is present (matching `uiField` behavior).
	 *
	 * @objectName Variable name of the model in the current controller scope (e.g. "post").
	 * @property Property to bind on the model (e.g. "title").
	 * @label Form label. Defaults to a humanized version of the property name.
	 * @type Input type (see uiField for full list). Defaults to "text".
	 * @id Optional explicit input id. Auto-generated if omitted.
	 * @placeholder Optional placeholder text.
	 * @description Optional help text below the input. Hidden when an error is shown.
	 * @required HTML required.
	 * @disabled HTML disabled.
	 * @options For select inputs — same format as uiField.
	 * @rows For textarea inputs — same as uiField.
	 * @class Extra classes appended to the input element.
	 */
	public string function uiBoundField(
		required string objectName,
		required string property,
		string label = "",
		string type = "text",
		string id = "",
		string placeholder = "",
		string description = "",
		boolean required = false,
		boolean disabled = false,
		string options = "",
		numeric rows = 4,
		string class = ""
	) {
		// Look the object up in the surrounding scope. The package methods
		// are mixed into the controller via PackageLoader and the view
		// renders inside the controller's variables scope, so the model
		// object exposed by the action (`post = params.post` etc.) is
		// reachable here.
		if (!structKeyExists(variables, arguments.objectName)) {
			throw(
				type = "WheelsBasecoat.ObjectNotFound",
				message = "uiBoundField: object '#arguments.objectName#' not found in the current scope.",
				detail = "Make sure the controller action exposes the model object (e.g. `post = model('Post').findByKey(params.id)`) before the view renders."
			);
		}
		var obj = variables[arguments.objectName];

		// Default label = humanized property name ("publishedAt" → "Published at").
		var resolvedLabel = len(arguments.label) ? arguments.label : $humanize(arguments.property);

		// Resolve the bound value. Plain structs and Wheels objects both
		// expose properties via bracket access; defaulting to empty string
		// means "new" objects with no fields render the right empty inputs.
		var resolvedValue = "";
		try {
			resolvedValue = obj[arguments.property] ?: "";
		} catch (any e) {
			resolvedValue = "";
		}

		// Datetime values arrive from Lucee/Wheels in formats that don't
		// round-trip into HTML form inputs cleanly — strip the surrounding
		// quotes some adapters add and reformat date types to the input
		// element's expected ISO-ish format.
		if (Len(resolvedValue) && (arguments.type == "date" || arguments.type == "datetime-local" || arguments.type == "time")) {
			var cleaned = Replace(Trim(resolvedValue), "'", "", "all");
			if (IsDate(cleaned)) {
				if (arguments.type == "date") {
					resolvedValue = DateFormat(cleaned, "yyyy-mm-dd");
				} else if (arguments.type == "datetime-local") {
					resolvedValue = DateTimeFormat(cleaned, "yyyy-mm-dd'T'HH:nn");
				} else {
					resolvedValue = TimeFormat(cleaned, "HH:nn");
				}
			} else {
				resolvedValue = cleaned;
			}
		}

		// For toggle types, derive the `checked` flag from the resolved value.
		var resolvedChecked = false;
		if (arguments.type == "checkbox" || arguments.type == "switch") {
			resolvedChecked = (IsBoolean(resolvedValue) && resolvedValue) || (IsNumeric(resolvedValue) && resolvedValue != 0);
			resolvedValue = ""; // checkbox/switch ignore value, only emit `checked`.
		}

		// Read the validation error (if any). Tolerate plain structs that
		// don't expose `hasErrors` / `errorsOn` — those simply have none.
		var resolvedError = "";
		try {
			if (IsObject(obj) && obj.hasErrors(arguments.property)) {
				var errs = obj.errorsOn(arguments.property);
				if (ArrayLen(errs) >= 1) resolvedError = errs[1].message;
			}
		} catch (any e) {}

		return uiField(
			label = resolvedLabel,
			name = "#arguments.objectName#[#arguments.property#]",
			type = arguments.type,
			value = resolvedValue,
			id = arguments.id,
			placeholder = arguments.placeholder,
			description = arguments.description,
			errorMessage = resolvedError,
			required = arguments.required,
			disabled = arguments.disabled,
			checked = resolvedChecked,
			options = arguments.options,
			rows = arguments.rows,
			class = arguments.class
		);
	}

	/**
	 * Convert a property name like "publishedAt" / "first_name" into a
	 * human-readable label like "Published at" / "First name".
	 *
	 * Public for the same reason as `$validateEnum` — called from the
	 * mixed-in scope by `uiBoundField`. (See PackageLoader notes above.)
	 */
	public string function $humanize(required string property) {
		var s = arguments.property;
		// camelCase → space-separated
		s = REReplace(s, "([a-z])([A-Z])", "\1 \2", "all");
		// snake_case → space-separated
		s = Replace(s, "_", " ", "all");
		// Capitalize first letter only (sentence case).
		if (len(s)) s = uCase(left(s, 1)) & lCase(mid(s, 2, len(s) - 1));
		return s;
	}

	// ==============================================
	// TABLES
	// ==============================================

	/** Opens a Basecoat table (table-container + table). Close with uiTableEnd(). */
	public string function uiTable(string class = "") {
		var cls = "table";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="table-container"><table class="#cls#">';
	}

	/** Opens the table thead and a tr. Close with uiTableHeaderEnd(). */
	public string function uiTableHeader() {
		return '<thead><tr>';
	}

	public string function uiTableHeaderEnd() {
		return '</tr></thead>';
	}

	/** Opens the table tbody. Close with uiTableBodyEnd(). */
	public string function uiTableBody() {
		return '<tbody>';
	}

	public string function uiTableBodyEnd() {
		return '</tbody>';
	}

	/** Opens a table tr. Close with uiTableRowEnd(). */
	public string function uiTableRow(string class = "") {
		if (len(arguments.class))
			return '<tr class="#arguments.class#">';
		return '<tr>';
	}

	public string function uiTableRowEnd() {
		return '</tr>';
	}

	/** Renders a th cell. */
	public string function uiTableHead(string text = "", string class = "") {
		if (len(arguments.class))
			return '<th class="#arguments.class#">#arguments.text#</th>';
		return '<th>#arguments.text#</th>';
	}

	/** Renders a td cell. */
	public string function uiTableCell(string text = "", string class = "") {
		if (len(arguments.class))
			return '<td class="#arguments.class#">#arguments.text#</td>';
		return '<td>#arguments.text#</td>';
	}

	public string function uiTableEnd() {
		return '</table></div>';
	}

	// ==============================================
	// TABS  (driven by basecoat-js's tabs.js)
	// ==============================================
	//
	// basecoat-css 0.3.x styles tabs via ARIA-role selectors:
	//   .tabs [role=tablist]
	//   .tabs [role=tablist] [role=tab]
	//   .tabs [role=tabpanel]
	// The active tab carries `aria-selected="true"` + `tabindex="0"`; inactive
	// tabs carry `aria-selected="false"` + `tabindex="-1"`. Each tab's
	// `aria-controls` matches the panel's `id`. tabs.js handles click +
	// arrow-key navigation and toggles the `hidden` attribute on panels to
	// show/hide them.
	//
	// Use a `defaultTab` value on `uiTabs(...)`; trigger and content helpers
	// auto-activate when their `value` matches it. The defaultTab is stashed
	// in the request scope between `uiTabs()` and `uiTabsEnd()`.

	/** Opens a tabs container. Close with uiTabsEnd(). */
	public string function uiTabs(string defaultTab = "", string id = "", string class = "") {
		var cls = "tabs";
		if (len(arguments.class)) cls &= " " & arguments.class;
		// Stash the active value + a per-instance ID prefix so that nested
		// uiTabTrigger / uiTabContent helpers can auto-pair `aria-controls`.
		var prefix = $uiBuildId(arguments.id, "tabs");
		request.$basecoatTabs = {
			defaultTab: arguments.defaultTab,
			prefix: prefix
		};
		var idAttr = len(arguments.id) ? ' id="#arguments.id#"' : "";
		return '<div class="#cls#"#idAttr#>';
	}

	/** Opens the tablist (the row of triggers). Close with uiTabListEnd(). */
	public string function uiTabList(string ariaLabel = "Tabs", string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<div role="tablist" aria-label="#arguments.ariaLabel#"#classAttr#>';
	}

	public string function uiTabListEnd() {
		return '</div>';
	}

	/**
	 * Renders a tab trigger button. Auto-activates when its `value` matches
	 * the parent `uiTabs(defaultTab=)`. The `aria-controls` attribute targets
	 * the matching `uiTabContent(value=)` panel id.
	 */
	public string function uiTabTrigger(required string value, required string text, string class = "") {
		var ctx = StructKeyExists(request, "$basecoatTabs") ? request.$basecoatTabs : { defaultTab: "", prefix: "tabs" };
		var isActive = len(ctx.defaultTab) && ctx.defaultTab == arguments.value;
		var tabId = "#ctx.prefix#-tab-#arguments.value#";
		var panelId = "#ctx.prefix#-panel-#arguments.value#";
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<button type="button"'
			& ' id="#tabId#"'
			& ' role="tab"'
			& ' aria-controls="#panelId#"'
			& ' aria-selected="#isActive ? 'true' : 'false'#"'
			& ' tabindex="#isActive ? '0' : '-1'#"'
			& classAttr
			& '>#arguments.text#</button>';
	}

	/** Opens a tab content panel. Auto-hidden unless its `value` matches the parent default. Close with uiTabContentEnd(). */
	public string function uiTabContent(required string value, string class = "") {
		var ctx = StructKeyExists(request, "$basecoatTabs") ? request.$basecoatTabs : { defaultTab: "", prefix: "tabs" };
		var isActive = len(ctx.defaultTab) && ctx.defaultTab == arguments.value;
		var tabId = "#ctx.prefix#-tab-#arguments.value#";
		var panelId = "#ctx.prefix#-panel-#arguments.value#";
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<div'
			& ' id="#panelId#"'
			& ' role="tabpanel"'
			& ' aria-labelledby="#tabId#"'
			& ' tabindex="0"'
			& (isActive ? '' : ' hidden')
			& classAttr
			& '>';
	}

	public string function uiTabContentEnd() {
		return '</div>';
	}

	public string function uiTabsEnd() {
		StructDelete(request, "$basecoatTabs");
		return '</div>';
	}

	// ==============================================
	// DROPDOWNS  (driven by basecoat-js's dropdown-menu.js)
	// ==============================================
	//
	// basecoat-css 0.3.x dropdowns are built on the popover primitive:
	//   <div class="dropdown-menu">
	//     <button aria-expanded="false" aria-haspopup="menu">Trigger</button>
	//     <div data-popover aria-hidden="true">
	//       <div role="menu">
	//         <button role="menuitem">Item</button>
	//         <a role="menuitem" href="...">Linked item</a>
	//         <hr role="separator">
	//       </div>
	//     </div>
	//   </div>
	// dropdown-menu.js handles click + keyboard navigation, arrow keys to
	// move focus between items, Escape to dismiss, outside-click to close.
	// Items emit role="menuitem" (the JS also recognizes menuitemcheckbox /
	// menuitemradio if you need them, via direct uiDropdownCheckItem etc.
	// — out of scope for this rewrite).

	/** Opens a dropdown menu. Close with uiDropdownEnd(). */
	public string function uiDropdown(required string text, string triggerClass = "btn-outline", string class = "") {
		var cls = "dropdown-menu";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="#cls#">'
			& '<button type="button" class="#arguments.triggerClass#" aria-expanded="false" aria-haspopup="menu">#arguments.text#</button>'
			& '<div data-popover aria-hidden="true">'
			& '<div role="menu">';
	}

	/**
	 * Renders a dropdown menu item. With `href`, renders a navigation link
	 * (`<a>`); without, a `<button>`. Both carry `role="menuitem"` so
	 * dropdown-menu.js's keyboard navigation includes them.
	 */
	public string function uiDropdownItem(required string text, string href = "", string class = "", boolean disabled = false) {
		var idAttr = ' id="dditem-' & replace(left(createUUID(), 8), "-", "", "all") & '"';
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		var disAttr = arguments.disabled ? ' aria-disabled="true"' : "";
		if (len(arguments.href)) {
			return '<a role="menuitem"#idAttr# href="#arguments.href#"#classAttr##disAttr#>#arguments.text#</a>';
		}
		return '<button type="button" role="menuitem"#idAttr##classAttr##disAttr#>#arguments.text#</button>';
	}

	/** Renders a separator line inside a dropdown menu. */
	public string function uiDropdownSeparator() {
		return '<hr role="separator">';
	}

	public string function uiDropdownEnd() {
		return '</div></div></div>';
	}

	// ==============================================
	// PAGINATION
	// ==============================================

	/**
	 * Renders a pagination nav with prev/next, page window, and ellipsis.
	 */
	public string function uiPagination(
		required numeric currentPage,
		required numeric totalPages,
		required string baseUrl,
		string pageParam = "page",
		numeric windowSize = 2,
		string class = ""
	) {
		var local = {};
		local.cls = "pagination";
		if (len(arguments.class)) local.cls &= " " & arguments.class;

		// URL builder helper
		local.sep = (find("?", arguments.baseUrl) > 0) ? "&" : "?";
		local.prevIcon = $uiLucideIcon("chevron-left", 16, 2);
		local.nextIcon = $uiLucideIcon("chevron-right", 16, 2);

		savecontent variable="local.html" {
			writeOutput('<nav class="#local.cls#" aria-label="Pagination">' & chr(10));

			// Previous
			if (arguments.currentPage <= 1) {
				writeOutput('<span class="pagination-item opacity-50" aria-disabled="true">#local.prevIcon#</span>' & chr(10));
			} else {
				writeOutput('<a href="#arguments.baseUrl##local.sep##arguments.pageParam#=#arguments.currentPage - 1#" class="pagination-item" aria-label="Previous page">#local.prevIcon#</a>' & chr(10));
			}

			// Page window
			local.windowStart = max(1, arguments.currentPage - arguments.windowSize);
			local.windowEnd = min(arguments.totalPages, arguments.currentPage + arguments.windowSize);

			// First page + ellipsis
			if (local.windowStart > 1) {
				writeOutput('<a href="#arguments.baseUrl##local.sep##arguments.pageParam#=1" class="pagination-item">1</a>');
				if (local.windowStart > 2)
					writeOutput('<span class="pagination-item" aria-hidden="true">&hellip;</span>' & chr(10));
			}

			// Page numbers
			for (var p = local.windowStart; p <= local.windowEnd; p++) {
				if (p == arguments.currentPage) {
					writeOutput('<span class="pagination-item pagination-item-active" aria-current="page">#p#</span>' & chr(10));
				} else {
					writeOutput('<a href="#arguments.baseUrl##local.sep##arguments.pageParam#=#p#" class="pagination-item">#p#</a>' & chr(10));
				}
			}

			// Last page + ellipsis
			if (local.windowEnd < arguments.totalPages) {
				if (local.windowEnd < arguments.totalPages - 1)
					writeOutput('<span class="pagination-item" aria-hidden="true">&hellip;</span>' & chr(10));
				writeOutput('<a href="#arguments.baseUrl##local.sep##arguments.pageParam#=#arguments.totalPages#" class="pagination-item">#arguments.totalPages#</a>' & chr(10));
			}

			// Next
			if (arguments.currentPage >= arguments.totalPages) {
				writeOutput('<span class="pagination-item opacity-50" aria-disabled="true">#local.nextIcon#</span>' & chr(10));
			} else {
				writeOutput('<a href="#arguments.baseUrl##local.sep##arguments.pageParam#=#arguments.currentPage + 1#" class="pagination-item" aria-label="Next page">#local.nextIcon#</a>' & chr(10));
			}

			writeOutput('</nav>');
		}
		return trim(local.html);
	}

	// ==============================================
	// BREADCRUMB
	// ==============================================

	/** Opens a Basecoat breadcrumb nav. Close with uiBreadcrumbEnd(). */
	public string function uiBreadcrumb(string class = "") {
		var cls = "breadcrumb";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<nav aria-label="Breadcrumb" class="#cls#"><ol>';
	}

	/** Renders a breadcrumb item. Omit href for the current (last) page. */
	public string function uiBreadcrumbItem(required string text, string href = "") {
		if (len(arguments.href))
			return '<li><a href="#arguments.href#">#arguments.text#</a></li>';
		return '<li><span aria-current="page">#arguments.text#</span></li>';
	}

	/** Renders a breadcrumb separator (chevron-right icon). */
	public string function uiBreadcrumbSeparator() {
		var icon = $uiLucideIcon("chevron-right", 14, 2);
		return '<li aria-hidden="true">#icon#</li>';
	}

	public string function uiBreadcrumbEnd() {
		return '</ol></nav>';
	}

	// ==============================================
	// SIDEBAR  (driven by basecoat-js's sidebar.js)
	// ==============================================
	//
	// basecoat-css 0.3.x sidebar uses an `<aside class="sidebar">` containing
	// a single `<nav>` with `<header>`, `<section>`, and `<footer>` direct
	// children. Inside `<section>` you place one or more `<div role="group">`
	// containing an optional `<h3>` heading and a list of items. The whole
	// sidebar tracks its open/closed state via `aria-hidden` on the `<aside>`,
	// driven by sidebar.js, which also handles:
	//   - mobile-first responsive collapse at `data-breakpoint` (default 768px)
	//   - desktop default-open via `data-initial-open` (default true)
	//   - mobile default-collapsed via `data-initial-mobile-open` (default false)
	//   - basecoat:sidebar CustomEvent for external open/close/toggle
	//
	// Items are rendered as `<a>` (or `<button>`) with optional icon and an
	// `aria-current="page"` attribute when `active=true`.

	/**
	 * Opens a sidebar. Close with uiSidebarEnd().
	 *
	 * @side "left" (default) or "right".
	 * @initialOpen Default open state on desktop. Default true.
	 * @initialMobileOpen Default open state on mobile (below `breakpoint`). Default false.
	 * @breakpoint Pixel width below which the mobile behavior applies. Default 768.
	 * @id Element id (used by `basecoat:sidebar` CustomEvent listeners).
	 */
	public string function uiSidebar(
		string side = "left",
		boolean initialOpen = true,
		boolean initialMobileOpen = false,
		numeric breakpoint = 768,
		string id = "",
		string class = ""
	) {
		$validateEnum(arguments.side, "left,right", "uiSidebar", "side");
		var cls = "sidebar";
		if (len(arguments.class)) cls &= " " & arguments.class;
		var attrs = '';
		if (len(arguments.id)) attrs &= ' id="#arguments.id#"';
		attrs &= ' data-side="#arguments.side#"';
		if (!arguments.initialOpen) attrs &= ' data-initial-open="false"';
		if (arguments.initialMobileOpen) attrs &= ' data-initial-mobile-open="true"';
		if (arguments.breakpoint != 768) attrs &= ' data-breakpoint="#arguments.breakpoint#"';
		return '<aside class="#cls#"#attrs#><nav>';
	}

	/** Opens the sidebar header (title row, brand, etc.). Close with uiSidebarHeaderEnd(). */
	public string function uiSidebarHeader(string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<header#classAttr#>';
	}

	public string function uiSidebarHeaderEnd() {
		return '</header>';
	}

	/** Opens the scrollable body of the sidebar (the `<section>`). Close with uiSidebarBodyEnd(). */
	public string function uiSidebarBody(string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<section#classAttr#>';
	}

	public string function uiSidebarBodyEnd() {
		return '</section>';
	}

	/** Opens a group of items inside the sidebar body. Optional `title` renders as an `<h3>` heading. Close with uiSidebarGroupEnd(). */
	public string function uiSidebarGroup(string title = "", string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		var html = '<div role="group"#classAttr#>';
		if (len(arguments.title)) html &= '<h3>#arguments.title#</h3>';
		return html;
	}

	public string function uiSidebarGroupEnd() {
		return '</div>';
	}

	/**
	 * Renders a sidebar navigation item. Pass `active=true` to mark the
	 * current page (also sets `aria-current="page"` for screen readers).
	 */
	public string function uiSidebarItem(
		required string text,
		string href = "##",
		string icon = "",
		boolean active = false,
		string class = ""
	) {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		var iconHtml = len(arguments.icon) ? $uiLucideIcon(arguments.icon, 16, 2) : "";
		var aria = arguments.active ? ' aria-current="page"' : "";
		return '<a href="#arguments.href#"#classAttr##aria#>#iconHtml##arguments.text#</a>';
	}

	/** Renders a separator inside the sidebar body. */
	public string function uiSidebarSeparator() {
		return '<hr role="separator">';
	}

	/** Opens the sidebar footer (account widget, version, etc.). Close with uiSidebarFooterEnd(). */
	public string function uiSidebarFooter(string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<footer#classAttr#>';
	}

	public string function uiSidebarFooterEnd() {
		return '</footer>';
	}

	public string function uiSidebarEnd() {
		return '</nav></aside>';
	}

	/**
	 * Renders a button that toggles a sidebar's open state via the
	 * `basecoat:sidebar` CustomEvent that sidebar.js listens for.
	 *
	 * @sidebarId If empty, toggles the first sidebar on the page; otherwise
	 *            targets the matching `<aside id="..."> element.
	 * @action "toggle" (default), "open", or "close".
	 */
	public string function uiSidebarToggle(
		string text = "",
		string sidebarId = "",
		string action = "toggle",
		string icon = "menu",
		string class = "btn-icon-ghost",
		string ariaLabel = "Toggle sidebar"
	) {
		$validateEnum(arguments.action, "toggle,open,close", "uiSidebarToggle", "action");
		var inner = "";
		if (len(arguments.icon)) inner &= $uiLucideIcon(arguments.icon, 18);
		if (len(arguments.text)) inner &= " " & arguments.text;

		var dataAttrs = ' data-ui-sidebar-toggle="#arguments.action#"';
		if (len(arguments.sidebarId)) dataAttrs &= ' data-ui-sidebar-target="#arguments.sidebarId#"';
		var ariaAttr = len(arguments.text) ? "" : ' aria-label="#arguments.ariaLabel#"';
		return '<button type="button" class="#arguments.class#"#dataAttrs##ariaAttr#>#inner#</button>';
	}

	// ==============================================
	// TURBO STREAM HELPERS
	// ==============================================

	/**
	 * Sets the Turbo Stream Content-Type response header. Call once at the
	 * top of any partial that responds with `<turbo-stream>` elements. Turbo
	 * 8 is strict about Content-Type detection — without this header set,
	 * Turbo treats the response as plain HTML and tries to swap a frame,
	 * surfacing as "Content missing" inside the requesting frame.
	 *
	 * Returns the empty string for convenient inline use:
	 *
	 * <pre>
	 *   ##turboStreamHeader()##
	 *   ##turboStream(action="remove", target="post_##post.id##")##
	 * </pre>
	 */
	public string function turboStreamHeader() {
		cfheader(name="Content-Type", value="text/vnd.turbo-stream.html; charset=utf-8");
		return "";
	}

	/**
	 * Renders a `<turbo-stream>` element. For actions that carry HTML
	 * content (append, prepend, replace, update, before, after, morph),
	 * the helper opens the element + `<template>` and `turboStreamEnd()`
	 * closes both. For content-less actions (remove, refresh), the
	 * complete element is returned directly.
	 *
	 * @action append | prepend | replace | update | before | after | morph | remove | refresh
	 * @target Single element id to target. Mutually exclusive with `targets`.
	 * @targets CSS selector matching multiple targets. Mutually exclusive with `target`.
	 * @method For replace / update — `morph` to opt into morph-style replacement.
	 *
	 * <pre>
	 *   ##turboStream(action="append", target="comments")##
	 *     &lt;article id="comment_##comment.id##"&gt;...&lt;/article&gt;
	 *   ##turboStreamEnd()##
	 *
	 *   ##turboStream(action="remove", target="post_##post.id##")##
	 * </pre>
	 */
	public string function turboStream(
		required string action,
		string target = "",
		string targets = "",
		string method = ""
	) {
		$validateEnum(arguments.action, "append,prepend,replace,update,before,after,morph,remove,refresh", "turboStream", "action");
		var attrs = 'action="#arguments.action#"';
		if (len(arguments.target)) attrs &= ' target="#arguments.target#"';
		if (len(arguments.targets)) attrs &= ' targets="#arguments.targets#"';
		if (len(arguments.method)) attrs &= ' method="#arguments.method#"';

		// `remove` and `refresh` take no inner content — return the complete
		// element so the caller doesn't need to pair it with `turboStreamEnd`.
		if (arguments.action == "remove" || arguments.action == "refresh") {
			return '<turbo-stream #attrs#></turbo-stream>';
		}
		return '<turbo-stream #attrs#><template>';
	}

	/** Closes a `<turbo-stream>` opened with `turboStream(...)`. */
	public string function turboStreamEnd() {
		return '</template></turbo-stream>';
	}

	// ==============================================
	// THEME TOGGLE  (light / dark)
	// ==============================================

	/**
	 * Inline script that runs synchronously before paint to apply the
	 * saved theme preference (or fall back to `prefers-color-scheme`). Must
	 * be rendered in the `<head>` BEFORE the basecoat CSS link to avoid the
	 * "flash of light theme" on dark-loading pages.
	 *
	 * <pre>
	 *   ##basecoatThemeScript()##
	 *   ##basecoatIncludes()##
	 * </pre>
	 *
	 * @storageKey localStorage key. Default "basecoat:theme".
	 */
	public string function basecoatThemeScript(string storageKey = "basecoat:theme") {
		var local = {};
		savecontent variable="local.html" {
			writeOutput(
				'<script>(function(){try{'
				& 'var k=' & '"' & arguments.storageKey & '"' & ';'
				& 'var t=localStorage.getItem(k);'
				& 'if(!t){t=window.matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light";}'
				& 'if(t==="dark"){document.documentElement.classList.add("dark");}'
				& '}catch(e){}})();</script>'
			);
		}
		return trim(local.html);
	}

	/**
	 * Renders a theme toggle button. Click flips the `.dark` class on
	 * `<html>` and writes the choice to localStorage. Pair with
	 * `basecoatThemeScript()` in the layout `<head>` so the saved theme is
	 * applied before first paint.
	 *
	 * @size sm | md | lg (passes through to uiButton).
	 * @class Extra classes appended to the button.
	 * @storageKey localStorage key. Must match `basecoatThemeScript`.
	 */
	public string function uiThemeToggle(
		string size = "sm",
		string class = "",
		string storageKey = "basecoat:theme",
		string ariaLabel = "Toggle theme"
	) {
		$validateEnum(arguments.size, "sm,md,lg", "uiThemeToggle", "size");
		var local = {};
		local.sun  = $uiLucideIcon("sun", 18);
		local.moon = $uiLucideIcon("moon", 18);
		local.cls  = arguments.size == "md" ? "btn-icon-ghost" : "btn-#arguments.size#-icon-ghost";
		if (len(arguments.class)) local.cls &= " " & arguments.class;

		savecontent variable="local.html" {
			writeOutput(
				'<button type="button" class="#local.cls#" aria-label="#arguments.ariaLabel#" '
				& 'data-ui-theme-toggle="#arguments.storageKey#">'
				& '<span class="hidden dark:inline-flex">' & local.sun & '</span>'
				& '<span class="inline-flex dark:hidden">' & local.moon & '</span>'
				& '</button>'
			);
		}
		return trim(local.html);
	}

	// ==============================================
	// BUTTON GROUP
	// ==============================================

	/**
	 * Renders a button-group container. basecoat-css 0.3.x styles the joined
	 * borders so adjacent buttons read as a single connected control. Place
	 * any combination of `uiButton`, `uiDropdown`, or `uiPopover` inside;
	 * use `uiButtonGroupSeparator()` to inject a visual divider.
	 *
	 * @orientation "horizontal" (default) or "vertical".
	 */
	public string function uiButtonGroup(string orientation = "horizontal", string class = "") {
		$validateEnum(arguments.orientation, "horizontal,vertical", "uiButtonGroup", "orientation");
		var cls = "button-group";
		if (len(arguments.class)) cls &= " " & arguments.class;
		var dataAttr = arguments.orientation == "vertical" ? ' data-orientation="vertical"' : "";
		return '<div class="#cls#"#dataAttr# role="group">';
	}

	/** Vertical/horizontal-aware separator inside a button-group. */
	public string function uiButtonGroupSeparator() {
		return '<hr role="separator">';
	}

	public string function uiButtonGroupEnd() {
		return '</div>';
	}

	// ==============================================
	// FIELDSET  (groups related form fields under a legend)
	// ==============================================

	/**
	 * Opens a `<fieldset>` styled by basecoat-css's `.fieldset` rule. Pass
	 * `legend` for the fieldset heading and `description` for the
	 * sentence-cased helper text below it.
	 */
	public string function uiFieldset(string legend = "", string description = "", string class = "") {
		var cls = "fieldset";
		if (len(arguments.class)) cls &= " " & arguments.class;
		var local = {};
		savecontent variable="local.html" {
			writeOutput('<fieldset class="#cls#">' & chr(10));
			if (len(arguments.legend)) writeOutput('<legend>#arguments.legend#</legend>' & chr(10));
			if (len(arguments.description)) writeOutput('<p>#arguments.description#</p>' & chr(10));
		}
		return trim(local.html);
	}

	public string function uiFieldsetEnd() {
		return '</fieldset>';
	}

	// ==============================================
	// POPOVER  (driven by basecoat-js's popover.js)
	// ==============================================

	/**
	 * Opens a Basecoat popover. Place a single trigger `<button>` and a single
	 * `<div data-popover>` content region inside; `uiPopoverTrigger` and
	 * `uiPopoverContent` make those easy. Close the popover wrapper with
	 * `uiPopoverEnd`.
	 */
	public string function uiPopover(string class = "") {
		var cls = "popover";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="#cls#">';
	}

	/**
	 * Renders the trigger button for a popover. basecoat-js wires the click
	 * handler that toggles `aria-expanded`; the matching `<div data-popover>`
	 * inside the same wrapper toggles `aria-hidden` accordingly.
	 *
	 * @triggerClass basecoat button class for the trigger (e.g. "btn-outline").
	 */
	public string function uiPopoverTrigger(required string text, string triggerClass = "btn-outline", string class = "") {
		var cls = arguments.triggerClass;
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<button type="button" class="#cls#" aria-expanded="false">#arguments.text#</button>';
	}

	/** Opens the popover content region. Close with `uiPopoverContentEnd`. */
	public string function uiPopoverContent(string class = "") {
		var attrs = 'data-popover aria-hidden="true"';
		if (len(arguments.class)) attrs &= ' class="#arguments.class#"';
		return '<div #attrs#>';
	}

	public string function uiPopoverContentEnd() {
		return '</div>';
	}

	public string function uiPopoverEnd() {
		return '</div>';
	}

	// ==============================================
	// AVATAR
	// ==============================================

	/**
	 * Renders an avatar. Pass `src` for an image avatar, or rely on `text`
	 * (typically initials) for a fallback avatar with a tinted background.
	 *
	 * basecoat-css 0.3.x doesn't ship a `.avatar` class so this helper
	 * composes from utility-friendly classes that work alongside it.
	 *
	 * @size px diameter — 32 (sm), 40 (default), 48 (lg).
	 */
	public string function uiAvatar(
		string src = "",
		string text = "?",
		string alt = "",
		numeric size = 40,
		string class = ""
	) {
		var local = {};
		local.cls = "inline-flex items-center justify-center overflow-hidden rounded-full bg-muted text-muted-foreground select-none shrink-0";
		if (len(arguments.class)) local.cls &= " " & arguments.class;
		local.style = 'width: #arguments.size#px; height: #arguments.size#px; font-size: #int(arguments.size * 0.4)#px; font-weight: 600;';

		if (len(arguments.src)) {
			return '<span class="#local.cls#" style="#local.style#"><img src="#arguments.src#" alt="#arguments.alt#" class="w-full h-full object-cover"></span>';
		}
		return '<span class="#local.cls#" style="#local.style#" aria-label="#arguments.alt#">#arguments.text#</span>';
	}

	// ==============================================
	// KEYBOARD KEY (KBD)
	// ==============================================

	/**
	 * Renders a keyboard key indicator: `<kbd class="kbd">⌘K</kbd>`. Useful
	 * inline alongside menu labels and command palettes.
	 */
	public string function uiKbd(required string text, string class = "") {
		var cls = "kbd";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<kbd class="#cls#">#arguments.text#</kbd>';
	}

	// ==============================================
	// TOAST + TOASTER  (driven by basecoat-js's toast.js)
	// ==============================================

	/**
	 * Renders the singleton toast container. Place once per layout, typically
	 * right before `</body>`. basecoat-js attaches to `#toaster` and animates
	 * any `<div class="toast">` children in/out.
	 */
	public string function uiToaster(string id = "toaster", string class = "") {
		var cls = "toaster";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div id="#arguments.id#" class="#cls#" aria-live="polite" aria-atomic="true"></div>';
	}

	/**
	 * Render a server-rendered toast inside a toaster — for SSR cases where
	 * you want a toast visible on first paint (e.g. flash messages after a
	 * redirect). For client-driven toasts, dispatch a `basecoat:toast`
	 * CustomEvent on `document` instead.
	 *
	 * @variant info | success | warning | error
	 * @duration Display duration in ms. -1 (default) lets basecoat-js pick (3000 normal, 5000 error).
	 */
	public string function uiToast(
		string title = "",
		string description = "",
		string variant = "info",
		numeric duration = -1,
		string class = ""
	) {
		$validateEnum(arguments.variant, "info,success,warning,error", "uiToast", "variant");
		var local = {};
		local.cls = "toast";
		if (len(arguments.class)) local.cls &= " " & arguments.class;
		local.role = arguments.variant == "error" ? "alert" : "status";
		local.iconMap = {
			"success": "check-circle",
			"error":   "x",
			"info":    "info",
			"warning": "alert-triangle"
		};
		local.icon = $uiLucideIcon(local.iconMap[arguments.variant], 24);
		local.durationAttr = arguments.duration GTE 0 ? ' data-duration="#arguments.duration#"' : "";

		savecontent variable="local.html" {
			writeOutput(
				'<div class="#local.cls#" role="#local.role#" aria-atomic="true" data-category="#arguments.variant#"#local.durationAttr#>' & chr(10)
				& '<div class="toast-content">' & chr(10)
				& local.icon & chr(10)
				& '<section>' & chr(10)
				& (len(arguments.title) ? '<h2>#arguments.title#</h2>' & chr(10) : '')
				& (len(arguments.description) ? '<p>#arguments.description#</p>' & chr(10) : '')
				& '</section>' & chr(10)
				& '</div>' & chr(10)
				& '</div>'
			);
		}
		return trim(local.html);
	}

	/**
	 * One-call replacement for Wheels' `flashMessages()` that surfaces every
	 * entry as a basecoat toast. Reads the controller-scoped `flash()` map and
	 * renders a toaster containing a toast per entry. Standard flash keys
	 * (`success`, `error`, `warning`, `info`, plus the legacy `notice`) map
	 * to the matching toast variant; unrecognized keys fall back to `info`.
	 *
	 * Drop-in usage in a layout:
	 *
	 * <pre>
	 *   ##basecoatFlashToasts()##
	 * </pre>
	 *
	 * Render this once per layout, near the end of `<body>`. Calling it more
	 * than once on the same page will produce duplicate toaster IDs and
	 * basecoat-js will only attach to the first.
	 */
	public string function basecoatFlashToasts(string toasterId = "toaster") {
		var local = {};
		local.f = {};
		try {
			local.f = flash();
		} catch (any e) {
			return uiToaster(id = arguments.toasterId);
		}
		if (StructIsEmpty(local.f)) return uiToaster(id = arguments.toasterId);

		local.variantMap = {
			"success":"success", "error":"error", "info":"info",
			"warning":"warning", "notice":"info"
		};

		savecontent variable="local.html" {
			writeOutput('<div id="#arguments.toasterId#" class="toaster" aria-live="polite" aria-atomic="true">' & chr(10));
			for (var key in local.f) {
				var v = StructKeyExists(local.variantMap, lcase(key)) ? local.variantMap[lcase(key)] : "info";
				writeOutput(uiToast(description = local.f[key], variant = v) & chr(10));
			}
			writeOutput('</div>');
		}
		return trim(local.html);
	}

	// ==============================================
	// COMMAND PALETTE  (driven by basecoat-js's command.js)
	// ==============================================
	//
	// basecoat-css 0.3.x ships `.command` and `.command-dialog` styles.
	// command.js wires the search input to filter [role=menuitem] items
	// (matching by `data-filter`/`textContent` plus optional `data-keywords`),
	// arrow-key + Home/End + Enter navigation, and click-to-close behavior
	// when nested in a `<dialog class="command-dialog">`.
	//
	//   <div class="command">
	//     <header><input type="text" placeholder="Search..."></header>
	//     <div role="menu">
	//       <div role="group" aria-label="Suggestions">
	//         <button role="menuitem" data-keywords="...">Item</button>
	//       </div>
	//       <hr role="separator">
	//       <div role="group" aria-label="Actions">
	//         <button role="menuitem" data-keep-command-open>Toggle theme</button>
	//       </div>
	//     </div>
	//   </div>
	//
	// For a ⌘K-style modal palette, wrap the command in `uiCommandDialog`.

	/** Opens a command palette container. Close with uiCommandEnd(). */
	public string function uiCommand(string class = "") {
		var cls = "command";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="#cls#">';
	}

	/**
	 * Renders the search input row of a command palette.
	 * basecoat-js attaches an `input` listener that filters items by their
	 * `data-filter` / textContent / `data-keywords`.
	 */
	public string function uiCommandInput(
		string placeholder = "Search...",
		string ariaLabel = "Search commands",
		string class = ""
	) {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<header><input type="text" placeholder="#arguments.placeholder#" aria-label="#arguments.ariaLabel#"#classAttr#></header>';
	}

	/** Opens the menu list of a command palette. Close with uiCommandListEnd(). */
	public string function uiCommandList(string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<div role="menu"#classAttr#>';
	}

	public string function uiCommandListEnd() {
		return '</div>';
	}

	/** Opens a labeled group inside a command list. Close with uiCommandGroupEnd(). */
	public string function uiCommandGroup(required string label, string class = "") {
		var classAttr = len(arguments.class) ? ' class="#arguments.class#"' : "";
		return '<div role="group" aria-label="#arguments.label#"#classAttr#>';
	}

	public string function uiCommandGroupEnd() {
		return '</div>';
	}

	/**
	 * Renders a command palette item. With `href`, renders a navigation link
	 * (`<a>`); without, a `<button>` for JS-driven actions. Both carry
	 * `role="menuitem"` so command.js's filter + keyboard nav include them.
	 *
	 * @keywords Space- or comma-separated extra search terms (basecoat-js
	 *           includes substring matches against these).
	 * @icon Lucide icon name to render before the label.
	 * @kbd Optional keyboard shortcut hint, rendered to the right.
	 * @force `true` keeps the item visible regardless of the input filter.
	 *        Use sparingly — typically for "no results" placeholders.
	 * @keepOpen When the command is inside a command-dialog, prevents the
	 *           dialog from closing on item click.
	 */
	public string function uiCommandItem(
		required string text,
		string href = "",
		string keywords = "",
		string icon = "",
		string kbd = "",
		boolean force = false,
		boolean keepOpen = false,
		boolean disabled = false,
		string class = ""
	) {
		var attrs = ' role="menuitem"';
		if (len(arguments.keywords)) attrs &= ' data-keywords="#arguments.keywords#"';
		if (arguments.force) attrs &= ' data-force';
		if (arguments.keepOpen) attrs &= ' data-keep-command-open';
		if (arguments.disabled) attrs &= ' aria-disabled="true"';
		if (len(arguments.class)) attrs &= ' class="#arguments.class#"';

		var inner = "";
		if (len(arguments.icon)) inner &= $uiLucideIcon(arguments.icon, 16);
		inner &= '<span>#arguments.text#</span>';
		if (len(arguments.kbd)) inner &= '<kbd class="kbd">#arguments.kbd#</kbd>';

		if (len(arguments.href)) {
			return '<a href="#arguments.href#"#attrs#>#inner#</a>';
		}
		return '<button type="button"#attrs#>#inner#</button>';
	}

	public string function uiCommandSeparator() {
		return '<hr role="separator">';
	}

	/** Renders a static "no results" placeholder. Pair with `force=true` for
	    items you want visible regardless of the search query. */
	public string function uiCommandEmpty(string text = "No results.", string class = "") {
		var cls = "command-empty";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<div class="#cls#" data-force>#arguments.text#</div>';
	}

	public string function uiCommandEnd() {
		return '</div>';
	}

	/**
	 * Wraps a command palette in a `<dialog class="command-dialog">` so it
	 * presents as a ⌘K-style modal. Renders an optional trigger button.
	 * Open via `data-ui-dialog-open="<id>"` (handled by wheels-basecoat-ui.js),
	 * or programmatically via `document.getElementById(id).showModal()`.
	 */
	public string function uiCommandDialog(
		string triggerText = "",
		string triggerClass = "btn-outline",
		string id = "",
		string class = ""
	) {
		var local = {};
		local.id = $uiBuildId(arguments.id, "cmddlg");
		local.cls = "dialog command-dialog";
		if (len(arguments.class)) local.cls &= " " & arguments.class;

		savecontent variable="local.html" {
			writeOutput(
				(len(arguments.triggerText) ? '<button type="button" data-ui-dialog-open="#local.id#" class="#arguments.triggerClass#">#arguments.triggerText#</button>' & chr(10) : '')
				& '<dialog id="#local.id#" class="#local.cls#" aria-label="Command palette">'
			);
		}
		return trim(local.html);
	}

	public string function uiCommandDialogEnd() {
		return '</dialog>';
	}

	// ==============================================
	// SELECT  (rich combobox driven by basecoat-js's select.js)
	// ==============================================
	//
	// Different from `uiField(type="select")` which wraps the native
	// <select> element. This is the basecoat-css 0.3.x .select component:
	// a popover-driven combobox with optional search filtering, multi-select,
	// keyboard navigation, and a hidden input for form submission.
	//
	//   <div class="select" data-placeholder="Pick one">
	//     <button aria-expanded="false" aria-haspopup="listbox">
	//       <span>Selected label</span>
	//     </button>
	//     <div data-popover aria-hidden="true">
	//       <header><input type="text" placeholder="Search..."></header>
	//       <div role="listbox">
	//         <div role="option" data-value="a">Apple</div>
	//         …
	//       </div>
	//     </div>
	//     <input type="hidden" name="fruit" value="a">
	//   </div>

	/**
	 * Renders a basecoat select / combobox in one call.
	 *
	 * @name Hidden input name for form submission. Required.
	 * @options "value:Label[:disabled],value:Label" — same shape as `uiField(type=select)`.
	 *          Append `:disabled` as a third segment to disable that option.
	 * @value Initial selected value. For multiselect, pass a JSON-encoded
	 *        array string ('["a","b"]') or a comma-separated list.
	 * @placeholder Shown when nothing is selected.
	 * @search Render the search input in the popover header.
	 * @multiselect Allow multiple selections; hidden input emits a JSON array.
	 * @closeOnSelect Close the popover after each selection (single-select default leaves it open
	 *                only when multi; pass `true` to override).
	 */
	public string function uiSelect(
		required string name,
		required string options,
		string value = "",
		string placeholder = "Select an option",
		boolean search = false,
		boolean multiselect = false,
		boolean closeOnSelect = false,
		string id = "",
		string class = ""
	) {
		var local = {};
		local.id = $uiBuildId(arguments.id, "sel");
		local.cls = "select";
		if (len(arguments.class)) local.cls &= " " & arguments.class;

		// Parse the options string into an array of {value, label, disabled}.
		local.parsed = [];
		for (var opt in listToArray(arguments.options)) {
			var parts = listToArray(opt, ":");
			arrayAppend(local.parsed, {
				value: parts[1],
				label: arrayLen(parts) >= 2 ? parts[2] : parts[1],
				disabled: arrayLen(parts) >= 3 && parts[3] == "disabled"
			});
		}

		// Resolve initial selection. Multiselect can arrive as JSON or CSV.
		local.selected = [];
		if (arguments.multiselect && len(arguments.value)) {
			try {
				var asJson = deserializeJSON(arguments.value);
				local.selected = isArray(asJson) ? asJson : [arguments.value];
			} catch (any e) {
				local.selected = listToArray(arguments.value);
			}
		} else if (len(arguments.value)) {
			local.selected = [arguments.value];
		}

		// Pre-render the trigger label so there's no FOUC before select.js inits.
		local.triggerLabel = arguments.placeholder;
		local.triggerClass = "text-muted-foreground";
		if (arrayLen(local.selected)) {
			local.matched = [];
			for (var item in local.parsed) {
				if (arrayFind(local.selected, item.value)) arrayAppend(local.matched, item.label);
			}
			if (arrayLen(local.matched)) {
				local.triggerLabel = arrayToList(local.matched, ", ");
				local.triggerClass = "";
			}
		}

		// Hidden input value: JSON array for multi, plain string for single.
		local.hiddenValue = arguments.multiselect
			? serializeJSON(local.selected)
			: (arrayLen(local.selected) ? local.selected[1] : "");

		savecontent variable="local.html" {
			var dataAttrs = ' data-placeholder="#arguments.placeholder#"';
			if (arguments.closeOnSelect) dataAttrs &= ' data-close-on-select="true"';
			writeOutput('<div class="#local.cls#" id="#local.id#"#dataAttrs#>' & chr(10));

			writeOutput('<button type="button" aria-expanded="false" aria-haspopup="listbox" aria-controls="#local.id#-listbox">' & chr(10));
			var spanCls = len(local.triggerClass) ? ' class="#local.triggerClass#"' : "";
			writeOutput('<span#spanCls#>#local.triggerLabel#</span>' & chr(10));
			writeOutput('</button>' & chr(10));

			writeOutput('<div data-popover aria-hidden="true">' & chr(10));
			if (arguments.search) {
				writeOutput('<header><input type="text" placeholder="Search..." aria-label="Search options"></header>' & chr(10));
			}
			writeOutput('<div role="listbox" id="#local.id#-listbox"');
			if (arguments.multiselect) writeOutput(' aria-multiselectable="true"');
			writeOutput('>' & chr(10));
			var idx = 0;
			for (var item in local.parsed) {
				idx++;
				var optId = "#local.id#-opt-#idx#";
				var isSel = arrayFind(local.selected, item.value) > 0;
				writeOutput('<div role="option" id="#optId#" data-value="#item.value#"');
				if (isSel) writeOutput(' aria-selected="true"');
				if (item.disabled) writeOutput(' aria-disabled="true"');
				writeOutput('>#item.label#</div>' & chr(10));
			}
			writeOutput('</div>' & chr(10));
			writeOutput('</div>' & chr(10));

			writeOutput('<input type="hidden" name="#arguments.name#" value="#htmlEditFormat(local.hiddenValue)#">' & chr(10));
			writeOutput('</div>');
		}
		return trim(local.html);
	}

	/**
	 * Wheels-bound variant of `uiSelect`. Auto-resolves the model value
	 * (single-string for single-select; JSON-array string for multiselect)
	 * and emits a `name="<objectName>[<property>]"` hidden input — same
	 * shape as `uiBoundField` does for ad-hoc inputs.
	 *
	 * <pre>
	 *   ##uiBoundSelect(objectName="post", property="status",
	 *                   options="draft:Draft,published:Published,archived:Archived")##
	 * </pre>
	 */
	public string function uiBoundSelect(
		required string objectName,
		required string property,
		required string options,
		string placeholder = "Select an option",
		boolean search = false,
		boolean multiselect = false,
		boolean closeOnSelect = false,
		string id = "",
		string class = ""
	) {
		if (!structKeyExists(variables, arguments.objectName)) {
			throw(
				type = "WheelsBasecoat.ObjectNotFound",
				message = "uiBoundSelect: object '#arguments.objectName#' not found in the current scope."
			);
		}
		var obj = variables[arguments.objectName];

		// Resolve value. Multiselect tolerates either a JSON-array string,
		// a CSV string, or a real array on the model.
		var resolvedValue = "";
		try {
			var raw = obj[arguments.property] ?: "";
			if (arguments.multiselect && IsArray(raw)) {
				resolvedValue = serializeJSON(raw);
			} else {
				resolvedValue = raw;
			}
		} catch (any e) {
			resolvedValue = "";
		}

		return uiSelect(
			name = "#arguments.objectName#[#arguments.property#]",
			options = arguments.options,
			value = resolvedValue,
			placeholder = arguments.placeholder,
			search = arguments.search,
			multiselect = arguments.multiselect,
			closeOnSelect = arguments.closeOnSelect,
			id = arguments.id,
			class = arguments.class
		);
	}

	// ==============================================
	// SLIDER  (styled <input type="range"> with --slider-value fill)
	// ==============================================
	//
	// basecoat-css 0.3.x styles `input[type=range]` with a CSS variable
	// `--slider-value` that drives the filled portion of the track. We
	// compute the current percentage server-side and emit `style` + the
	// `aria-valuetext`, so the slider renders with the right fill on
	// first paint (no JS needed).

	/**
	 * Renders a basecoat-styled range slider.
	 *
	 * @name Form input name. Required.
	 * @value Current value. Defaults to halfway between min and max.
	 * @min Minimum value. Default 0.
	 * @max Maximum value. Default 100.
	 * @step Step increment. Default 1.
	 * @label Optional label text rendered above the slider.
	 * @showValue Render the current value to the right of the slider.
	 * @id Optional input id. Auto-generated if omitted.
	 */
	public string function uiSlider(
		required string name,
		any value = "",
		numeric min = 0,
		numeric max = 100,
		numeric step = 1,
		string label = "",
		boolean showValue = false,
		boolean disabled = false,
		string id = "",
		string class = ""
	) {
		var local = {};
		local.id = $uiBuildId(arguments.id, "slider");
		local.val = len(arguments.value) ? arguments.value : (arguments.min + arguments.max) / 2;
		// Clamp + percentage for the fill var.
		local.range = arguments.max - arguments.min;
		local.pct = local.range == 0 ? 0 : ((local.val - arguments.min) / local.range) * 100;
		if (local.pct < 0) local.pct = 0;
		if (local.pct > 100) local.pct = 100;
		local.attrs = 'id="#local.id#" name="#arguments.name#" type="range"'
			& ' min="#arguments.min#" max="#arguments.max#" step="#arguments.step#"'
			& ' value="#local.val#"'
			& ' style="--slider-value: #numberFormat(local.pct, '0.##')#%"'
			& ' aria-valuemin="#arguments.min#" aria-valuemax="#arguments.max#" aria-valuenow="#local.val#"';
		if (arguments.disabled) local.attrs &= " disabled";
		if (len(arguments.class)) local.attrs &= ' class="#arguments.class#"';

		savecontent variable="local.html" {
			writeOutput('<div class="grid gap-2">' & chr(10));
			if (len(arguments.label)) {
				writeOutput('<label for="#local.id#">#arguments.label#</label>' & chr(10));
			}
			if (arguments.showValue) {
				writeOutput('<div class="flex items-center gap-3">' & chr(10));
				writeOutput('<input #local.attrs# class="flex-1">' & chr(10));
				writeOutput('<output for="#local.id#" data-ui-slider-output class="text-sm tabular-nums w-12 text-right">#local.val#</output>' & chr(10));
				writeOutput('</div>');
			} else {
				writeOutput('<input #local.attrs#>');
			}
			writeOutput('</div>');
		}
		return trim(local.html);
	}

	/**
	 * Wheels-bound variant of `uiSlider`. Auto-resolves the value from
	 * the model and emits `name="<objectName>[<property>]"`. Label
	 * defaults to the humanized property name (matching `uiBoundField`).
	 */
	public string function uiBoundSlider(
		required string objectName,
		required string property,
		numeric min = 0,
		numeric max = 100,
		numeric step = 1,
		string label = "",
		boolean showValue = false,
		boolean disabled = false,
		string id = "",
		string class = ""
	) {
		if (!structKeyExists(variables, arguments.objectName)) {
			throw(
				type = "WheelsBasecoat.ObjectNotFound",
				message = "uiBoundSlider: object '#arguments.objectName#' not found in the current scope."
			);
		}
		var obj = variables[arguments.objectName];
		var val = "";
		try { val = obj[arguments.property] ?: ""; } catch (any e) { val = ""; }
		return uiSlider(
			name = "#arguments.objectName#[#arguments.property#]",
			value = val,
			min = arguments.min,
			max = arguments.max,
			step = arguments.step,
			label = len(arguments.label) ? arguments.label : $humanize(arguments.property),
			showValue = arguments.showValue,
			disabled = arguments.disabled,
			id = arguments.id,
			class = arguments.class
		);
	}

	// ==============================================
	// STEPS  (multi-step / wizard progress indicator)
	// ==============================================
	//
	// basecoat-css 0.3.x doesn't ship a stepper component. The output
	// uses semantic `<ol>` + `aria-current="step"` + status data
	// attributes that the bundled wheels-basecoat-extras.min.css styles
	// (numbered circles, a connecting line, color-coding by status).
	//
	//   <ol class="ui-steps">
	//     <li data-status="complete"><span class="ui-step-marker">1</span><span class="ui-step-label">Account</span></li>
	//     <li data-status="current" aria-current="step"><span class="ui-step-marker">2</span>…</li>
	//     <li data-status="upcoming"><span class="ui-step-marker">3</span>…</li>
	//   </ol>

	/** Opens a steps progress indicator. Close with uiStepsEnd(). */
	public string function uiSteps(string ariaLabel = "Progress", string class = "") {
		var cls = "ui-steps";
		if (len(arguments.class)) cls &= " " & arguments.class;
		return '<nav aria-label="#arguments.ariaLabel#"><ol class="#cls#">';
	}

	/**
	 * Renders a single step. Status drives styling and ARIA:
	 *   - "complete": done, with a check icon
	 *   - "current":  active step, sets aria-current="step"
	 *   - "upcoming": future step
	 *
	 * Pass `number` for the marker (defaults to incrementing counter
	 * tracked in request scope between uiSteps / uiStepsEnd).
	 */
	public string function uiStep(
		required string text,
		string status = "upcoming",
		string number = "",
		string description = "",
		string href = ""
	) {
		$validateEnum(arguments.status, "complete,current,upcoming", "uiStep", "status");
		// Auto-increment number when caller doesn't pass one.
		if (!structKeyExists(request, "$basecoatStepCounter")) request.$basecoatStepCounter = 0;
		request.$basecoatStepCounter++;
		var n = len(arguments.number) ? arguments.number : request.$basecoatStepCounter;

		var marker = "";
		if (arguments.status == "complete") {
			marker = $uiLucideIcon("check", 14);
		} else {
			marker = n;
		}

		var aria = arguments.status == "current" ? ' aria-current="step"' : "";
		var labelHtml = '<span class="ui-step-label">#arguments.text#</span>';
		if (len(arguments.description)) {
			labelHtml &= '<span class="ui-step-description">#arguments.description#</span>';
		}
		var inner = '<span class="ui-step-marker">#marker#</span><span class="ui-step-text">#labelHtml#</span>';
		if (len(arguments.href) && arguments.status != "current") {
			inner = '<a href="#arguments.href#" class="ui-step-link">' & inner & '</a>';
		}
		return '<li data-status="#arguments.status#"#aria#>#inner#</li>';
	}

	public string function uiStepsEnd() {
		StructDelete(request, "$basecoatStepCounter");
		return '</ol></nav>';
	}

	// ==============================================
	// BOUND CHECKBOX (single boolean)
	// ==============================================

	/**
	 * Wheels-bound single checkbox or switch.
	 *
	 * Solves the standard "unchecked checkbox submits nothing" footgun by
	 * emitting a hidden input with the same name + falsy value BEFORE the
	 * checkbox. The browser submits both; the controller receives the
	 * later (checkbox) value when checked, the falsy hidden value when
	 * not. So `params.<obj>.<prop>` is always defined as `0` or `1`.
	 */
	public string function uiBoundCheckbox(
		required string objectName,
		required string property,
		string label = "",
		boolean switch = false,
		string description = "",
		boolean disabled = false,
		string id = "",
		string class = ""
	) {
		if (!structKeyExists(variables, arguments.objectName)) {
			throw(
				type = "WheelsBasecoat.ObjectNotFound",
				message = "uiBoundCheckbox: object '#arguments.objectName#' not found in the current scope."
			);
		}
		var obj = variables[arguments.objectName];
		var raw = "";
		try { raw = obj[arguments.property] ?: ""; } catch (any e) { raw = ""; }
		var checked = (IsBoolean(raw) && raw) || (IsNumeric(raw) && raw != 0);

		var name = "#arguments.objectName#[#arguments.property#]";
		var resolvedLabel = len(arguments.label) ? arguments.label : $humanize(arguments.property);
		var inputId = $uiBuildId(arguments.id, "fld");
		var inputCls = arguments.switch ? "switch" : "checkbox";
		if (len(arguments.class)) inputCls &= " " & arguments.class;
		var roleAttr = arguments.switch ? ' role="switch"' : "";
		var disAttr = arguments.disabled ? " disabled" : "";

		var local = {};
		savecontent variable="local.html" {
			writeOutput('<div class="grid gap-2">' & chr(10));
			writeOutput('<div class="flex items-center gap-2">' & chr(10));
			writeOutput('<input type="hidden" name="#name#" value="0">' & chr(10));
			writeOutput(
				'<input type="checkbox" id="#inputId#" name="#name#" value="1"'
				& ' class="#inputCls#"#roleAttr##disAttr#'
				& (checked ? " checked" : "")
				& ' />' & chr(10)
			);
			writeOutput('<label for="#inputId#">#resolvedLabel#</label>' & chr(10));
			writeOutput('</div>' & chr(10));
			if (len(arguments.description)) {
				writeOutput('<p class="text-sm text-muted-foreground">#arguments.description#</p>' & chr(10));
			}
			writeOutput('</div>');
		}
		return trim(local.html);
	}

	// ==============================================
	// CHECKBOX GROUP (multi-value) + bound variant
	// ==============================================

	/**
	 * Group of checkboxes posting an array under the same name (`name[]`).
	 *
	 * @options Same shape as uiSelect: "value:Label[:disabled],..."
	 * @value Initial selected values — comma-separated string, JSON array, or real CFML array.
	 */
	public string function uiCheckboxGroup(
		required string name,
		required string options,
		any value = "",
		string legend = "",
		string description = "",
		boolean inline = false,
		string class = ""
	) {
		var local = {};
		local.selected = [];
		if (IsArray(arguments.value)) {
			local.selected = arguments.value;
		} else if (Len(arguments.value)) {
			try {
				var asJson = deserializeJSON(arguments.value);
				local.selected = isArray(asJson) ? asJson : [arguments.value];
			} catch (any e) {
				local.selected = listToArray(arguments.value);
			}
		}

		local.parsed = [];
		for (var opt in listToArray(arguments.options)) {
			var parts = listToArray(opt, ":");
			arrayAppend(local.parsed, {
				value: parts[1],
				label: arrayLen(parts) >= 2 ? parts[2] : parts[1],
				disabled: arrayLen(parts) >= 3 && parts[3] == "disabled"
			});
		}

		local.itemsCls = arguments.inline ? "flex flex-wrap gap-x-4 gap-y-2" : "grid gap-2";
		local.fieldsetCls = "fieldset";
		if (len(arguments.class)) local.fieldsetCls &= " " & arguments.class;

		savecontent variable="local.html" {
			writeOutput('<fieldset class="#local.fieldsetCls#">' & chr(10));
			if (len(arguments.legend)) writeOutput('<legend>#arguments.legend#</legend>' & chr(10));
			if (len(arguments.description)) writeOutput('<p>#arguments.description#</p>' & chr(10));
			writeOutput('<div class="#local.itemsCls#">' & chr(10));
			var idx = 0;
			for (var item in local.parsed) {
				idx++;
				var cbId = "cbg-" & replace(left(createUUID(), 8), "-", "", "all") & "-" & idx;
				var checked = arrayFind(local.selected, item.value) > 0;
				writeOutput('<div class="flex items-center gap-2">' & chr(10));
				writeOutput('<input type="checkbox" id="#cbId#" name="#arguments.name#[]" value="#item.value#" class="checkbox"');
				if (checked) writeOutput(" checked");
				if (item.disabled) writeOutput(" disabled");
				writeOutput(' />' & chr(10));
				writeOutput('<label for="#cbId#">#item.label#</label>' & chr(10));
				writeOutput('</div>' & chr(10));
			}
			writeOutput('</div>' & chr(10));
			writeOutput('</fieldset>');
		}
		return trim(local.html);
	}

	/** Wheels-bound multi-checkbox group. */
	public string function uiBoundCheckboxGroup(
		required string objectName,
		required string property,
		required string options,
		string legend = "",
		string description = "",
		boolean inline = false,
		string class = ""
	) {
		if (!structKeyExists(variables, arguments.objectName)) {
			throw(
				type = "WheelsBasecoat.ObjectNotFound",
				message = "uiBoundCheckboxGroup: object '#arguments.objectName#' not found in the current scope."
			);
		}
		var obj = variables[arguments.objectName];
		var raw = "";
		try { raw = obj[arguments.property] ?: ""; } catch (any e) { raw = ""; }
		return uiCheckboxGroup(
			name = "#arguments.objectName#[#arguments.property#]",
			options = arguments.options,
			value = raw,
			legend = len(arguments.legend) ? arguments.legend : $humanize(arguments.property),
			description = arguments.description,
			inline = arguments.inline,
			class = arguments.class
		);
	}

	// ==============================================
	// RADIO GROUP + bound variant
	// ==============================================

	public string function uiRadioGroup(
		required string name,
		required string options,
		string value = "",
		string legend = "",
		string description = "",
		boolean inline = false,
		string class = ""
	) {
		var local = {};
		local.parsed = [];
		for (var opt in listToArray(arguments.options)) {
			var parts = listToArray(opt, ":");
			arrayAppend(local.parsed, {
				value: parts[1],
				label: arrayLen(parts) >= 2 ? parts[2] : parts[1],
				disabled: arrayLen(parts) >= 3 && parts[3] == "disabled"
			});
		}
		local.itemsCls = arguments.inline ? "flex flex-wrap gap-x-4 gap-y-2" : "grid gap-2";
		local.fieldsetCls = "fieldset";
		if (len(arguments.class)) local.fieldsetCls &= " " & arguments.class;

		savecontent variable="local.html" {
			writeOutput('<fieldset class="#local.fieldsetCls#">' & chr(10));
			if (len(arguments.legend)) writeOutput('<legend>#arguments.legend#</legend>' & chr(10));
			if (len(arguments.description)) writeOutput('<p>#arguments.description#</p>' & chr(10));
			writeOutput('<div class="#local.itemsCls#" role="radiogroup">' & chr(10));
			var idx = 0;
			for (var item in local.parsed) {
				idx++;
				var rId = "rg-" & replace(left(createUUID(), 8), "-", "", "all") & "-" & idx;
				var checked = arguments.value == item.value;
				writeOutput('<div class="flex items-center gap-2">' & chr(10));
				writeOutput('<input type="radio" id="#rId#" name="#arguments.name#" value="#item.value#" class="radio"');
				if (checked) writeOutput(" checked");
				if (item.disabled) writeOutput(" disabled");
				writeOutput(' />' & chr(10));
				writeOutput('<label for="#rId#">#item.label#</label>' & chr(10));
				writeOutput('</div>' & chr(10));
			}
			writeOutput('</div>' & chr(10));
			writeOutput('</fieldset>');
		}
		return trim(local.html);
	}

	/** Wheels-bound radio group. */
	public string function uiBoundRadioGroup(
		required string objectName,
		required string property,
		required string options,
		string legend = "",
		string description = "",
		boolean inline = false,
		string class = ""
	) {
		if (!structKeyExists(variables, arguments.objectName)) {
			throw(
				type = "WheelsBasecoat.ObjectNotFound",
				message = "uiBoundRadioGroup: object '#arguments.objectName#' not found in the current scope."
			);
		}
		var obj = variables[arguments.objectName];
		var raw = "";
		try { raw = obj[arguments.property] ?: ""; } catch (any e) { raw = ""; }
		return uiRadioGroup(
			name = "#arguments.objectName#[#arguments.property#]",
			options = arguments.options,
			value = toString(raw),
			legend = len(arguments.legend) ? arguments.legend : $humanize(arguments.property),
			description = arguments.description,
			inline = arguments.inline,
			class = arguments.class
		);
	}

	// ==============================================
	// ERROR SUMMARY
	// ==============================================

	/**
	 * Drop-in replacement for Wheels' `errorMessagesFor()`. Renders a
	 * basecoat destructive alert with a bullet list of field-prefixed
	 * messages from `model.allErrors()`. Returns "" when no errors so
	 * it's safe to call unconditionally at the top of a form.
	 */
	public string function uiErrorSummary(
		required any model,
		string title = "",
		string description = ""
	) {
		var local = {};
		try {
			if (!arguments.model.hasErrors()) return "";
			local.errors = arguments.model.allErrors();
		} catch (any e) {
			return "";
		}
		if (!arrayLen(local.errors)) return "";

		local.t = len(arguments.title)
			? arguments.title
			: (arrayLen(local.errors) == 1
				? "Couldn't save — 1 error"
				: "Couldn't save — #arrayLen(local.errors)# errors");

		savecontent variable="local.html" {
			writeOutput('<div class="alert alert-destructive" role="alert">' & chr(10));
			writeOutput($uiLucideIcon("alert-triangle", 16) & chr(10));
			writeOutput('<h5>#local.t#</h5>' & chr(10));
			writeOutput('<section>' & chr(10));
			if (len(arguments.description)) writeOutput('<p>#arguments.description#</p>' & chr(10));
			writeOutput('<ul>' & chr(10));
			for (var err in local.errors) {
				var prop = (err.property ?: "");
				var msg = (err.message ?: "");
				var line = len(prop) ? '<strong>#$humanize(prop)#</strong> #msg#' : msg;
				writeOutput('<li>#line#</li>' & chr(10));
			}
			writeOutput('</ul>' & chr(10));
			writeOutput('</section>' & chr(10));
			writeOutput('</div>');
		}
		return trim(local.html);
	}

	// ==============================================
	// RATING (1-N stars; read-only or interactive)
	// ==============================================

	/**
	 * Renders a 1-to-N star rating. With `name` set, renders interactive
	 * radio inputs whose labels show the stars (CSS-only highlight via
	 * the bundled extras stylesheet — no JS required). Without `name`,
	 * renders a static read-only display.
	 */
	public string function uiRating(
		any value = 0,
		numeric max = 5,
		string name = "",
		string ariaLabel = "Rating",
		string class = ""
	) {
		var local = {};
		local.cls = "ui-rating";
		if (len(arguments.class)) local.cls &= " " & arguments.class;
		local.numeric = IsNumeric(arguments.value) ? val(arguments.value) : 0;
		local.interactive = len(arguments.name);

		savecontent variable="local.html" {
			if (local.interactive) {
				writeOutput('<fieldset class="#local.cls#" data-rating-max="#arguments.max#" role="radiogroup" aria-label="#arguments.ariaLabel#">' & chr(10));
				// Render highest-first so CSS sibling combinators can light up
				// earlier stars on hover/check.
				for (var i = arguments.max; i >= 1; i--) {
					var rId = "rt-" & replace(left(createUUID(), 8), "-", "", "all") & "-" & i;
					var checked = local.numeric == i;
					writeOutput('<input type="radio" id="#rId#" name="#arguments.name#" value="#i#"');
					if (checked) writeOutput(" checked");
					writeOutput(' />' & chr(10));
					writeOutput('<label for="#rId#" aria-label="#i# of #arguments.max#">' & $uiLucideIcon("star", 20) & '</label>' & chr(10));
				}
				writeOutput('</fieldset>');
			} else {
				writeOutput('<span class="#local.cls#" data-rating="#local.numeric#" data-rating-max="#arguments.max#" aria-label="#arguments.ariaLabel#: #local.numeric# of #arguments.max#" role="img">' & chr(10));
				for (var i = 1; i <= arguments.max; i++) {
					var filled = i <= local.numeric;
					writeOutput('<span class="ui-rating-star#filled ? ' is-filled' : ''#" aria-hidden="true">' & $uiLucideIcon("star", 16) & '</span>' & chr(10));
				}
				writeOutput('</span>');
			}
		}
		return trim(local.html);
	}

}


