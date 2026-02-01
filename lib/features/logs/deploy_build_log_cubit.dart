import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'deploy_build_log_state.dart';

/// Cubit for the deploy build log screen: fetches historical build log.
class DeployBuildLogCubit extends Cubit<DeployBuildLogState> {
  DeployBuildLogCubit(this._repository) : super(const DeployBuildLogLoading());

  final ProjectRepository _repository;

  /// Loads build log for [projectId] and [attemptId].
  Future<void> load(String projectId, String attemptId) async {
    emit(const DeployBuildLogLoading());
    try {
      final records = await _repository.fetchBuildLog(projectId, attemptId);
      emit(DeployBuildLogLoaded(records));
    } catch (e) {
      AppDebug.logError('DeployBuildLogCubit', 'load error: $e');
      emit(DeployBuildLogError(e.toString()));
    }
  }

  /// Retries loading with the last [projectId] and [attemptId].
  /// No-op if we don't have them stored; caller should pass them again.
  Future<void> retry(String projectId, String attemptId) async {
    await load(projectId, attemptId);
  }
}
