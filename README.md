# Terra NT

Start with the [documentation index and team instructions](docs/DOCUMENTATION-INDEX.md) for links, reading order and guidance for each role.

🚧 **Work in progress.** 🚧

## Run

The Flutter app is in `terra_nt/`. Copy `terra_nt/.env.example` to `terra_nt/.env`, then
pass the file to every run and build. The OpenFreeMap basemap needs no API key:

    cd terra_nt
    flutter run --dart-define-from-file=.env
    flutter build apk --dart-define-from-file=.env

## Routes and directions

The route line and animated car use road geometry from the public OSRM demo service,
based on OpenStreetMap roads. It is best effort, without live traffic, closure data, or
uptime guarantees; if the routing service is unavailable, the app falls back to the
straight connections between stops. Google Maps opens in its app when installed. On iOS,
Apple Maps opens when Google Maps is not installed. For actual navigation, confirm current
road conditions separately.

## Demo on a phone (Android, USB cable)

1. Phone: *Settings → About phone*, tap *Build number* seven times, then *Developer options →
   USB debugging* on. Plug it in and accept the prompt.
2. Laptop: double-click `tools/plan_server/start.bat`. It links every plugged-in phone and
   emulator to the laptop, then runs the AI planner; keep that window open.
3. Install the app: `adb install -r terra_nt/build/app/outputs/flutter-apk/app-release.apk`
   (build it first with `flutter build apk --release --dart-define-from-file=.env`, with
   `PLAN_API_URL=http://127.0.0.1:8787` in `.env`).

A phone plugged in after step 2 needs `tools/plan_server/link-devices.bat`. iPhone:
`docs/IOS-SETUP.md`.
