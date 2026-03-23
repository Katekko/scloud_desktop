import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'secrets_state.dart';

class SecretsCubit extends Cubit<SecretsState> {
  SecretsCubit(this._repository) : super(const SecretsLoading());

  final ProjectRepository _repository;
  String? _projectId;

  Future<void> load(String projectId) async {
    _projectId = projectId;
    emit(const SecretsLoading());
    try {
      final keys = await _repository.listSecrets(projectId);
      emit(SecretsLoaded(projectId: projectId, keys: keys));
    } catch (e) {
      AppDebug.logError('SecretsCubit', 'load error: $e');
      emit(SecretsError(e.toString()));
    }
  }

  Future<void> upsert(String key, String value) async {
    final projectId = _projectId;
    if (projectId == null) return;

    final current = state;
    final currentKeys = current is SecretsLoaded ? current.keys : <String>[];
    emit(SecretsOperationInProgress(projectId: projectId, keys: currentKeys));

    try {
      await _repository.upsertSecret(projectId, key, value);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('SecretsCubit', 'upsert error: $e');
      emit(SecretsError(e.toString()));
    }
  }

  Future<void> delete(String key) async {
    final projectId = _projectId;
    if (projectId == null) return;

    final current = state;
    final currentKeys = current is SecretsLoaded ? current.keys : <String>[];
    emit(SecretsOperationInProgress(projectId: projectId, keys: currentKeys));

    try {
      await _repository.deleteSecret(projectId, key);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('SecretsCubit', 'delete error: $e');
      emit(SecretsError(e.toString()));
    }
  }
}
