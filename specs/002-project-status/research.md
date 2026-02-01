# Phase 0 Research: Project List & Status

**Feature**: 002-project-status  
**Date**: 2026-02-01

## 1. Project list (CLI parity)

**Decision**: Use the `serverpod_cloud_cli` Dart package to obtain the list of linked and available projects for the current account, in the same way the scloud CLI does (e.g. project list command or equivalent API).

**Rationale**:
- Spec and constitution require CLI parity: "consistent with the data the CLI exposes" (FR-001). The MVP plan states Serverpod Cloud operations use serverpod_cloud_cli (auth, session, deploy, status — same as CLI). The desktop app already uses serverpod_cloud_cli for auth (AuthRepository uses CloudCliServiceProvider, ResourceManager, GlobalConfiguration). Reusing the same package for project list guarantees the same data and semantics as `scloud` project list.
- Implementation will use the package’s command/library layer (same pattern as auth): either a project-list command/class or the cloud API client exposed by CloudCliServiceProvider. Exact entry point to be determined from the package (e.g. `commands/project/` or `cloudApiClient` methods).

**Alternatives considered**:
- Calling `Process.run('scloud', ['project', 'list'])`: would share behavior but is brittle and not ideal for a desktop UI. Rejected.
- Reimplementing against Ground Control/Serverpod Cloud APIs directly: duplicates logic and risks drift. Rejected for MVP.

**Implementation note**: After login, the app has GlobalConfiguration and CloudCliServiceProvider (or equivalent). Discover the exact API for "list projects for current user" from serverpod_cloud_cli (e.g. project command, or cloudApiClient.projects.list()). Return a list of projects with at least: identifier, display name, and whether each is "linked" or "available" so the UI can show one list with an indicator per project.

---

## 2. Project status (scloud status)

**Decision**: Use the `serverpod_cloud_cli` package to obtain project status (deployment state, last deploy time, environment if exposed) for a given project, matching the meaning of `scloud status`.

**Rationale**:
- Spec requires status "equivalent in meaning to CLI scloud status" (FR-003) and display at least deployment state and last deploy time, and environment if the CLI exposes it. Using the same package ensures parity.
- The app will pass the current project (identifier or context) to the status API/command. Same initialization pattern as auth: GlobalConfiguration, CloudCliServiceProvider, and session from existing auth storage.

**Alternatives considered**:
- Parsing `scloud status` stdout: brittle and not suitable for UI. Rejected.
- Custom API calls to Serverpod Cloud: would duplicate logic. Rejected.

**Implementation note**: Discover the exact API for "get status for project X" from serverpod_cloud_cli (e.g. status command or cloudApiClient method). Map the result to a simple model: deployment state (e.g. Live, Deploying, Failed), last deploy time, environment (optional). Handle network errors and invalid session the same way as auth (clear message, retry).

---

## 3. Current project (session-only, in-memory)

**Decision**: Hold the current project in application state (e.g. a Cubit or shared state) for the lifetime of the app process only. Do not persist it to disk; when the app is closed, current project is cleared.

**Rationale**:
- Spec clarification: "Current project is session-only (not persisted across app restarts)." No additional storage or persistence layer is required.
- Simplest implementation: a single source of truth (e.g. ProjectListCubit or a dedicated CurrentProjectCubit) that holds the selected project; status screen and future deploy feature read from it. When the user clicks a project in the list, update this state; when the user signs out, clear it (and redirect to login per FR-009).

**Implementation note**: Current project can be represented by the same identifier/model returned by the project list (e.g. project id or a small value object). No database or shared_preferences for current project; in-memory only.

---

## 4. Server directory (optional path to set current project)

**Decision**: Support setting current project by choosing a server directory (folder containing a Serverpod server linked to a Cloud project) as an optional alternative to clicking a project in the list. Use serverpod_cloud_cli or project config discovery to validate the directory and resolve the linked project.

**Rationale**:
- Spec FR-004: "allow the user to set the current project by clicking a project in the list (primary) or by choosing a server directory." So list-click is primary; server directory is secondary. Validation (FR-005) must show a clear message when the choice is invalid.
- CLI users often run commands from a server directory; supporting this in the app keeps parity and allows "open folder → set current project from here" workflows later.

**Implementation note**: If the package exposes a way to "resolve project from server directory" (e.g. read serverpod.yaml or link file), use it. Otherwise, validate directory contains expected project config and map to a known project from the list. Phase 1 tasks can detail the exact validation steps.

---

## 5. Navigation (separate screens)

**Decision**: Implement project list and status on separate screens. Router has a route for the project list (e.g. `/projects`) and a route for the status screen (e.g. `/status`). User navigates from list to status (e.g. "View status" or similar); list remains the entry point after login (or home can show list).

**Rationale**:
- Spec clarification: "Separate screens: project list on one screen; navigating to another screen shows status for the current project." (FR-011.)
- Matches existing app: go_router with routes per screen. Extend redirect logic so that when not logged in, project/status routes redirect to login; when logged in, home can be project list and status is a separate route.

**Implementation note**: After 001-login, "home" is LoggedInScreen. For 002-project-status, home can become the project list screen (or a shell with nav to list and status). Status screen is only meaningful when a current project is set; if user navigates to status without a current project, show FR-007 message or redirect to list. Details in contracts.
