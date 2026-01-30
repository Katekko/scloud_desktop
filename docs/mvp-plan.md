# MVP Plan: scloud_desktop

This document defines **which features are in the MVP** of **scloud_desktop**: a desktop version of the Serverpod Cloud CLI (scloud) for Linux. The MVP is the set of features we will deliver to show the product to the Serverpod Cloud team.

---

## Which Features Are in the MVP

These are the features we are putting inside the MVP. Each corresponds to CLI commands or workflows we want in the desktop app.

| # | Feature | CLI equivalent | Description | Status |
|---|--------|----------------|-------------|--------|
| 1 | **Login** | `scloud auth login` | Log in to Serverpod Cloud from the app (same account as CLI). Session shared with scloud so one login works for both. Sign out. Clear messages for cancel, invalid session, network error. | In progress (001-login) |
| 2 | **Project / status** | `scloud status`, project list | View linked or available projects, or show status for the current project (e.g. from a chosen server directory). Proves the app can read project/account state. | Planned |
| 3 | **Deploy** | `scloud deploy` | Trigger a deploy (e.g. from a chosen server directory). Core value: “deploy from the desktop” instead of the terminal. | Planned |
| 4 | **Deployment progress** | `scloud deployment show` | After starting a deploy, show progress (e.g. “Deploying…”, then “Live” or “Failed”). Keeps the demo concrete and shows the app stays in sync with Cloud. | Planned |
| 5 | **Logs** *(optional)* | `scloud log` | Open or stream a simple log view for the current service. Included if time allows. | Optional |
| 6 | **Me / account** *(optional)* | `scloud me` | Show logged-in user (e.g. email) so it’s clear who is connected. Included if time allows. | Optional |

**Cross-cutting for the whole MVP**

- **Theme**: Serverpod colors (serverpod.dev / Serverpod Cloud) so the app feels part of the ecosystem.
- **Internationalization (l10n)**: All user-facing strings via Flutter’s default l10n (ARB, `AppLocalizations`). Default locale English.
- **Structured logging**: Auth and key flows logged so debugging does not require the CLI.

---

## Which Features Are NOT in the MVP

We are **not** including these in the MVP; they are for a later release:

| Feature | CLI equivalent | Why not in MVP |
|--------|----------------|----------------|
| Launch (guided setup) | `scloud launch` | New-project setup; defer until after core deploy flow. |
| Variables | `scloud variable` | Config; add after deploy works. |
| Secrets | `scloud secret` | Config; add after deploy works. |
| Custom domains | `scloud domain` | Add after deploy works. |
| Database management | `scloud db` | Add after deploy works. |
| Multi-account / account switching | — | Single session per app instance for MVP. |
| macOS / Windows | — | Linux primary for MVP; other platforms later. |

---

## How We Build Each Feature

For each MVP feature we follow the same workflow:

1. **Spec** — User stories, requirements, acceptance criteria (e.g. `specs/NNN-feature-name/spec.md`).
2. **Plan** — Technical context, constitution check, project structure, design artifacts (`specs/NNN-feature-name/plan.md`).
3. **Tasks** — Phased task list with file paths and checkpoints (`specs/NNN-feature-name/tasks.md`).
4. **Implement** — Execute tasks; validate with tests and quickstart.

**First feature (Login)** is tracked in branch `001-login` and in `specs/001-login/` (spec, plan, tasks, quickstart). Later features (project/status, deploy, deployment progress, optional logs/me) will get their own spec folders and branches when we start them.

---

## Tech Stack (MVP-wide)

| Item | Choice |
|------|--------|
| **Framework** | Flutter 3.38.8 (Linux desktop primary) |
| **Serverpod Cloud** | `serverpod_cloud_cli` (auth, session, deploy, status, logs — same as CLI) |
| **UI** | Material/Cupertino; theme from Serverpod colors |
| **Localization** | `flutter_localizations`, ARB, generated `AppLocalizations` |
| **Testing** | Flutter test; integration tests for auth and (later) deploy flows |
| **Logging** | Structured logging for auth and key operations |

---

## Reference Artifacts

| Document | Path | Purpose |
|----------|------|---------|
| **Login spec** | [specs/001-login/spec.md](../specs/001-login/spec.md) | Login user stories and requirements. |
| **Login plan** | [specs/001-login/plan.md](../specs/001-login/plan.md) | Technical context, theme, l10n, structure. |
| **Login tasks** | [specs/001-login/tasks.md](../specs/001-login/tasks.md) | Phased tasks for login (T001–T027). |
| **Quickstart** | [specs/001-login/quickstart.md](../specs/001-login/quickstart.md) | Run app and validate login, theme, l10n. |
| **Constitution** | [.specify/memory/constitution.md](../.specify/memory/constitution.md) | Project principles (desktop-first, CLI parity, tests, l10n, etc.). |

---

## Summary

- **MVP features we are putting in**: (1) Login, (2) Project/status, (3) Deploy, (4) Deployment progress, (5) Logs *optional*, (6) Me/account *optional*, plus theme, l10n, and structured logging across the app.
- **Not in MVP**: Launch, variables, secrets, domains, db, multi-account, non-Linux platforms.
- **Order**: We are building Login first (001-login); then project/status, deploy, deployment progress, and optionally logs and me.
