import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/shared/debug_log.dart';

import 'auth_repository.dart';
import 'auth_state.dart';

/// Cubit for auth state: login, restore session, sign out.
/// Emits [AuthState]; uses [AuthRepository] for serverpod_cloud_cli.
///
/// Logging: we log state transitions (one per emit) so auth flow is easy to
/// trace in debug. To reduce noise, log only errors or key actions elsewhere.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const Unauthenticated());

  final AuthRepository _repository;

  /// Starts login flow; emits [LoginInProgress] then result.
  Future<void> login() async {
    emit(const LoginInProgress());
    AppDebug.log('AuthCubit', 'auth_state: LoginInProgress');
    final result = await _repository.login();
    AppDebug.log('AuthCubit', 'auth_state: ${result.runtimeType}');
    emit(result);
  }

  /// Restores session from CLI storage; emits result.
  Future<void> restoreSession() async {
    final result = await _repository.restoreSession();
    AppDebug.log('AuthCubit', 'auth_state: ${result.runtimeType}');
    emit(result);
  }

  /// Signs out; clears session and emits [Unauthenticated].
  Future<void> signOut() async {
    await _repository.signOut();
    AppDebug.log('AuthCubit', 'auth_state: Unauthenticated');
    emit(const Unauthenticated());
  }
}
