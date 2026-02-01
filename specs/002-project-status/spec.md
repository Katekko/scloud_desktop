# Feature Specification: Project / Status

**Feature Branch**: `002-project-status`  
**Created**: 2026-02-01  
**Status**: Draft  
**Input**: User description: "lets make the second feature, the project / status"

## Clarifications

### Session 2026-02-01

- Q: What must the status view display? → A: Deployment state plus last deploy time (and environment if CLI exposes it).
- Q: How does the user set the current project? → A: List projects (like the CLI); user clicks one project to set it as current; that project is then used for status and other commands. Current project is session-only (not persisted across app restarts).
- Q: How should the project list and status view be arranged? → A: Separate screens: project list on one screen; navigating to another screen shows status for the current project.
- Q: How should the project list show "linked" vs "available" projects? → A: One list with an indicator: show all projects in one list with a visible indicator (e.g. label or icon) for linked vs available.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View project list (Priority: P1)

A logged-in user opens the app and navigates to the project list screen, where they see a list of their projects (same data as the CLI project list). The user can see which projects they have access to. Clicking a project in the list sets it as the current project. To see status (or later deploy), the user navigates to the status screen.

**Why this priority**: Proving the app can read project/account state is the core goal of this feature; the project list is the primary proof.

**Independent Test**: Log in, open the project/list view; the app shows the list of projects for the current account. Delivers visibility of account projects in the desktop app.

**Acceptance Scenarios**:

1. **Given** the user is logged in, **When** the user opens or navigates to the project list, **Then** the app displays a single list of projects for the current account, with a visible indicator (e.g. label or icon) for linked vs available per project.
2. **Given** the user has no projects (or empty list), **When** the user opens the project list, **Then** the app shows an empty state with a clear message (e.g. no projects yet) rather than an error.
3. **Given** the user is logged in, **When** the project list is loading, **Then** the app shows a loading state until the list is available.

---

### User Story 2 - View status for current project (Priority: P2)

A logged-in user has set a current project (e.g. by clicking one in the list or choosing a server directory). They navigate to the status screen to see the status of that project: deployment state, last deploy time, and environment if the CLI exposes it. The app shows this on a separate screen from the project list so the user knows the state of their project without running the CLI.

**Why this priority**: Status for the current project completes the “read project/account state” proof and sets up the deploy feature.

**Independent Test**: Establish a current project (e.g. choose a server directory or select a project), open status; the app shows the status for that project. Delivers status visibility in the desktop app.

**Acceptance Scenarios**:

1. **Given** the user has a current project (chosen server directory or selected project), **When** the user opens or refreshes the status view, **Then** the app displays deployment state, last deploy time, and environment (if the CLI exposes it) for that project.
2. **Given** the user has no current project, **When** the user tries to view status, **Then** the app either prompts to choose a project/server directory or shows a clear message that no project is selected.
3. **Given** the user is viewing status, **When** the status is loading, **Then** the app shows a loading state until status is available.

---

### User Story 3 - Set current project by selecting from list (Priority: P3)

A logged-in user sees the project list and wants to set which project is “current” so that status (and later deploy) apply to the right project. The primary way is to click one project in the list; that project becomes the current project for the session. Optionally, the user may set current project by choosing a server directory (a folder that contains a Serverpod server linked to a Cloud project). The current project is used for status and other commands until the user selects a different project or signs out; it is not persisted across app restarts.

**Why this priority**: Establishing current project context is required for status (and deploy) to be meaningful; it can be developed after list and status display.

**Independent Test**: Open project list, click one project; the app sets it as current and status (if viewed) reflects it. Delivers clear current-project context.

**Acceptance Scenarios**:

1. **Given** the user is logged in and sees the project list, **When** the user clicks a project in the list (or chooses a valid server directory), **Then** the app sets that as the current project and subsequent status (and later deploy) apply to it.
2. **Given** the user selects a folder that is not a valid server directory (or not linked to a Cloud project), **When** the app validates the choice, **Then** the app shows a clear message and does not set it as current project.
3. **Given** the user has set a current project, **When** the user continues using the app in the same session, **Then** the app retains the current project until the user selects a different project or signs out; the current project is cleared when the app is closed (not persisted across restarts).

---

### Edge Cases

- What happens when the user is not logged in? The app MUST not show project list or status; the user MUST be directed to log in first (per Login feature).
- How does the system handle network errors when fetching project list or status? The app MUST show a clear, user-friendly message and allow the user to retry.
- What happens when the session becomes invalid while viewing projects or status? The app MUST treat the user as not logged in and show the login/session-expired behavior per Login feature.
- What happens when the user has many projects? The app MUST display the list in a usable way (e.g. scrollable list or paging) so all projects are accessible.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow a logged-in user to view a single list of linked and available projects for their account (consistent with the data the CLI exposes), with a visible indicator (e.g. label or icon) for linked vs available per project.
- **FR-002**: System MUST display the project list with a loading state while data is being fetched and an empty state when there are no projects.
- **FR-003**: System MUST allow a logged-in user to view the status of the current project when a current project is set, displaying at least deployment state and last deploy time, and environment if the CLI exposes it.
- **FR-004**: System MUST allow the user to set the current project by clicking a project in the list (primary) or by choosing a server directory (folder containing a Serverpod server linked to Cloud).
- **FR-005**: System MUST validate the server directory (or selection) before setting it as current project and show a clear message when the choice is invalid.
- **FR-006**: System MUST retain the current project for the session until the user selects a different project or signs out; the current project MUST NOT be persisted across app restarts.
- **FR-007**: System MUST show a clear message when the user attempts to view status without a current project, and either prompt to choose a project or explain that none is selected.
- **FR-008**: System MUST show loading state when fetching status and handle network errors with a clear, user-friendly message and option to retry.
- **FR-009**: System MUST not show project list or status when the user is not logged in; the user MUST be directed to log in first.
- **FR-010**: System MUST display the project list in a usable way when the user has many projects (e.g. scrollable or paged).
- **FR-011**: System MUST show the project list and the status view on separate screens; the user navigates from the project list screen to the status screen to view status for the current project.

### Key Entities

- **Project**: A Serverpod Cloud project the user has access to; has an identifier and display information (e.g. name); may be “linked” (associated with a local server directory) or “available” in the account. The project list shows all projects in one list with a visible indicator for linked vs available.
- **Current project**: The project context set when the user clicks a project in the list (or chooses a server directory); used for status and later for deploy; session-only (cleared when the app is closed).
- **Project status**: The state of a project shown in the status view: deployment state (e.g. Live, Deploying, Failed), last deploy time, and environment if the CLI exposes it.
- **Server directory**: A folder on the user’s machine that contains a Serverpod server linked to a Cloud project; used to establish current project context.

## Assumptions

- Project list and status data come from the same Serverpod Cloud APIs or mechanisms as the CLI (`scloud status`, project list); no new backend is required.
- “Linked or available” projects are defined by the existing Cloud/CLI model; the app displays what the CLI would show.
- A single current project per session is sufficient for MVP; the user sets it by clicking a project in the list (or choosing a server directory). Current project is not persisted across app restarts.
- The project list and the status view are on separate screens; the user navigates from the list to the status screen.
- Session and login behavior are defined by the Login feature (001-login); this feature depends on the user being logged in.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A logged-in user can see the list of their projects within a few seconds of opening the project list view under normal conditions.
- **SC-002**: A logged-in user can see the status of the current project within a few seconds of opening or refreshing the status view when a current project is set.
- **SC-003**: A user can set the current project by clicking a project in the list (or choosing a server directory) and then see status for that project without using the CLI.
- **SC-004**: When the project list is empty or status cannot be loaded, the user sees clear, actionable messages (empty state or error with retry) rather than a generic failure.
- **SC-005**: The app demonstrates that it can read project/account state (list and status) in parity with the CLI, so the team can confidently proceed to deploy and deployment progress features.
