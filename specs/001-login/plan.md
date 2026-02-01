# Implementation Plan: Login to Serverpod Cloud + Theme (Serverpod Colors)

**Branch**: `001-login` | **Date**: 2025-01-30 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/001-login/spec.md`  
**User addition**: Theme creation following Serverpod colors. Flutter 3.38.8; internationalization (l10n) using Flutter’s default approach.

## Summary

Implement login to Serverpod Cloud from the scloud_desktop Flutter app: initiate auth (same flow as scloud CLI), show "Complete sign-in in browser" waiting state, persist session using the same storage as the CLI so one login works for both, display account identity when logged in, and support sign-out with clear messages for cancel/abandon and invalid session. Additionally, create an app theme that follows Serverpod brand colors (from serverpod.dev / Serverpod Cloud) for consistent visual identity.

## Technical Context

**Language/Version**: Flutter 3.38.8  
**Primary Dependencies**: Flutter SDK, flutter_localizations (for l10n), serverpod_cloud_cli (for auth/session and CLI parity), Material/Cupertino for UI  
**Storage**: Same location and format as scloud CLI (platform-appropriate persistent storage; see serverpod_cloud_cli persistent storage / resource manager)  
**Testing**: Flutter test (widget, unit); integration tests for auth flow and Serverpod Cloud API (per constitution)  
**Target Platform**: Linux desktop (primary); macOS/Windows desktop optional later  
**Project Type**: Single Flutter desktop application  
**Performance Goals**: Login flow completable in under one minute; app startup and session restore responsive  
**Constraints**: Session shared with scloud CLI when possible; UI simple and focused (constitution)  
**Scale/Scope**: Single user per app instance; MVP login + theme for team demo  

**Theme**: App theme MUST follow Serverpod colors (primary, surface, accents) derived from serverpod.dev and Serverpod Cloud branding. Research Phase 0 will capture exact color values and apply them to a Flutter ThemeData (light/dark as needed).

**Internationalization (l10n)**: Use Flutter’s default localization: `flutter_localizations`, ARB files for strings, and code generation (`flutter gen-l10n`). Default locale is the app’s primary language; all user-facing strings (login, waiting message, errors) MUST be localized via generated `AppLocalizations`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Desktop-First**: Login and all flows are UI-driven (Flutter); no CLI-only behavior. **PASS**
- **CLI Parity**: Auth and session use same identity provider and storage as scloud; behavior matches CLI. **PASS**
- **Test-First / Integration**: Plan includes integration tests for auth flow and Serverpod Cloud; tests before or alongside implementation. **PASS**
- **Simplicity & Observability**: Clear messages ("Complete sign-in in browser", "Sign-in was not completed.", "Session expired. Please sign in again."); structured logging for debugging. **PASS**
- **Localization (l10n)**: All user-facing strings via ARB/AppLocalizations; no hardcoded UI text; default locale defined. **PASS**

No violations. Proceed to Phase 0.

*Post–Phase 1 re-check*: Theme and auth design do not introduce new violations. Desktop-First, CLI Parity, Test-First/Integration, and Simplicity & Observability still pass.

## Project Structure

### Documentation (this feature)

```text
specs/001-login/
├── plan.md              # This file
├── research.md          # Phase 0: auth flow, session storage, Serverpod colors
├── data-model.md        # Phase 1: Session, User/account identity
├── quickstart.md        # Phase 1: run app, login, theme
├── contracts/           # Phase 1: login flow / UI state contract
└── tasks.md             # Phase 2: from /speckit.tasks (not created by plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── app.dart             # App widget, theme, routes, localizationsDelegates
├── theme/
│   ├── app_theme.dart   # ThemeData following Serverpod colors
│   └── serverpod_colors.dart  # Color constants from Serverpod brand
├── features/
│   └── auth/
│       ├── login_screen.dart
│       ├── login_waiting_screen.dart   # "Complete sign-in in browser"
│       ├── auth_service.dart           # Uses serverpod_cloud_cli auth + session
│       └── auth_state.dart             # Logged-in / logged-out state
└── shared/
    └── (use AppLocalizations for strings; no hardcoded messages)

l10n.yaml                 # Flutter l10n config (arb-dir, synthetic-package)
lib/l10n/                 # ARB files: app_en.arb (default), app_<locale>.arb
# Generated: .dart_tool/flutter_gen/gen_l10n/ or output-dir per l10n.yaml

test/
├── unit/
├── widget/
└── integration/
    └── auth_flow_test.dart
```

**Structure Decision**: Single Flutter project. Feature-based layout under `lib/features/auth/`. Theme under `lib/theme/` with Serverpod color constants and `ThemeData`. Localization: Flutter default l10n with `l10n.yaml`, ARB files under `lib/l10n/` (or arb-dir as configured), generated `AppLocalizations`; no hardcoded user-facing strings. No backend; desktop app only.

## Theme Creation (Serverpod Colors)

- **Objective**: Define a Flutter theme that follows Serverpod brand colors so the app feels part of the Serverpod ecosystem.
- **Artifacts**: `lib/theme/serverpod_colors.dart` (primary, secondary, surface, error, etc.); `lib/theme/app_theme.dart` (light/dark `ThemeData` using those colors).
- **Source of truth**: serverpod.dev and Serverpod Cloud UI (gradients, primary blue/dark tones). Phase 0 research will document exact hex values and any light/dark variants.
- **Applied to**: `MaterialApp` / `App` in `main.dart` so all screens (login, waiting, post-login) use the theme.

## Internationalization (l10n)

- **Objective**: Support multiple locales using Flutter’s default localization so all user-facing text is localizable and the default locale is consistent.
- **Approach**: Flutter’s built-in l10n (code generation from ARB files). Use `flutter_localizations` and `flutter gen-l10n`; configure via `l10n.yaml` (e.g. `arb-dir`, `output-dir`, `synthetic-package: false` if desired).
- **Artifacts**:
  - `l10n.yaml` at project root (or `flutter: generate: true` and `flutter/gen-l10n` defaults).
  - ARB files in the configured arb directory (e.g. `lib/l10n/`): `app_en.arb` as default (or `app_en.arb` with `"@@locale": "en"`), plus `app_<locale>.arb` for other locales.
  - All spec-mandated strings (e.g. "Complete sign-in in browser", "Sign-in was not completed.", "Session expired. Please sign in again.") MUST be keys in the default ARB and used via `AppLocalizations.of(context)!.<key>` (or equivalent).
- **MaterialApp**: Set `localizationsDelegates` (including `AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, etc.) and `supportedLocales` (at least default locale).
- **Default**: The default locale is the app’s primary language (e.g. English); define it in the default ARB file.

## Complexity Tracking

No constitution violations. No entries required.
