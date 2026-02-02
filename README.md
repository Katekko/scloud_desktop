# scloud_desktop

Flutter desktop app for [Serverpod Cloud](https://serverpod.cloud): login, session (shared with scloud CLI), theme, and localization.

## Getting the app

### Option 1: Download a release (recommended)

1. Go to [Releases](https://github.com/Katekko/scloud_desktop/releases).
2. Download the Linux archive.
3. Unpack and run the app (see the release notes for platform-specific steps).

### Option 2: Build from source

Use this if you want to compile the app yourself (e.g. to use a different Flutter version or patch the code).

#### Prerequisites

- **Flutter SDK** — Use a version compatible with the project (see `pubspec.yaml`: Dart `^3.10.7`, Flutter stable).
- **Linux**: `clang`, `cmake`, `gtk3` dev packages, and `ninja` (e.g. on Debian/Ubuntu: `sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev`).

#### Build steps

1. **Clone the repo**

   ```bash
   git clone https://github.com/Katekko/scloud_desktop.git
   cd scloud_desktop
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Build for your platform**

   - **Linux (release bundle)**

     ```bash
     flutter build linux
     ```

     Run the app from: `build/linux/x64/release/bundle/` (e.g. `./scloud_desktop` or the executable name in that folder).

4. **Run in debug (optional)**

   ```bash
   flutter run -d linux
   ```

   Or use the VS Code/Cursor launch config **scloud_desktop (Linux)**.

#### Verifying Flutter

```bash
flutter doctor
```

Fix any reported issues before building.

---

## Localization (l10n)

After editing ARB files under `lib/l10n/`, regenerate:

```bash
flutter gen-l10n
```

(or run `flutter pub get` if `flutter: generate: true` is set in `pubspec.yaml`).

---

## Login flow

- **Login**: Tap "Log in" → app shows "Complete sign-in in browser" → complete sign-in in the opened browser → app shows logged-in state and account identity.
- **Session parity**: Session is stored in the same location as the scloud CLI; one login works for both app and CLI.
- **Sign out**: Tap "Sign out" → login screen; next launch shows login screen.
- **Invalid session**: If session is expired/revoked, app shows "Session expired. Please sign in again." and login screen.

## Project list and status

- **Project list**: After login, home shows the project list with linked/available indicator per project.
- **Project details**: Tap a project to open its details (deployment state, deploy history).
- **Session-only**: Current project is not persisted across app restarts. Sign out clears the current project.

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Serverpod Cloud](https://serverpod.cloud)
