# Data Model: Project / Status (002-project-status)

**Feature**: 002-project-status  
**Date**: 2026-02-01

## Entities

### Project

- **Purpose**: Represents a Serverpod Cloud project the user has access to. Shown in the project list with an indicator for linked vs available.
- **Attributes** (logical; implementation maps from serverpod_cloud_cli / Cloud API):
  - Identifier: string (or id) — unique project id for API and current-project reference.
  - Display name: string — for list display.
  - Linked vs available: boolean or enum — "linked" = associated with a local server directory; "available" = in account but not necessarily linked. Used to show a visible indicator (e.g. label or icon) per project in the list.
- **Lifecycle**: Fetched when user opens project list; not persisted by the app (comes from Cloud).
- **Relationships**: Many projects per account; user selects one as current project (session-only).

### Current project

- **Purpose**: The project context selected by the user (by clicking one in the list or choosing a server directory). Used for status screen and later for deploy.
- **Attributes** (logical):
  - Reference to a Project (identifier or full model).
  - Session-scoped only: held in memory; cleared when app closes or user signs out.
- **Lifecycle**: Set when user clicks a project in the list or chooses a valid server directory; cleared when user selects a different project, signs out, or closes the app.
- **Validation**: Server directory choice must be validated (FR-005); invalid choice must not set current project and must show a clear message.

### Project status

- **Purpose**: The state of a project shown on the status screen: deployment state, last deploy time, and environment if the CLI exposes it.
- **Attributes** (logical; implementation maps from serverpod_cloud_cli / Cloud API):
  - Deployment state: e.g. Live, Deploying, Failed (or equivalent from CLI).
  - Last deploy time: timestamp or formatted string for display.
  - Environment: optional, if the CLI exposes it.
- **Lifecycle**: Fetched when user navigates to the status screen (for the current project); not persisted (always fresh from Cloud).
- **Relationships**: One status per current project; status screen shows status for current project only.

### Server directory

- **Purpose**: A folder on the user’s machine that contains a Serverpod server linked to a Cloud project; optional way to set current project.
- **Attributes** (logical):
  - Path: filesystem path to the directory.
  - Resolved project: after validation, maps to a Project (identifier/name) so it can be set as current project.
- **Validation**: Must be a valid server directory (e.g. contains serverpod config) and linked to a Cloud project; otherwise show clear message and do not set current project (FR-005).

## UI state (non-persisted)

- **Project list state**: One of: loading, loaded (list of projects), empty (no projects), error (with message key or text for retry). Per FR-002.
- **Status screen state**: One of: no current project (show message or prompt), loading status, loaded (status data), error (with message and retry). Per FR-007, FR-008.
- **Current project**: Held in app state (e.g. Cubit); null when none selected or after sign-out/restart.

## Notes

- No persistence for current project; session-only in-memory (per spec and research).
- Project list and status data come from serverpod_cloud_cli (same as CLI); no local database for projects.
- Auth/session remains per 001-login (serverpod_cloud_cli persistent storage). Project/status features depend on user being logged in.
