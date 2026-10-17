# Presentation demo evidence

Evidence captured while preparing the Terra NT Flutter iOS presentation demo. These are
runtime observations, not design reference screenshots or evaluation results.

| File | Capture conditions | Observation |
|---|---|---|
| `iphone17-login-debug-empty-config-2026-10-06.png` | iPhone 17 simulator, iOS 26.5; Flutter 3.47.1 debug build; captured before the keyless map switch | Historical screenshot: app launched to Login, no demo account was used, and the previous CARTO basemap showed its API-key watermark. It does not show the current OpenFreeMap layer. |
| `iphone17-login-openfreemap-2026-10-06.png` | iPhone 17 simulator, iOS 26.5; Flutter 3.47.1 debug build after the basemap change | Current login screen uses OpenFreeMap dark vector tiles without the CARTO watermark and shows OpenFreeMap/OpenMapTiles/OpenStreetMap attribution. The dark scrim intentionally tones down the decorative background. No demo account was used. |

To capture an updated simulator screenshot from `terra_nt/`:

```sh
xcrun simctl io 593B103F-F067-4768-9194-AD67FC7425E8 screenshot /tmp/terra-nt-demo.png
cp /tmp/terra-nt-demo.png ../docs/presentation-demo-evidence/<name>.png
```

Do not put credentials, API keys, or private configuration values in this directory.
