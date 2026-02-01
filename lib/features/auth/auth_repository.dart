import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/commands/auth/auth_login.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import 'package:scloud_desktop/shared/app_logger.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'auth_state.dart';

/// Repository for auth: serverpod_cloud_cli login, restore, sign-out.
/// Same storage as scloud CLI. Returns auth state outcomes; no stream.
///
/// Logging: we log key actions and errors (login started, callback success,
/// failures, session restored/invalid, signOut) so auth flow is traceable.
class AuthRepository {
  AuthRepository() {
    _logger = CommandLogger(AppLogger());
    _globalConfig = GlobalConfiguration.resolve(args: [], env: {});
    _logger.configuration = _globalConfig;
  }

  late final CommandLogger _logger;
  late final GlobalConfiguration _globalConfig;

  /// Runs login flow; returns resulting [AuthState].
  Future<AuthState> login() async {
    AppDebug.log('AuthRepository', 'login started');
    try {
      final stored = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: _globalConfig.scloudDir.path,
        logger: _logger,
      );
      if (stored != null) {
        AppDebug.log('AuthRepository', 'existing session; log out first');
        return const AuthError('signInNotCompleted');
      }
      await AuthLoginCommands.login(
        logger: _logger,
        globalConfig: _globalConfig,
        timeLimit: const Duration(seconds: 300),
        persistent: true,
        openBrowser: true,
      );
      AppDebug.log('AuthRepository', 'login callback success');
      return restoreSession();
    } on FailureException catch (e) {
      AppDebug.logError('AuthRepository', 'login failed: ${e.reason}');
      return AuthError(e.reason ?? 'signInNotCompleted');
    } catch (e) {
      AppDebug.logError('AuthRepository', 'login error: $e');
      return const AuthError('networkError');
    }
  }

  /// Restores session from CLI storage; returns current [AuthState].
  Future<AuthState> restoreSession() async {
    final authData = await ResourceManager.tryFetchServerpodCloudAuthData(
      localStoragePath: _globalConfig.scloudDir.path,
      logger: _logger,
    );
    if (authData == null) {
      return const Unauthenticated();
    }
    try {
      final provider = CloudCliServiceProvider();
      provider.initialize(globalConfiguration: _globalConfig, logger: _logger);
      final client = provider.cloudApiClient;
      final user = await client.users.readUser();
      provider.shutdown();
      AppDebug.log('AuthRepository', 'session restored: ${user.email}');
      return Authenticated(user.email);
    } catch (e) {
      AppDebug.logError('AuthRepository', 'session invalid or expired: $e');
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: _globalConfig.scloudDir.path,
      );
      return const AuthError('sessionExpired');
    }
  }

  /// Clears session in CLI storage.
  Future<void> signOut() async {
    AppDebug.log('AuthRepository', 'signOut');
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
  }
}
