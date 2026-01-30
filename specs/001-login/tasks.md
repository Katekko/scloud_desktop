# Tasks: Login to Serverpod Cloud + Theme + l10n

**Input**: Design documents from `/specs/001-login/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Integration test for auth flow is included (constitution requires integration tests for auth flows).

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Flutter single project: `lib/`, `test/` at repository root (per plan.md)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create directory structure per plan: lib/theme/, lib/features/auth/, lib/l10n/, test/unit/, test/widget/, test/integration/
- [ ] T002 Add dependencies in pubspec.yaml: serverpod_cloud_cli, flutter_localizations (sdk: flutter)
- [ ] T003 [P] Configure linting in analysis_options.yaml for lib/ and test/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Theme, l10n, auth service, and app shell MUST be in place before any user story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 [P] Create lib/theme/serverpod_colors.dart with Serverpod brand color constants (primary, surface, error, etc.)
- [ ] T005 [P] Create lib/theme/app_theme.dart with ThemeData (light/dark) using serverpod_colors
- [ ] T006 Create l10n.yaml at project root with arb-dir (e.g. lib/l10n) and output-dir as needed
- [ ] T007 [P] Create lib/l10n/app_en.arb with @@locale "en" and keys: logIn, completeSignInInBrowser, signInNotCompleted, sessionExpired, networkError, signOut, and any other UI strings per contracts/login-flow.md
- [ ] T008 Run flutter gen-l10n and add localizationsDelegates (AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate) and supportedLocales to MaterialApp in lib/app.dart
- [ ] T009 Create lib/features/auth/auth_state.dart with auth flow states: unauthenticated, login_in_progress, authenticated(identity), error(message) per data-model.md and contracts/login-flow.md
- [ ] T010 Create lib/features/auth/auth_service.dart using serverpod_cloud_cli for login flow, session read/write (same storage as scloud CLI), sign-out, and session validation; expose auth state stream or getter
- [ ] T011 Add structured logging for auth flow and errors in lib/features/auth/auth_service.dart (login start, callback success/failure, sign-out, session restore/validation) and for auth_state transitions so debugging does not require CLI access (per constitution V)
- [ ] T012 Create lib/app.dart with MaterialApp applying app_theme, localizationsDelegates, supportedLocales, and a simple navigator/router that will show login, waiting, or logged-in screen based on auth_state (placeholder routes ok; wiring in US1/US2)
- [ ] T013 Update lib/main.dart to run the App widget

**Checkpoint**: Foundation ready — theme, l10n, auth_service, auth_state, and app shell exist; user story implementation can begin

---

## Phase 3: User Story 1 - First-time login (Priority: P1) 🎯 MVP

**Goal**: User can start login, see "Complete sign-in in browser", complete auth in browser, and see logged-in state with account identity; cancel/abandon returns to login with message.

**Independent Test**: Open app → tap Log in → see waiting state → complete sign-in in browser → see logged-in with identity; or cancel → see "Sign-in was not completed." and login screen.

### Integration test for User Story 1 (per constitution)

- [ ] T014 [P] [US1] Add integration test for auth flow (start login, waiting state, success path or cancel) in test/integration/auth_flow_test.dart

### Implementation for User Story 1

- [ ] T015 [US1] Create lib/features/auth/login_screen.dart with Log in button and error message area; use AppLocalizations for all strings; show error when auth_state is error (e.g. signInNotCompleted)
- [ ] T016 [US1] Create lib/features/auth/login_waiting_screen.dart showing completeSignInInBrowser via AppLocalizations
- [ ] T017 [US1] Create lib/features/auth/logged_in_screen.dart showing account identity from auth_state and Sign out button using AppLocalizations for signOut
- [ ] T018 [US1] In lib/app.dart (or a small router), show login_screen when unauthenticated, login_waiting_screen when login_in_progress, logged_in_screen when authenticated; wire auth_service.authState
- [ ] T019 [US1] Wire login_screen "Log in" to call auth_service.login(); set state to login_in_progress and navigate to waiting screen; on auth callback set authenticated(identity) or error(signInNotCompleted/network) and navigate accordingly
- [ ] T020 [US1] Handle cancel/abandon: when auth flow returns cancelled or abandoned, set auth_state to error with signInNotCompleted message; ensure login_screen displays it

**Checkpoint**: User Story 1 is fully functional — first-time login and cancel flow work and are testable independently

---

## Phase 4: User Story 2 - Already logged in (Priority: P2)

**Goal**: Session persists across app restarts; on reopen app shows logged-in state and account identity; invalid session on startup shows "Session expired. Please sign in again." and login screen.

**Independent Test**: Log in once, close app, reopen → see logged-in (no login screen). Invalidate session (or simulate) → reopen → see sessionExpired message and login screen.

### Implementation for User Story 2

- [ ] T021 [US2] On app startup (in lib/app.dart or main.dart), call auth_service to restore session from CLI storage; if valid set auth_state to authenticated(identity), else set unauthenticated and error(sessionExpired) when session invalid/expired
- [ ] T022 [US2] Ensure UI shows logged_in_screen with correct account identity when session restored on startup; ensure login_screen is not shown when session is valid
- [ ] T023 [US2] When restored session is invalid/expired, show sessionExpired message (from AppLocalizations) and login_screen per FR-007

**Checkpoint**: User Stories 1 and 2 work — persistence and invalid-session handling are testable independently

---

## Phase 5: User Story 3 - Log out (Priority: P3)

**Goal**: Logged-in user can sign out; app clears session and shows login screen; next launch shows login screen.

**Independent Test**: Log in → tap Sign out → see login screen; reopen app → see login screen.

### Implementation for User Story 3

- [ ] T024 [US3] Implement auth_service.signOut() to clear session using same storage as scloud CLI and set auth_state to unauthenticated
- [ ] T025 [US3] Wire logged_in_screen Sign out button to auth_service.signOut(); ensure app navigates to login_screen and does not perform any action with previous session

**Checkpoint**: All user stories are complete — login, persistence, invalid session, and sign-out work independently

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and validation

- [ ] T026 [P] Update README.md or docs with run instructions (flutter run -d linux, l10n: flutter gen-l10n)
- [ ] T027 Run quickstart.md validation (manual or script): first-time login, persistence, sign-out, cancel, invalid session

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Stories (Phase 3–5)**: All depend on Foundational
  - US1 (Phase 3) can start after Phase 2
  - US2 (Phase 4) depends on US1 (needs login_screen, logged_in_screen, auth_service restore)
  - US3 (Phase 5) depends on US1 (needs logged_in_screen and auth_service)
- **Polish (Phase 6)**: Depends on completion of desired user stories

### User Story Dependencies

- **US1 (P1)**: No dependency on US2/US3 — implements login, waiting, logged-in screen and auth flow
- **US2 (P2)**: Depends on US1 (restore session at startup; reuse login_screen and logged_in_screen)
- **US3 (P3)**: Depends on US1 (sign-out on logged_in_screen; auth_service.signOut)

(T011: structured logging depends on T010 auth_service; implement after auth_service exists.)

### Within Each User Story

- Integration test (T014) can be written before or alongside US1 implementation
- Screens before wiring; auth_service usage in app/router after screens exist

### Parallel Opportunities

- T004, T005, T007 can run in parallel (theme and ARB files)
- T014 (integration test) can be started in parallel with T015–T020
- T026 (docs) can run in parallel with other Polish tasks

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup  
2. Complete Phase 2: Foundational (CRITICAL)  
3. Complete Phase 3: User Story 1  
4. **STOP and VALIDATE**: Test first-time login and cancel flow  
5. Demo if ready  

### Incremental Delivery

1. Setup + Foundational → theme, l10n, auth_service, app shell  
2. US1 → first-time login + waiting + logged-in screen → MVP  
3. US2 → session restore + invalid session message  
4. US3 → sign out  
5. Polish → docs and quickstart validation  

---

## Notes

- [P] = different files, no dependencies; [USn] = task belongs to that user story
- All user-facing strings MUST come from AppLocalizations (ARB); no hardcoded messages (constitution l10n)
- Session storage MUST match scloud CLI (auth_service uses serverpod_cloud_cli persistent storage)
- Commit after each task or logical group; stop at any checkpoint to validate story independently
