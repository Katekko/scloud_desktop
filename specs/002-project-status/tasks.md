# Tasks: Project / Status

**Input**: Design documents from `/specs/002-project-status/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Integration tests for project list and status flows are included (constitution requires integration tests for Serverpod Cloud API interactions).

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Flutter single project: `lib/`, `test/` at repository root (per plan.md)
- New feature code: `lib/features/projects/`, `lib/features/status/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Feature directories and l10n placeholders for project/status

- [x] T001 Create directory structure per plan: lib/features/projects/, lib/features/status/
- [x] T002 Verify serverpod_cloud_cli is in pubspec.yaml (already present from 001-login)
- [x] T003 [P] Add l10n keys for project list and status in lib/l10n/app_en.arb: projectListTitle, noProjectsYet, projectListLoading, projectListErrorRetry, linked, available, noProjectSelected, chooseProjectToViewStatus, statusTitle, deploymentState, lastDeployTime, environment, statusErrorRetry, invalidServerDirectory (per contracts)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Models, repository, and routes MUST be in place before any user story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 [P] Create Project model in lib/features/projects/project.dart with id, displayName, isLinked (or linkedOrAvailable) per data-model.md
- [x] T005 [P] Create ProjectStatus model in lib/features/projects/project_status.dart with deploymentState, lastDeployTime, environment (optional) per data-model.md
- [x] T006 Create ProjectRepository in lib/features/projects/project_repository.dart using serverpod_cloud_cli to fetch project list and fetch status for a project (per research.md and plan)
- [x] T007 Add route /status in lib/router/app_router.dart; redirect unauthenticated users to login when accessing /home or /status. Post-login: user goes to /home; /home displays the project list (available projects) — i.e. home screen shows ProjectListScreen content
- [x] T008 Register ProjectRepository in lib/di/injection.dart

**Checkpoint**: Foundation ready — models, repository, and routes exist; user story implementation can begin

---

## Phase 3: User Story 1 - View project list (Priority: P1) 🎯 MVP

**Goal**: Logged-in user sees project list screen with a single list of projects and a visible indicator (label or icon) for linked vs available per project; loading, empty, and error states with retry; clicking a project sets it as current for the session.

**Independent Test**: Log in, open project list; app shows list of projects with linked/available indicator; empty state when no projects; loading and error with retry; click a project to set current.

### Integration test for User Story 1 (per constitution)

- [x] T009 [P] [US1] Add integration test for project list flow (login, go to home, see project list or empty on home) in test/integration/project_status_flow_test.dart

### Implementation for User Story 1

- [x] T010 [US1] Create ProjectListCubit in lib/features/projects/project_list_cubit.dart with states: loading, loaded(List<Project>), empty, error(message); and currentProject (Project?); methods loadProjects(), selectProject(Project), clearCurrentProject(); use ProjectRepository per contracts/project-list-flow.md
- [x] T011 [US1] Create ProjectListScreen widget class in lib/features/projects/project_list_screen.dart: show loading / empty / loaded / error per contract; single scrollable list with visible indicator (label or icon) for linked vs available per project; on tap project call cubit.selectProject(project) per FR-001, FR-002, FR-004, FR-010
- [x] T012 [US1] Register ProjectListCubit in lib/di/injection.dart (lazy singleton or factory so StatusCubit can read currentProject); wire ProjectListScreen to /home in lib/router/app_router.dart so that when user is logged in, home shows the project list (available projects)
- [x] T013 [US1] Use AppLocalizations in ProjectListScreen for noProjectsYet, projectListLoading, projectListErrorRetry, linked, available (no hardcoded strings) per FR-002 and contracts
- [x] T014 [US1] Add structured logging for project list load and errors in lib/features/projects/project_list_cubit.dart and lib/features/projects/project_repository.dart per constitution V

**Checkpoint**: User Story 1 is fully functional — project list with indicator, loading/empty/error, click to set current project; testable independently

---

## Phase 4: User Story 2 - View status for current project (Priority: P2)

**Goal**: Logged-in user navigates to status screen; when a current project is set, app shows deployment state, last deploy time, and environment (if CLI exposes it); when no current project, app shows clear message or prompt; loading and error with retry.

**Independent Test**: Set current project from list, navigate to status → see status; navigate to status without current project → see no-project message; loading and error with retry.

### Integration test for User Story 2 (per constitution)

- [x] T015 [P] [US2] Add integration test for status flow (select project, navigate to status, see status; or no current project → see message) in test/integration/project_status_flow_test.dart

### Implementation for User Story 2

- [x] T016 [US2] Create StatusCubit in lib/features/status/status_cubit.dart with states: noCurrentProject, loading, loaded(ProjectStatus), error(message); method loadStatus() that reads current project from get_it<ProjectListCubit>.state.currentProject and calls ProjectRepository.getStatus(projectId); per contracts/status-screen.md
- [x] T017 [US2] Create StatusScreen widget class in lib/features/status/status_screen.dart: show noCurrentProject message or prompt (FR-007), or loading, or deployment state + last deploy time + environment (FR-003), or error with retry (FR-008); use AppLocalizations for all strings
- [x] T018 [US2] Register StatusCubit in lib/di/injection.dart and add /status route in lib/router/app_router.dart; add navigation from project list to status (e.g. "View status" button or app bar action that navigates to /status)
- [x] T019 [US2] Add structured logging for status load in lib/features/status/status_cubit.dart per constitution V

**Checkpoint**: User Stories 1 and 2 work — list, select project, view status; no-current-project and error handling testable independently

---

## Phase 5: User Story 3 - Set current project by selecting from list (Priority: P3)

**Goal**: Primary path (click project in list) is already in US1; add optional "choose server directory" flow: user selects a folder, app validates it (valid Serverpod server linked to Cloud); if valid set current project, if invalid show clear message (FR-005).

**Independent Test**: Choose valid server directory → current project set; choose invalid folder → clear message, current project not set; current project retained until user selects different project or signs out; not persisted across app restart.

### Implementation for User Story 3

- [x] T020 [US3] Implement server directory validation in lib/features/projects/project_repository.dart (or lib/features/projects/server_directory_validator.dart): resolve project from directory path (e.g. serverpod config, link to Cloud project per research.md); return Project if valid, null or throw with reason if invalid
- [x] T021 [US3] Add "Choose server directory" option to project list UI (e.g. button or menu in lib/features/projects/project_list_screen.dart); on directory selected call repository validation; if valid call ProjectListCubit.selectProject(resolvedProject), else show invalidServerDirectory message via AppLocalizations (FR-005)
- [x] T022 [US3] Ensure current project is cleared on sign out: when AuthCubit transitions to unauthenticated, call ProjectListCubit.clearCurrentProject() (e.g. from AuthCubit.signOut() or router redirect) per FR-006, FR-009

**Checkpoint**: All user stories complete — list, status, click-to-select, optional server directory, current project cleared on sign out

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and validation

- [x] T023 [P] Update README.md or docs with project list and status usage (navigate to projects, select project, view status) per quickstart.md
- [ ] T024 Run quickstart.md validation for 002-project-status: list, select, status, no persistence across restart, sign out clears current project

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational — list screen, repository, click to set current
- **User Story 2 (Phase 4)**: Depends on Foundational and US1 (needs ProjectListCubit with currentProject and home showing project list) — status screen reads current project
- **User Story 3 (Phase 5)**: Depends on US1 (ProjectListCubit.selectProject exists) — adds server directory path and sign-out clear
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: After Foundational — no dependency on US2/US3
- **US2 (P2)**: After US1 (needs current project state and home with project list) — independently testable with a selected project
- **US3 (P3)**: After US1 — adds server directory and sign-out clear; independently testable

### Within Each User Story

- Integration test can be written alongside or after implementation (constitution: tests before or alongside)
- Models (T004, T005) before repository (T006); repository before cubits and screens
- Register cubits and wire routes before navigation from list to status

### Parallel Opportunities

- T004, T005 can run in parallel (different model files)
- T009, T015 (integration tests) can be written in parallel with implementation
- T023 (docs) can run in parallel with other polish

---

## Parallel Example: User Story 1

```text
# Models (Foundational) in parallel:
T004: Create Project model in lib/features/projects/project.dart
T005: Create ProjectStatus model in lib/features/projects/project_status.dart

# After T006–T008, US1 implementation:
T010: ProjectListCubit in lib/features/projects/project_list_cubit.dart
T011: ProjectListScreen in lib/features/projects/project_list_screen.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (T004–T008)
3. Complete Phase 3: User Story 1 (T009–T014)
4. **STOP and VALIDATE**: Test project list independently (login → list → empty/loaded → click to set current)
5. Demo: list projects with linked/available indicator; select one as current

### Incremental Delivery

1. Setup + Foundational → models, repository, routes
2. Add US1 → project list + click to set current → Demo (MVP)
3. Add US2 → status screen → Demo
4. Add US3 → server directory + sign-out clear → Demo
5. Polish → docs and quickstart validation

### Parallel Team Strategy

- After Foundational: Developer A does US1 (list + cubit), Developer B can start US2 (StatusCubit, StatusScreen) once T010–T012 are done so currentProject exists
- US3 can start after US1 list and selection exist

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to spec user story for traceability
- Each user story is independently completable and testable
- All user-facing strings via ARB/AppLocalizations (constitution VI)
- Widgets as classes (StatelessWidget/StatefulWidget), not widget-returning functions (constitution VII)
- Commit after each task or logical group; stop at any checkpoint to validate story independently
