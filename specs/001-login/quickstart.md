# Quickstart: 001-login (Login + Theme)

**Feature**: 001-login  
**Date**: 2025-01-30

## Prerequisites

- Flutter SDK (per project `pubspec.yaml`)
- Linux desktop (primary target); `flutter run -d linux`
- A Serverpod Cloud account (or sign up at serverpod.cloud)
- Optional: `scloud` CLI installed (`dart pub global activate serverpod_cloud_cli`) to compare behavior

## Run the app (after implementation)

1. **Checkout and install**
   - Branch: `001-login`
   - From repo root: `flutter pub get`

2. **Run on Linux**
   - `flutter run -d linux`  
   - Or use the VS Code/Cursor launch config "scloud_desktop (Linux)".

3. **Login flow**
   - Open app → login screen (Serverpod-themed).
   - Tap "Log in" → app shows "Complete sign-in in browser".
   - Complete sign-in in the opened browser.
   - Return to app → see logged-in state and account identity.
   - Sign out → back to login screen.

4. **Session parity**
   - If you previously ran `scloud auth login` and have a valid session, the app may show you as already logged in (shared storage).
   - Conversely, logging in via the app can make `scloud` commands work without running `scloud auth login` again.

## Theme

- The app uses a theme based on Serverpod colors (see `lib/theme/`). Primary and surface colors follow serverpod.dev / Serverpod Cloud. No extra steps; theme is applied at app startup.

## Localization (l10n)

- The app uses Flutter’s default l10n: ARB files (e.g. `lib/l10n/app_en.arb`) and generated `AppLocalizations`. Default locale is the app’s primary language. Run `flutter gen-l10n` (or `flutter pub get`) to regenerate localizations after editing ARB files.

## Verification

- **First-time login**: Not logged in → Log in → waiting state → complete in browser → logged in with identity shown.
- **Persistence**: Close app, reopen → still logged in (no login screen).
- **Sign out**: Sign out → login screen; reopen app → login screen.
- **Invalid session**: If session is expired/revoked, app shows "Session expired. Please sign in again." and login screen.
- **Cancel**: Start login, close browser without signing in → "Sign-in was not completed." and login screen.

## Spec and plan

- Spec: [spec.md](spec.md)  
- Plan: [plan.md](plan.md)  
- Research: [research.md](research.md)  
- Data model: [data-model.md](data-model.md)  
- Login flow contract: [contracts/login-flow.md](contracts/login-flow.md)
