# scloud_desktop

Flutter desktop app for Serverpod Cloud: login, session (shared with scloud CLI), theme, and localization.

## Getting Started

### Prerequisites

- Flutter SDK (see `pubspec.yaml`)
- Linux desktop (primary target); macOS/Windows optional

### Install and run

From the repo root:

```bash
flutter pub get
flutter run -d linux
```

Or use the VS Code/Cursor launch config **scloud_desktop (Linux)**.

### Localization (l10n)

After editing ARB files under `lib/l10n/`, regenerate:

```bash
flutter gen-l10n
```

(or run `flutter pub get` which triggers generation when `flutter: generate: true` is set).

## Login flow

- **Login**: Tap "Log in" → app shows "Complete sign-in in browser" → complete sign-in in the opened browser → app shows logged-in state and account identity.
- **Session parity**: Session is stored in the same location as the scloud CLI; one login works for both app and CLI.
- **Sign out**: Tap "Sign out" → login screen; next launch shows login screen.
- **Invalid session**: If session is expired/revoked, app shows "Session expired. Please sign in again." and login screen.

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Serverpod Cloud](https://serverpod.cloud)
