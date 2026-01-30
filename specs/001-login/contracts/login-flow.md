# Contract: Login flow states and outcomes

**Feature**: 001-login  
**Type**: UI / state contract (no REST API; desktop app)

## Auth states

The app SHALL model auth as one of:

| State | Description | UI |
|-------|-------------|-----|
| `unauthenticated` | No valid session | Login screen; user can initiate login |
| `login_in_progress` | Auth flow started, waiting for user in browser | Waiting screen: "Complete sign-in in browser" (or equivalent) |
| `authenticated` | Valid session; identity available | Post-login screen; show account identity; user can sign out |
| `error` | Login failed or cancelled | Show message (per FR-006, FR-007); user can retry or return to login |

## Transitions

- **unauthenticated** → **login_in_progress**: User taps "Log in"; app starts Serverpod Cloud auth flow and shows waiting state.
- **login_in_progress** → **authenticated**: User completes auth in browser; app receives confirmation and restores session; show identity.
- **login_in_progress** → **unauthenticated** (cancel): User cancels/abandons; app shows message "Sign-in was not completed." and returns to login screen.
- **login_in_progress** → **error**: Network or other failure; show clear message; allow retry.
- **authenticated** → **unauthenticated**: User signs out or session invalid/expired; if expired, show "Session expired. Please sign in again." then login screen.

## Required user-facing strings (localized via l10n)

All user-facing strings MUST be defined in ARB files and accessed via `AppLocalizations`. Keys (or equivalent) for:

- Waiting: "Complete sign-in in browser" (or equivalent, consistent with CLI).
- Cancel/abandon: "Sign-in was not completed."
- Session invalid: "Session expired. Please sign in again."
- Network error: Clear, user-friendly message and option to retry (exact wording implementation-defined).

## Session storage contract

- Read/write of session SHALL use the same storage and format as the scloud CLI (serverpod_cloud_cli persistent storage). No app-specific auth storage root.
