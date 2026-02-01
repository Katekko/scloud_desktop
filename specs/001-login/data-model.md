# Data Model: Login (001-login)

**Feature**: 001-login  
**Date**: 2025-01-30

## Entities

### User / account identity

- **Purpose**: Represents the Serverpod Cloud account the user is logged in as. Used for display (e.g. email or username) and for authorizing actions. Identity comes from Serverpod Cloud; no local account creation.
- **Attributes** (logical; implementation may map from serverpod_cloud_cli / API):
  - Display identifier: string (e.g. email or username), for UI only.
  - (No local password or credentials; auth is delegated to Serverpod Cloud.)
- **Lifecycle**: Exists only while a valid session exists. Cleared on sign-out or when session is invalid/expired.
- **Relationships**: One active user per app instance (MVP). Session holds reference to this identity while logged in.

### Session

- **Purpose**: The authenticated state that allows the app to perform actions on behalf of the user. Persisted across app restarts until sign-out or invalidation.
- **Attributes** (logical; storage format follows serverpod_cloud_cli):
  - Valid: boolean (or derived from token validity).
  - Associated identity: reference to User/account identity for display.
  - Stored in same location/format as scloud CLI (per FR-008 and research).
- **State transitions**:
  - None → Active: after successful login.
  - Active → None: after sign-out or when detected invalid/expired.
- **Validation**: Session is invalid if expired or revoked; app treats as “not logged in” and shows login screen + message (FR-007).

## UI state (non-persisted)

- **Auth flow state**: One of: unauthenticated, login_in_progress (waiting for browser), authenticated, error (with message key or text).
- **Display messages**: Short user-facing strings for “Sign-in was not completed.”, “Session expired. Please sign in again.”, network error, etc. (see spec FR-006, FR-007).

## Notes

- No local database or custom persistence for auth; use serverpod_cloud_cli’s persistent storage and auth key manager only.
- Theme is not part of the data model; it is app-wide configuration (see plan theme section and research).
