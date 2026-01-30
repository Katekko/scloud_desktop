import 'package:cli_tools/logger.dart' as cli;

import 'debug_log.dart';

/// Logger that forwards to [AppDebug] for app debugging (no stdout).
/// Used by serverpod_cloud_cli CommandLogger so CLI flows log to the app
/// instead of stdout.
class AppLogger extends cli.Logger {
  AppLogger() : super(cli.LogLevel.debug);

  @override
  int? get wrapTextColumn => 80;

  @override
  void debug(
    String message, {
    bool newParagraph = false,
    cli.LogType type = const cli.RawLogType(),
  }) {
    AppDebug.log('scloud', message);
  }

  @override
  void info(
    String message, {
    bool newParagraph = false,
    cli.LogType type = const cli.RawLogType(),
  }) {
    AppDebug.log('scloud', message);
  }

  @override
  void warning(
    String message, {
    bool newParagraph = false,
    cli.LogType type = const cli.RawLogType(),
  }) {}

  @override
  void error(
    String message, {
    bool newParagraph = false,
    StackTrace? stackTrace,
    cli.LogType type = const cli.RawLogType(),
  }) {
    AppDebug.logError('scloud', message);
  }

  @override
  void log(
    String message,
    cli.LogLevel level, {
    bool newParagraph = false,
    cli.LogType type = const cli.RawLogType(),
  }) {
    AppDebug.log('scloud', message);
  }

  @override
  Future<void> flush() => Future.value();

  @override
  Future<bool> progress(
    String message,
    Future<bool> Function() runner, {
    bool newParagraph = true,
  }) async {
    return runner();
  }

  @override
  void write(
    String message,
    cli.LogLevel logLevel, {
    bool newParagraph = false,
    bool newLine = true,
  }) {}
}
