# Feature Specification: Login to Serverpod Cloud

**Feature Branch**: `001-login`  
**Created**: 2025-01-30  
**Status**: Draft  
**Input**: User description: "lets specify the login"

## Clarifications

### Session 2025-01-30

- Q: Should the desktop app use the same session storage as the scloud CLI so that one login works for both app and CLI, or keep app-only session storage? → A: Same storage as scloud CLI when possible — one login works for both app and CLI.
- Q: Should the app show an explicit loading/waiting state while the auth flow is in progress? → A: Yes; use "Complete sign-in in browser" (like the CLI).
- Q: When the stored session is invalid/expired, should the app show a message or keep it optional? → A: Required: show a short message (e.g. "Session expired. Please sign in again.") when session is invalid/expired.
- Q: When the user cancels or abandons login, should the app show a message or keep it optional? → A: Required: show a short message (e.g. "Sign-in was not completed.") when user cancels or abandons login.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-time login (Priority: P1)

A user opens the desktop app for the first time (or after signing out). They are not logged in. They start the login flow from the app. They complete authentication with their Serverpod Cloud account and return to the app. The app shows that they are logged in (e.g. account identity or home screen).

**Why this priority**: Login is the gate to all other features; without it the app cannot talk to Serverpod Cloud.

**Independent Test**: Can be fully tested by opening the app, triggering login, completing auth, and verifying the app shows a logged-in state. Delivers a working authenticated session.

**Acceptance Scenarios**:

1. **Given** the user is not logged in, **When** the user chooses to log in, **Then** the app starts the Serverpod Cloud authentication flow and shows an explicit waiting state (e.g. "Complete sign-in in browser", consistent with the CLI) until the user returns from the external flow.
2. **Given** the user has completed authentication in the external flow, **When** the app receives confirmation, **Then** the app shows the user as logged in and displays account identity (e.g. email or username).
3. **Given** the user is on the login screen, **When** the user cancels or abandons the flow, **Then** the app returns to the unauthenticated state without showing a logged-in identity.

---

### User Story 2 - Already logged in (Priority: P2)

A user who has previously logged in opens the app again. The app restores the session and shows the user as logged in without asking them to log in again.

**Why this priority**: Session persistence makes the app usable day-to-day; without it every launch would require re-authentication.

**Independent Test**: Log in once, close the app, reopen; the app shows the user as logged in. Delivers persistent session across restarts.

**Acceptance Scenarios**:

1. **Given** the user has logged in and closed the app, **When** the user opens the app again, **Then** the app shows the user as logged in (no login screen).
2. **Given** the user is logged in, **When** the app starts, **Then** the app shows the correct account identity for the current session.

---

### User Story 3 - Log out (Priority: P3)

A logged-in user can sign out from within the app. After signing out, the app shows the unauthenticated state and does not use the previous session for any action.

**Why this priority**: Users need a way to switch accounts or clear session for security; lower priority than login and persistence.

**Independent Test**: Log in, then choose sign out; the app shows the login screen and does not perform any action as the previous user. Delivers clear session termination.

**Acceptance Scenarios**:

1. **Given** the user is logged in, **When** the user chooses to sign out, **Then** the app clears the session and shows the unauthenticated (login) state.
2. **Given** the user has signed out, **When** the user opens the app later, **Then** the app shows the login screen and does not auto-restore the previous session.

---

### Edge Cases

- What happens when the user closes the browser or auth window without completing login? The app MUST return to the unauthenticated state and MUST show a short message (e.g. "Sign-in was not completed.").
- How does the system handle network errors during login? The app MUST show a clear, user-friendly message and allow the user to retry.
- What happens when the stored session is no longer valid (expired or revoked)? The app MUST treat the user as not logged in, show the login screen, and MUST show a short message (e.g. "Session expired. Please sign in again.").

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow the user to initiate login to Serverpod Cloud from the desktop app.
- **FR-001a**: While the auth flow is in progress (e.g. user is in browser), the app MUST show an explicit waiting state with the message "Complete sign-in in browser" (or equivalent, consistent with the CLI).
- **FR-002**: System MUST complete authentication via the same Serverpod Cloud identity provider and account as the official CLI (scloud) so one account works for both.
- **FR-003**: System MUST show the user as logged in after successful authentication (e.g. display account identity such as email or username).
- **FR-004**: System MUST persist the session so that the user remains logged in after closing and reopening the app, until they sign out or the session becomes invalid.
- **FR-005**: System MUST allow the user to sign out; after sign-out, no action MUST be performed using the previous session.
- **FR-006**: System MUST show clear, user-friendly messages when login fails (e.g. network error, user cancelled, session invalid). When the user cancels or abandons the flow, the app MUST show a short message (e.g. "Sign-in was not completed.").
- **FR-007**: System MUST treat an invalid or expired stored session as not logged in, show the login screen, and show a short message (e.g. "Session expired. Please sign in again.").
- **FR-008**: Session persistence MUST use the same storage location and format as the scloud CLI when possible, so that logging in once (in either the app or the CLI) is sufficient for both.

### Key Entities

- **User / account identity**: The Serverpod Cloud account the user logs in with; represented in the app for display (e.g. email or username) and for authorizing actions. No local account creation—identity comes from Serverpod Cloud.
- **Session**: The authenticated state that allows the app to perform actions on behalf of the user; persisted across app restarts until sign-out or invalidation.

## Assumptions

- Authentication flow is the same as or equivalent to the Serverpod Cloud CLI (scloud auth login) so that existing Serverpod Cloud accounts work without extra setup.
- Session persistence uses the same storage as the scloud CLI when possible so one login works for both; exact format and location follow CLI conventions.
- A single active session per app instance is sufficient for MVP; multi-account switching may be a future feature.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can complete login (from “Log in” to seeing logged-in state) in under one minute under normal conditions.
- **SC-002**: After a successful login, the user sees clear confirmation (e.g. account identity or home screen) with no ambiguity about whether they are logged in.
- **SC-003**: When login fails or is cancelled, the user sees a clear message and can retry or return to the unauthenticated state without confusion.
- **SC-004**: Session persists across app restarts so that the user does not need to log in again on every launch under normal conditions (until they sign out or the session is invalidated).
