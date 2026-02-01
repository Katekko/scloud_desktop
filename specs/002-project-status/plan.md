# Implementation Plan: Project / Status

**Branch**: `002-project-status` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/002-project-status/spec.md`

## Summary

Implement project list and status in scloud_desktop: show a single list of linked and available projects (with indicator per project), let the user click one to set it as current (session-only), and provide a separate status screen showing deployment state, last deploy time, and environment when the CLI exposes it. Use serverpod_cloud_cli as a library for project list and status so behavior matches the CLI. Project list and status screens are separate; user navigates from list to status.

## Technical Context

**Language/Version**: Flutter 3.38.8 (Dart per pubspec)  
**Primary Dependencies**: Flutter SDK, flutter_localizations, serverpod_cloud_cli (project list, status — same as CLI), Material/Cupertino for UI  
**Storage**: Session-only in-memory for current project (not persisted across app restarts); auth/session remains per Login feature (serverpod_cloud_cli persistent storage)  
**Testing**: Flutter test (widget, unit); integration tests for project list and status flows (Serverpod Cloud API; per constitution)  
**Target Platform**: Linux desktop (primary)  
**Project Type**: Single Flutter desktop application  
**Performance Goals**: Project list and status load within a few seconds under normal conditions (per spec)  
**Constraints**: CLI parity (same data as scloud project list / scloud status); current project session-only; separate screens for list and status  
**Scale/Scope**: Single user per app instance; list and status for MVP demo

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Desktop-First**: Project list and status are UI-driven (Flutter); user navigates and selects via UI. **PASS**
- **CLI Parity**: Project list and status use serverpod_cloud_cli so data and behavior match scloud project list and scloud status. **PASS**
- **Test-First / Integration**: Plan includes integration tests for project list and status (Serverpod Cloud API); tests before or alongside implementation. **PASS**
- **Simplicity & Observability**: Loading/empty/error states and clear messages; structured logging for project/status flows. **PASS**
- **Localization (l10n)**: All user-facing strings (list, status, errors, empty state) via ARB/AppLocalizations; no hardcoded UI text. **PASS**
- **Widgets as classes**: UI built from StatelessWidget/StatefulWidget classes, not widget-returning functions. **PASS**

No violations. Proceed to Phase 0.

*Post–Phase 1 re-check*: Data model and contracts do not introduce new violations.

## Project Structure

### Documentation (this feature)

```text
specs/002-project-status/
├── plan.md              # This file
├── research.md          # Phase 0: serverpod_cloud_cli project list & status
├── data-model.md        # Phase 1: Project, Current project, Project status, Server directory
├── quickstart.md        # Phase 1: run app, list projects, select, view status
├── contracts/           # Phase 1: project-list flow, status screen contract
└── tasks.md             # Phase 2: from /speckit.tasks (not created by plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── app.dart
├── theme/
├── features/
│   ├── auth/            # Existing (001-login)
│   └── projects/        # NEW: project list + current project selection
│       ├── project_list_screen.dart   # List with linked/available indicator
│       ├── project_list_cubit.dart    # Load list, set current project (session)
│       ├── project_repository.dart    # serverpod_cloud_cli project list + status
│       └── ...
│   └── status/          # NEW: status screen (separate from list)
│       ├── status_screen.dart         # Deployment state, last deploy time, environment
│       ├── status_cubit.dart          # Load status for current project
│       └── ...
├── router/              # Add routes: project list, status
├── l10n/
└── shared/

test/
├── unit/
├── widget/
└── integration/
    ├── auth_flow_test.dart
    └── project_status_flow_test.dart   # NEW: list, select, status
```

**Structure Decision**: Single Flutter project. Add `lib/features/projects/` for project list and current-project selection, and `lib/features/status/` for the status screen. Routing extends existing `lib/router/` so user navigates from project list to status screen. Current project held in memory (Cubit/state) for the session only.

## Complexity Tracking

No constitution violations. No entries required.
