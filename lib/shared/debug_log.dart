import 'package:flutter/foundation.dart';

/// Centralized debug logging. Encapsulates [kDebugMode] and [debugPrint]
/// so call sites don't repeat the same check. Only prints when [enabled]
/// is true (defaults to [kDebugMode]).
///
/// **Logging strategy:** Use [log] for normal flow (state transitions, key
/// actions). Use [logError] for failures and exceptions. For auth we log
/// everything (login started, result, session restored/invalid, signOut) so
/// the flow is easy to trace in debug; to reduce noise elsewhere, log only
/// errors or a few key actions per feature.
abstract final class AppDebug {
  /// When false, [log] and [logError] are no-ops. Defaults to [kDebugMode].
  /// Override in tests to silence logs (e.g. `AppDebug.enabled = false`).
  static bool enabled = kDebugMode;

  /// Logs a message with a tag when [enabled]. Use for app-level debug
  /// (auth flow, state transitions, etc.), not for serverpod_cloud_cli
  /// output (that uses [AppLogger]).
  static void log(String tag, String message) {
    if (enabled) {
      debugPrint('[$tag] $message');
    }
  }

  /// Logs an error message with a tag when [enabled]. Use for failures
  /// and exceptions so they can be formatted or filtered differently later.
  static void logError(String tag, String message) {
    if (enabled) {
      debugPrint('[$tag] ERROR: $message');
    }
  }
}
