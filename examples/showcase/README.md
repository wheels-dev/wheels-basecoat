# wheels-basecoat live showcase

A drop-in Wheels controller + view that renders every `wheels-basecoat` helper live alongside the source code that produced it. Mount it in your dev environment to:

- Explore every component visually before authoring code
- Catch visual regressions when bumping basecoat-css versions
- Hand the URL to AI assistants as a real rendering reference

## Why this exists separately from `index.cfm`

The package's `index.cfm` is rendered at `/wheels/packages/wheels-basecoat` by the Wheels admin views — but those views run in an admin controller scope where the package's mixed-in helpers AREN'T available. So the package-level `index.cfm` can only be a static documentation page.

This controller, on the other hand, is mounted in YOUR app, runs in YOUR app's controller scope (where the mixins ARE present), and renders the helpers live.

## Install

1. Copy the controller and view into your app:

```bash
cp -r vendor/wheels-basecoat/examples/showcase/controllers/Showcase.cfc app/controllers/Showcase.cfc
cp -r vendor/wheels-basecoat/examples/showcase/views/showcase app/views/showcase
```

2. Add a route. Open `config/routes.cfm` and add inside `mapper()...end()`:

```cfml
.get(name="basecoatShowcase", pattern="/basecoat-showcase", to="showcase##index")
```

3. Reload your app and visit `http://localhost:<port>/basecoat-showcase`.

## Uninstall

Delete `app/controllers/Showcase.cfc`, the `app/views/showcase/` directory, and the route. Reload.

## Best practice: gate to dev only

This page exposes every component but doesn't expose any data, so it's safe to ship to production. If you'd rather keep it dev-only, gate it in the controller:

```cfml
function index() {
    if (get("environment") != "development") {
        return redirectTo(route="root");
    }
    // ... rest of action
}
```
