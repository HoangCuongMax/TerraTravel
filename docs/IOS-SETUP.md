# Running Terra NT on an iPhone

For a teammate with a Mac. The first iOS debug build was run on the iPhone 17 simulator
on 2026-10-06. A physical-iPhone release install still needs to be completed and verified.

What is already done in the repo: the iOS app is registered in Firebase (`terra-nt-cdu`,
bundle id `au.edu.cdu.terraNt`), `lib/firebase_options.dart` has the iOS entry, Google
Sign-In's iOS client id and URL scheme are in `ios/Runner/Info.plist`, and the app icon and
dark launch screen are in place. Nothing below needs a Firebase console.

## You need

- A Mac with the current Xcode (App Store), opened once so it installs its components.
- Flutter 3.47.1 (`flutter --version`).
- For a physical iPhone: the phone and its cable, plus a free Apple ID. No paid developer
  account. A simulator can be used without Apple ID signing.
- Copy `terra_nt/.env.example` to `terra_nt/.env`. The OpenFreeMap basemap needs no key;
  `PLAN_API_URL` is only needed for live itinerary generation. Blank keeps the built-in
  demo route.
- Route lines use the public OSRM demo service for OpenStreetMap road geometry when online.
  It has no uptime or traffic/closure guarantees. If Google Maps is not installed on iOS,
  directions open in Apple Maps.

## Steps

1. Clone the repo, put `.env` in `terra_nt/`, then:

       cd terra_nt
       flutter pub get

   This iOS project uses Swift Package Manager and has no `ios/Podfile`, so there is no
   `pod install` step. Xcode resolves the generated Flutter plugin package and its iOS
   dependencies when the workspace is opened or the app is built; the first resolution
   may take a few minutes.

2. Open `ios/Runner.xcworkspace` (the workspace, not the project) once and wait for Xcode's
   package resolution to finish.

### Run on an iPhone simulator

List available devices with `flutter devices`, then run:

    flutter run -d <simulator-id> --dart-define-from-file=.env

The simulator does not require Apple ID signing. The login screen still requires an
authorized Firebase account or Google sign-in to enter the app.

### Install on a physical iPhone

1. Open `ios/Runner.xcworkspace`. Select **Runner** → **Signing & Capabilities** → **Team**:
   add your Apple ID and pick its *Personal Team*. Keep the bundle id `au.edu.cdu.terraNt`:
   Firebase and Google Sign-In are tied to it. If Xcode says the id is unavailable, stop and
   tell Tarık rather than changing it.
2. On the iPhone: plug it in, tap *Trust*, then **Settings → Privacy & Security →
   Developer Mode → On** (the phone restarts).
3. Build a release build, so the app opens from the home screen without the Mac:

       flutter run --release --dart-define-from-file=.env

4. The first launch is blocked until you trust yourself: **Settings → General → VPN &
   Device Management →** your Apple ID → *Trust*.

The app stops opening after 7 days (free Apple ID limit); run the release command in step 3
again to renew. Every other iPhone that should get the app is plugged into the Mac once and
the release command is repeated.

## The AI planner on an iPhone

iOS refuses plain `http`, so `PLAN_API_URL` in `.env` must be the `https://…` address Tarık
gets from `cloudflared` while `tools/plan_server` runs on his machine
(`tools/plan_server/README.md`). Rebuild after changing `.env`.
