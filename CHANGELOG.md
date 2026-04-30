# Changelog

All notable changes to this package will be documented in this file.

## [1.0.4] — 2026-04-30

### Fixed
- Drop `mixin="controller"` from the `Basecoat.cfc` component declaration. The 1.0.3 changelog claimed this attribute was a no-op — that was wrong. Lucee 7.0.0.395 enforces native trait composition on `component mixin="..."` and tries to resolve `controller` as a CFML component path; on a clean install with empty Lucee class caches, that resolution fails and the whole component bombs out with the misleading error `invalid component definition, can't find component [vendor.wheels-basecoat.Basecoat]`. Net effect on a fresh `wheels packages add wheels-basecoat`: `application.wheels.failedPackages` carries the package, every helper call (`uiCard`, `uiField`, `uiButton`, etc.) blows up with `No matching function [...] found`, and the bonus chapter is unreachable. Cached-class reproductions appeared to load the package fine, which masked the bug during 1.0.2/1.0.3 release testing. The authoritative source for the mixin target is the `provides.mixins: "controller"` field in `package.json`, which `PackageLoader` already reads — the component-level attribute is genuinely redundant and now also actively breaks Lucee 7. (Verified end-to-end on a fresh VM with `wheels stop && rm -rf vendor/wheels-basecoat ~/.wheels/servers/<app>/lucee-server/context/cfclasses/* && wheels packages add wheels-basecoat && wheels start` — without this fix, `application.wheels.failedPackages` is non-empty; with it, `application.wheels.packages.wheels-basecoat` is populated and all 57 helpers resolve.)

### Retraction
- The 1.0.3 changelog included a "Note on the 1.0.2 changelog" stating that the `mixin="controller"` attribute compiles fine on Lucee 7.0.0.395 and is a no-op. That note was based on testing against a Lucee class cache that already had the package compiled — the actual fresh-install behavior is the failure described above. The 1.0.2 changelog's original diagnosis (Lucee 7 rejecting the `mixin` attribute) was directionally correct; what was wrong was its claim that 1.0.2 "fixed" it by removing only `view` from the comma list. Removing `controller` was also required, and is what 1.0.4 does.

## [1.0.3] — 2026-04-29

### Fixed
- Switch `$uiBuildId` and `$uiLucideIcon` from `private` → `public` on `Basecoat.cfc`. Wheels' `PackageLoader.$collectMixins` integrates only PUBLIC methods of the package CFC into the target scope (controllers in our case), so when public sibling helpers like `uiField`, `uiInput`, `uiCheckbox`, `uiButton(icon=...)`, `uiAlert`, and `uiPagination` invoked the `$`-prefixed helpers from the mixed-in scope they blew up at runtime with `No matching function [$UIBUILDID] found` (and the symmetrical icon variant). Hitting *any* page that rendered a form via `uiField` therefore 500'd on a fresh install. The leading `$` keeps signalling "internal — don't call from app code"; the access-modifier change just lets `PackageLoader` carry the helpers across the mixin boundary alongside the public callers that depend on them. (Discovered during a Wheels Tutorial fresh-VM bake; see Wheels Tutorial Finding #14.)

### Note on the 1.0.2 changelog
The 1.0.2 changelog asserted that Lucee 7 was rejecting the `mixin="controller"` component-level attribute outright, blocking compilation. That diagnosis was incorrect — verified post-release on Lucee 7.0.0.395, the package compiles fine and `PackageLoader` loads it successfully with the attribute in place. The actual blocker preventing helper rendering was the private-helper visibility issue fixed in 1.0.3 above. The `mixin="controller"` attribute on the component declaration is a no-op (the authoritative source for mixin targets is `package.json`'s `provides.mixins` field), and was already simplified to just `"controller"` in 1.0.2. No further changes to the attribute are required.

## [1.0.2] — 2026-04-29

### Fixed
- Drop `view` from the component-level `mixin` attribute on `Basecoat.cfc`. Lucee 7 enforces native trait composition on `component mixin="..."` and tries to load each comma-separated value as a CFML component path; there is no `view.cfc` on the path, so the whole component failed to compile with a misleading `can't find component [vendor.wheels-basecoat.Basecoat]` error. Net effect on Lucee 7: every `wheels packages add wheels-basecoat` install resulted in a successful extract but no helper activation. Helpers like `#uiButton(...)#`, `#uiCard(...)#`, `#uiField(...)#` all returned `function not found`. After this fix the package activates cleanly. The `package.json`'s `provides.mixins: "controller"` field remains the actual source of truth — the component-level attribute was a legacy convention obsolete on Lucee 7. Lucee 5/6 don't enforce native mixin composition the same way, which is why this went undetected until Wheels 4.0 made Lucee 7 the default. (See [#2](https://github.com/wheels-dev/wheels-basecoat/pull/2).)

## [1.0.1] — 2026-04-24

### Added
- Patch release. (Original entry omitted from the changelog at release time.)

## [1.0.0] — 2026-04-23

### Added
- Initial standalone release, extracted from the Wheels monorepo at `packages/basecoat`.
- Git history preserved from the monorepo's package directory.
- Published to the `wheels-dev/wheels-packages` registry for installation via `wheels packages install` (coming in Wheels 4.1).
