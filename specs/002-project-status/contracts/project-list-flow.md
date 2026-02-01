# Contract: Project list screen and current project

**Feature**: 002-project-status  
**Type**: UI / state contract (desktop app)

## Prerequisites

- User MUST be logged in (per FR-009). If not logged in, redirect to login (per Login feature).
- Project list screen is on a separate route from the status screen (FR-011).

## Project list screen states

The project list screen SHALL model list state as one of:

| State | Description | UI |
|-------|-------------|-----|
| `loading` | Fetching project list from Cloud | Show loading indicator until list is available (FR-002) |
| `loaded` | List of projects available | Show single list with visible indicator (label or icon) for linked vs available per project (FR-001); list scrollable or paged when many projects (FR-010) |
| `empty` | No projects for account | Show empty state with clear message (e.g. no projects yet), not an error (FR-002) |
| `error` | Network or API error | Show clear, user-friendly message and option to retry (edge case) |

## Current project selection

- **Primary**: User clicks a project in the list → set that project as current project for the session (FR-004). Subsequent navigation to the status screen shows status for this project.
- **Optional**: User chooses a server directory (folder) → validate (FR-005); if valid and linked to a Cloud project, set that project as current; if invalid, show clear message and do not set current project.
- Current project is retained in memory until user selects a different project or signs out; NOT persisted across app restarts (FR-006).

## Transitions

- **Enter list screen** → fetch project list; show `loading` then `loaded` or `empty` or `error`.
- **User clicks project** → set current project (in-memory); user may then navigate to status screen.
- **User chooses server directory** → validate; if valid set current project; if invalid show message.
- **User signs out** → clear current project; redirect to login.

## Required user-facing strings (localized via l10n)

All user-facing strings MUST be in ARB files and accessed via AppLocalizations. Keys (or equivalent) for:

- Empty state: e.g. "No projects yet" (or equivalent).
- Loading: loading indicator; optional text (implementation-defined).
- Error: clear message and retry (implementation-defined).
- Invalid server directory: clear message (FR-005).
