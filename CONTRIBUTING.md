# Contributing to scloud_desktop

Thanks for your interest in contributing. Here’s how to get started.

## Development setup

1. **Clone and open the repo**

   ```bash
   git clone https://github.com/YOUR_ORG/scloud_desktop.git
   cd scloud_desktop
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   flutter run -d linux
   ```

4. **Run tests**

   ```bash
   flutter test
   ```

5. **Lint**

   ```bash
   flutter analyze
   ```

## Making changes

- Create a branch from `main` (e.g. `feature/short-description` or `fix/issue-description`).
- Keep commits focused and messages clear.
- Run `flutter analyze` and `flutter test` before opening a PR.
- Open a pull request against `main` and describe what changed and why.

## Code style

- Follow the project’s Dart/Flutter style (enforced by `analysis_options.yaml` and `flutter_lints`).
- Format with `dart format .` before committing.

## Reporting issues

Use [GitHub Issues](https://github.com/Katekko/scloud_desktop/issues). Please include:

- OS and Flutter version (`flutter doctor -v`).
- Steps to reproduce.
- Expected vs actual behavior.

## Release process

Releases are built and published by GitHub Actions when a version tag is pushed (e.g. `v1.0.0`). See [README](README.md#option-2-build-from-source) for building from source.
