# Contract: Status screen

**Feature**: 002-project-status  
**Type**: UI / state contract (desktop app)

## Prerequisites

- User MUST be logged in. If not logged in, redirect to login (FR-009).
- Status screen is on a separate route from the project list (FR-011).

## Status screen states

The status screen SHALL model state as one of:

| State | Description | UI |
|-------|-------------|-----|
| `no_current_project` | User has not set a current project | Show clear message or prompt to choose a project (FR-007); do not show status |
| `loading` | Fetching status for current project | Show loading state until status is available (FR-008) |
| `loaded` | Status data available | Display deployment state, last deploy time, and environment if CLI exposes it (FR-003) |
| `error` | Network or API error | Show clear, user-friendly message and option to retry (FR-008) |

## Data displayed when loaded

When state is `loaded`, the screen SHALL display at least (per spec and clarifications):

- **Deployment state**: e.g. Live, Deploying, Failed (or equivalent from scloud status).
- **Last deploy time**: timestamp or formatted string.
- **Environment**: if the CLI exposes it; otherwise omit.

## Transitions

- **User navigates to status without current project** → show `no_current_project` (message or prompt to go to list).
- **User navigates to status with current project** → fetch status; show `loading` then `loaded` or `error`.
- **User refreshes** → re-fetch status; show `loading` then `loaded` or `error`.
- **User signs out or current project cleared** → when navigating to status, show `no_current_project`.

## Required user-facing strings (localized via l10n)

All user-facing strings MUST be in ARB files and accessed via AppLocalizations. Keys (or equivalent) for:

- No current project: e.g. "No project selected" / "Choose a project to view status" (or equivalent) (FR-007).
- Loading: loading indicator; optional text.
- Error: clear message and retry (FR-008).
- Labels for deployment state, last deploy time, environment (implementation-defined).
