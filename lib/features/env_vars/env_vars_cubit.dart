import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'env_vars_state.dart';

/// Cubit for managing environment variables for a project.
class EnvVarsCubit extends Cubit<EnvVarsState> {
  EnvVarsCubit(this._repository) : super(const EnvVarsLoading());

  final ProjectRepository _repository;

  String? _projectId;

  /// Loads all environment variables for [projectId].
  Future<void> load(String projectId) async {
    _projectId = projectId;
    emit(const EnvVarsLoading());
    try {
      final vars = await _repository.listEnvVars(projectId);
      emit(EnvVarsLoaded(projectId: projectId, variables: vars));
    } catch (e) {
      AppDebug.logError('EnvVarsCubit', 'load error: $e');
      emit(EnvVarsError(e.toString()));
    }
  }

  /// Creates a new environment variable.
  Future<void> create(String name, String value) async {
    final projectId = _projectId;
    if (projectId == null) return;

    final current = state;
    final currentVars = current is EnvVarsLoaded
        ? current.variables
        : <EnvironmentVariable>[];
    emit(
      EnvVarsOperationInProgress(projectId: projectId, variables: currentVars),
    );

    try {
      await _repository.createEnvVar(projectId, name, value);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('EnvVarsCubit', 'create error: $e');
      emit(EnvVarsError(e.toString()));
    }
  }

  /// Updates an existing environment variable.
  Future<void> update(String name, String value) async {
    final projectId = _projectId;
    if (projectId == null) return;

    final current = state;
    final currentVars = current is EnvVarsLoaded
        ? current.variables
        : <EnvironmentVariable>[];
    emit(
      EnvVarsOperationInProgress(projectId: projectId, variables: currentVars),
    );

    try {
      await _repository.updateEnvVar(projectId, name, value);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('EnvVarsCubit', 'update error: $e');
      emit(EnvVarsError(e.toString()));
    }
  }

  /// Deletes an environment variable.
  Future<void> delete(String name) async {
    final projectId = _projectId;
    if (projectId == null) return;

    final current = state;
    final currentVars = current is EnvVarsLoaded
        ? current.variables
        : <EnvironmentVariable>[];
    emit(
      EnvVarsOperationInProgress(projectId: projectId, variables: currentVars),
    );

    try {
      await _repository.deleteEnvVar(projectId, name);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('EnvVarsCubit', 'delete error: $e');
      emit(EnvVarsError(e.toString()));
    }
  }
}
