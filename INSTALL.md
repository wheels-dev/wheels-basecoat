# Installing wheels-basecoat

## 1. Add the package

```bash
wheels packages add wheels-basecoat
```

…or manually:

```bash
mkdir -p vendor
cp -r packages/basecoat vendor/wheels-basecoat
wheels reload
```

## 2. Publish the bundled assets

The package ships basecoat-css 0.3.11 + basecoat-js + a CSP-safe shim under `vendor/wheels-basecoat/assets/`. Publish them to your app's `public/` directory:

```bash
cp -r vendor/wheels-basecoat/assets/basecoat public/assets/basecoat
```

This is a one-shot operation. If you upgrade the package later (`wheels packages update wheels-basecoat`), re-run the copy to refresh the bundled CSS+JS.

> **Why a manual copy?** Wheels' `PackageLoader` activates the helpers automatically, but it doesn't expose the package's `assets/` directory at any URL. Publishing to `public/assets/basecoat` is the simplest path that works on every host. Most modern frameworks (Rails, Django, Phoenix) use a similar copy-or-symlink pattern.

## 3. Wire the layout

In `app/views/layout.cfm`'s `<head>`:

```cfm
<cfoutput>
    #basecoatThemeScript()#
    #csrfMetaTags()#
    #basecoatIncludes()#
</cfoutput>
```

…and just before `</body>`:

```cfm
<cfoutput>#basecoatFlashToasts()#</cfoutput>
```

## 4. (Optional) Mount the live showcase

Drop the controller + view + route from `examples/showcase/` into your app to get a live `/basecoat-showcase` URL. See `examples/showcase/README.md` for the three-step install.

## 5. Reload

```bash
wheels reload
```

Visit `/wheels/packages/wheels-basecoat` to confirm the package is loaded (you'll see the docs page). Visit `/basecoat-showcase` if you mounted the showcase to see every helper rendered live.

## Updating

```bash
wheels packages update wheels-basecoat
cp -r vendor/wheels-basecoat/assets/basecoat public/assets/basecoat
wheels reload
```

The asset copy step refreshes the bundled CSS+JS to match the new package version.

## Troubleshooting

If anything renders unstyled, check:

1. The bundled CSS is published — `ls public/assets/basecoat/basecoat.min.css` should exist.
2. `basecoatIncludes()` is in your layout's `<head>`.
3. Reload the app: `wheels reload`.
4. Check the package loaded: `application.wheels.packages` should contain `wheels-basecoat`.

For more, see `.ai/PITFALLS.md`.
