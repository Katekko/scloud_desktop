import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'database_state.dart';

class DatabaseCubit extends Cubit<DatabaseState> {
  DatabaseCubit(this._repository) : super(const DatabaseLoading());

  final ProjectRepository _repository;
  String? _projectId;

  Future<void> load(String projectId) async {
    _projectId = projectId;
    emit(const DatabaseLoading());
    try {
      final conn = await _repository.getDatabaseConnection(projectId);
      emit(DatabaseLoaded(projectId: projectId, connection: conn));
    } catch (e) {
      AppDebug.logError('DatabaseCubit', 'load error: $e');
      emit(DatabaseError(e.toString()));
    }
  }

  /// Creates a super user and returns the generated password.
  Future<String?> createSuperUser(String username) async {
    final projectId = _projectId;
    if (projectId == null) return null;

    emit(DatabaseOperationInProgress(projectId: projectId));
    try {
      final password = await _repository.createDatabaseSuperUser(
        projectId,
        username,
      );
      await load(projectId);
      return password;
    } catch (e) {
      AppDebug.logError('DatabaseCubit', 'createSuperUser error: $e');
      emit(DatabaseError(e.toString()));
      return null;
    }
  }

  /// Resets a user password and returns the new password.
  Future<String?> resetPassword(String username) async {
    final projectId = _projectId;
    if (projectId == null) return null;

    emit(DatabaseOperationInProgress(projectId: projectId));
    try {
      final password = await _repository.resetDatabasePassword(
        projectId,
        username,
      );
      await load(projectId);
      return password;
    } catch (e) {
      AppDebug.logError('DatabaseCubit', 'resetPassword error: $e');
      emit(DatabaseError(e.toString()));
      return null;
    }
  }
}
