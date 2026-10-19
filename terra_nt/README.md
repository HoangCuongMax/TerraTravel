# Terra NT Flutter application

This directory contains the mobile app. Start with the [project README](../README.md) for setup, Firebase requirements, demo modes and known limitations, or the [complete documentation index](../docs/DOCUMENTATION-INDEX.md) for team instructions.

Run Flutter commands from this directory:

```sh
flutter pub get
cp .env.example .env
flutter run --dart-define-from-file=.env
```

Use Flutter 3.47.1 / Dart 3.13.1, as specified in the project engineering guide. On Windows, use `copy .env.example .env` instead of `cp`.

An empty `PLAN_API_URL` uses the seeded planning repository. Authentication still uses Firebase; an empty planner URL does not bypass sign-in or make this a completely disconnected first-install demo.
