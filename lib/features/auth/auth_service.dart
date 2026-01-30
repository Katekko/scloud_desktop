import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/commands/auth/auth_login.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:cli_tools/logger.dart' as cli;

import 'auth_state.dart';

/// Auth service using serverpod_cloud_cli: same storage as scloud CLI,
/// login flow, sign-out, session validation. Exposes auth state stream.
class AuthService {
  AuthService() {
    _logger = CommandLogger(_createAppLogger());
    _globalConfig = GlobalConfiguration.resolve(args: [], env: {});
    _logger.configuration = _globalConfig;
  }

  late final CommandLogger _logger;
  late final GlobalConfiguration _globalConfig;
  final _authStateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = const Unauthenticated();

  /// Current auth state.
  AuthState get authState => _currentState;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateStream => _authStateController.stream;

  void _setState(AuthState state) {
    if (_currentState == state) return;
    if (kDebugMode) {
      debugPrint(
        '[AuthService] auth_state: ${_currentState.runtimeType} -> ${state.runtimeType}',
      );
    }
    _currentState = state;
    _authStateController.add(state);
  }

  /// Starts login flow: open browser, wait for callback, store session.
  /// Sets login_in_progress then authenticated(identity) or error(message).
  Future<void> login() async {
    _setState(const LoginInProgress());
    if (kDebugMode) {
      debugPrint('[AuthService] login started');
    }
    try {
      final stored = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: _globalConfig.scloudDir.path,
        logger: _logger,
      );
      if (stored != null) {
        _setState(const AuthError('signInNotCompleted'));
        if (kDebugMode) {
          debugPrint('[AuthService] existing session; log out first');
        }
        return;
      }
      await AuthLoginCommands.login(
        logger: _logger,
        globalConfig: _globalConfig,
        timeLimit: const Duration(seconds: 300),
        persistent: true,
        openBrowser: true,
      );
      if (kDebugMode) debugPrint('[AuthService] login callback success');
      await _restoreSession();
    } on FailureException catch (e) {
      if (kDebugMode) debugPrint('[AuthService] login failed: ${e.reason}');
      _setState(AuthError(e.reason ?? 'signInNotCompleted'));
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] login error: $e');
      _setState(const AuthError('networkError'));
    }
  }

  /// Restores session from CLI storage; sets authenticated(identity) or error.
  Future<void> restoreSession() async {
    await _restoreSession();
  }

  Future<void> _restoreSession() async {
    final authData = await ResourceManager.tryFetchServerpodCloudAuthData(
      localStoragePath: _globalConfig.scloudDir.path,
      logger: _logger,
    );
    if (authData == null) {
      _setState(const Unauthenticated());
      return;
    }
    try {
      final provider = CloudCliServiceProvider();
      provider.initialize(globalConfiguration: _globalConfig, logger: _logger);
      final client = provider.cloudApiClient;
      final user = await client.users.readUser();
      provider.shutdown();
      _setState(Authenticated(user.email));
      if (kDebugMode) {
        debugPrint('[AuthService] session restored: ${user.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] session invalid or expired: $e');
      }
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: _globalConfig.scloudDir.path,
      );
      _setState(const AuthError('sessionExpired'));
    }
  }

  /// Signs out: clear session in CLI storage, set unauthenticated.
  Future<void> signOut() async {
    if (kDebugMode) debugPrint('[AuthService] signOut');
    try {
      final provider = CloudCliServiceProvider();
      provider.initialize(globalConfiguration: _globalConfig, logger: _logger);
      try {
        await provider.cloudApiClient.auth.logoutDevice();
      } catch (_) {}
      provider.shutdown();
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: _globalConfig.scloudDir.path,
      );
    } catch (_) {}
    _setState(const Unauthenticated());
  }

  cli.Logger _createAppLogger() {
    return _AppLogger();
  }

  void dispose() {
    _authStateController.close();
  }
}

/// Logger that forwards to debugPrint for app debugging (no stdout).
class _AppLogger extends cli.Logger {
  _AppLogger() : super(cli.LogLevel.debug);

  @override
  int? get wrapTextColumn => 80;

  @override
  void debug(
    String message, {
    bool newParagraph = false,
    cli.LogType type = const cli.RawLogType(),
  }) {
    if (kDebugMode) debugPrint('[scloud] $message');
  }

  @override
  void info(
    String message, {
    bool newParagraph = false,
    cli.LogType type = const cli.RawLogType(),
  }) {
    if (kDebugMode) debugPrint('[scloud] $message');
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
    if (kDebugMode) debugPrint('[scloud] ERROR: $message');
  }

  @override
  void log(
    String message,
    cli.LogLevel level, {
    bool newParagraph = false,
    cli.LogType type = const cli.RawLogType(),
  }) {
    if (kDebugMode) debugPrint('[scloud] $message');
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
