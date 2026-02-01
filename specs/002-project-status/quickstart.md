# Quickstart: 002-project-status (Project List & Status)

**Feature**: 002-project-status  
**Date**: 2026-02-01

## Prerequisites

- Flutter SDK (per project `pubspec.yaml`)
- Linux desktop (primary target); `flutter run -d linux`
- User must be logged in (001-login); valid Serverpod Cloud session
- Optional: `scloud` CLI installed to compare project list and status output

## Run the app (after implementation)

1. **Checkout and install**
   - Branch: `002-project-status`
   - From repo root: `flutter pub get`

2. **Run on Linux**
   - `flutter run -d linux`
   - Or use the VS Code/Cursor launch config "scloud_desktop (Linux)".

3. **Login** (if not already)
   - Open app → log in per 001-login quickstart so you have a valid session.

4. **Project list**
   - After login, navigate to the project list screen (e.g. home or /projects).
   - App shows a list of linked and available projects with an indicator per project (linked vs available).
   - If no projects: empty state with a clear message (e.g. no projects yet).
   - If loading: loading state until list is available.

5. **Set current project**
   - Click one project in the list → that project becomes the current project for the session.
   - Optional: choose a server directory (folder with Serverpod server linked to Cloud) to set current project; invalid choice shows a clear message.

6. **View status**
   - Navigate to the status screen (separate screen from the list).
   - If a current project is set: app shows deployment state, last deploy time, and environment (if CLI exposes it).
   - If no current project: app shows a message or prompt to choose a project.
   - Loading and error states show clear feedback and retry where applicable.

7. **Session-only current project**
   - Close the app and reopen → current project is cleared; user selects again from the list.
   - Sign out → current project cleared; redirect to login.

## Verification

- **List**: Logged in → project list screen shows projects with linked/available indicator; empty state when no projects; loading and error with retry.
- **Select**: Click a project → current project set; navigate to status → status for that project.
- **Status**: Status screen shows deployment state, last deploy time, environment (if any); no current project → clear message.
- **No persistence**: Restart app → current project cleared; sign out → current project cleared.

## Spec and plan

- Spec: [spec.md](spec.md)
- Plan: [plan.md](plan.md)
- Research: [research.md](research.md)
- Data model: [data-model.md](data-model.md)
- Contracts: [contracts/project-list-flow.md](contracts/project-list-flow.md), [contracts/status-screen.md](contracts/status-screen.md)
