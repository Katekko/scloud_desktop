# Phase 0 Research: Login + Theme

**Feature**: 001-login  
**Date**: 2025-01-30

## 1. Serverpod Cloud CLI auth flow (programmatic use)

**Decision**: Use the `serverpod_cloud_cli` Dart package as a dependency and invoke auth via its command/library layer so behavior and storage match the CLI.

**Rationale**:
- The package exposes `command_runner/commands/auth_command` and `commands/auth/auth_login` (per pub.dev API docs). The CLI’s `scloud auth login` is implemented there, so reusing it guarantees the same identity provider, redirect flow, and token handling.
- Flutter app will: (1) Call into the package’s auth entry point (e.g. auth command or auth_login module) when the user taps “Log in”. (2) Let the package open the browser and run the OAuth-like flow. (3) On callback, the package persists the session; the app then reads session state and updates UI to “logged in”.

**Alternatives considered**:
- Calling `Process.run('scloud', ['auth', 'login'])`: would share storage but is brittle (PATH, parsing stdout) and not ideal for a desktop UI. Rejected.
- Reimplementing auth against Ground Control / Serverpod Cloud APIs directly: possible but duplicates logic and risks drift from CLI. Rejected for MVP.

**Implementation note**: Confirm the exact public API for “run login” (e.g. `AuthCommand().run()` or `authLogin()` function) from the package’s `commands/auth/` and `command_runner/commands/auth_command`; use that in `auth_service.dart`. If the package only exposes CLI entry points, the app may need to instantiate the command runner with a non-stdout logger and trigger the auth subcommand.

---

## 2. Session storage (CLI parity)

**Decision**: Use the same persistent storage as the scloud CLI. Session persistence MUST be implemented by using serverpod_cloud_cli’s storage layer (e.g. `persistent_storage/`, `resource_manager`, `cli_authentication_key_manager`) so that one login in either the app or the CLI is sufficient for both.

**Rationale**:
- Spec and constitution require shared session when possible (FR-008, Assumptions). The CLI stores auth/session data in platform-appropriate locations; the package’s `persistent_storage` and related modules define where and how. Using them from the desktop app guarantees parity.

**Alternatives considered**:
- App-only storage: would break “one login for both” and was rejected per spec clarification.

**Implementation note**: Do not implement a custom session store. Depend on serverpod_cloud_cli and use its APIs for reading/writing auth state. If the package stores under a “scloud” or “serverpod_cloud_cli” path, the app must use that same path (no separate “scloud_desktop” root for auth data).

---

## 3. Serverpod colors and theme

**Decision**: Define app theme from Serverpod brand colors. Use serverpod.dev and Serverpod Cloud as the visual reference; capture primary (blue), surface/background, and accent colors into a small palette and map them to Flutter `ThemeData`.

**Rationale**:
- User requested theme creation following Serverpod colors for a consistent Serverpod product feel. serverpod.dev uses blue gradients (e.g. hero, “blue” gradient assets), dark or dark-ish backgrounds, and light text/accents. Serverpod Cloud UI aligns with that. Defining a single source of truth (e.g. `serverpod_colors.dart`) keeps the app on-brand.

**Sources**:
- serverpod.dev: gradients (hero-main, blue), dark backgrounds, primary blue tones.
- No official public style guide was found; colors are derived from the live site and assets (e.g. `gradients/blue@….webp`, `logos/on-dark@….svg`).

**Proposed palette (to be confirmed or adjusted from assets)**:
- **Primary**: Blue aligned with Serverpod (e.g. indigo/blue in the #4F46E5–#6366F1 range, or extract from logo/gradient).
- **Surface / background**: Dark gray or navy for “on-dark” feel (e.g. #0F172A, #1E293B) for dark theme; light gray/white for light theme if needed.
- **On-primary / on-surface**: White or light gray for contrast.
- **Error**: Standard red for errors (e.g. “Session expired”, “Sign-in was not completed.”).
- **Secondary / accent**: Lighter blue or gradient accent for buttons/links.

**Alternatives considered**:
- Generic Material theme: would not match Serverpod. Rejected.
- Waiting for an official Serverpod design token repo: not available; deriving from the site is acceptable and can be updated later if the brand publishes tokens.

**Implementation note**: Create `lib/theme/serverpod_colors.dart` with named constants (e.g. `serverpodPrimary`, `serverpodSurfaceDark`, `serverpodBackground`) and `lib/theme/app_theme.dart` that builds `ThemeData` (light and/or dark) using those constants. Apply to the app in `main.dart` / root `App` widget. If exact hex values are published later by Serverpod, update the constants in one place.

---

## 4. Internationalization (l10n)

**Decision**: Use Flutter’s default localization: `flutter_localizations`, ARB files, and `flutter gen-l10n` for generated `AppLocalizations`. Default locale is the app’s primary language (e.g. English).

**Rationale**: Plan requires l10n with Flutter’s default approach. Built-in gen-l10n is well documented, avoids third-party packages for MVP, and keeps all user-facing strings in ARB files. Default locale is set via the default ARB file (e.g. `app_en.arb`).

**Implementation note**: Add `flutter_localizations` (sdk: flutter); create `l10n.yaml` (e.g. `arb-dir: lib/l10n`, `output-dir` as needed); add ARB files with keys for login, waiting message, errors. Use `AppLocalizations.of(context)!` in UI; set `localizationsDelegates` and `supportedLocales` on `MaterialApp`.
