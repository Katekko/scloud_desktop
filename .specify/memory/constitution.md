<!--
  Sync Impact Report
  Version change: 1.0.0 → 1.1.0
  Modified principles: None
  Added sections: Principle VI. Localization (l10n)
  Removed sections: None
  Templates: plan-template.md ✅ (Constitution Check should include l10n gate)
             spec-template.md ✅ (no principle-specific changes)
             tasks-template.md ✅ (task categorization unchanged)
  Follow-up TODOs: None
-->

# scloud_desktop Constitution

## Core Principles

### I. Desktop-First

The system is a desktop application, not a terminal CLI. All user interaction MUST
occur through a graphical interface (Flutter UI). The primary target platform is
Linux; other desktop platforms (macOS, Windows) MAY be supported. Rationale: The
product exists to provide the same capabilities as the Serverpod Cloud CLI in a
desktop-native, discoverable way.

### II. CLI Parity

The application MUST offer functional parity with the Serverpod Cloud CLI (scloud)
for deploy and management workflows. Supported operations MUST include: auth
(login), deploy, deployment show, status, logs, project, variable, secret, domain,
and db where applicable. Implementation SHOULD use the serverpod_cloud_cli Dart
package as a library where possible; otherwise behavior MUST match CLI outcomes.
Rationale: Users expect the desktop app to replace the CLI for day-to-day use.

### III. Test-First

Tests MUST be written before or alongside implementation for critical paths
(auth, deploy, status, API interactions). Red-Green-Refactor is preferred where
practical. Rationale: Reduces regressions and documents expected behavior for
a product that interacts with external services (Serverpod Cloud).

### IV. Integration Testing

Integration tests are REQUIRED for: Serverpod Cloud API interactions, auth flows,
deploy workflows, and any contract with serverpod_cloud_cli or Ground Control.
New features that call external services MUST have at least one integration test.
Rationale: Desktop app correctness depends on real service behavior.

### V. Simplicity & Observability

The UI MUST remain simple and focused; avoid unnecessary complexity (YAGNI).
Errors and long-running operations MUST give clear, user-visible feedback.
Structured logging and error reporting MUST support debugging without requiring
CLI access. Rationale: Usability and debuggability for a desktop tool.

### VI. Localization (l10n)

All user-facing strings MUST be localized using Flutter’s default localization
(flutter_localizations, ARB files, generated AppLocalizations). There MUST be
no hardcoded user-visible text in the UI; strings MUST be defined in ARB files
and accessed via the generated l10n API. A default locale (e.g. English) MUST
be defined. Rationale: Enables multiple languages and keeps copy in one place
from the start.

## Additional Constraints

- **Stack**: Flutter/Dart; Linux as primary desktop target.
- **Dependencies**: Prefer serverpod_cloud_cli (and its transitive deps) for
  Serverpod Cloud operations; avoid reimplementing Cloud API contracts.
- **Storage**: Use platform-appropriate persistent storage for auth and settings;
  align with serverpod_cloud_cli persistent storage where sharing state is
  desired (e.g. same login as scloud).

## Development Workflow

- Features MUST be specified in specs (user stories, requirements, acceptance
  criteria) before implementation.
- An implementation plan (plan.md) MUST reference this constitution and pass a
  Constitution Check before Phase 0 research.
- Task lists (tasks.md) MUST be derived from specs and plans; task categories
  MUST reflect principle-driven types (e.g. integration tests, CLI parity).

## Governance

This constitution supersedes ad-hoc practices for scloud_desktop. All PRs and
reviews MUST verify compliance with the principles above. Amendments REQUIRE
documentation, version bump (semantic: MAJOR for breaking principle changes,
MINOR for new principles/sections, PATCH for clarifications), and update of this
file. Use README.md and specs for runtime and feature-level guidance.

**Version**: 1.1.0 | **Ratified**: 2025-01-30 | **Last Amended**: 2025-01-30
