import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/di/injection.dart';
import 'package:scloud_desktop/features/projects/project_list_cubit.dart';
import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'status_state.dart';

/// Cubit for status screen: loads status for current project.
class StatusCubit extends Cubit<StatusState> {
  StatusCubit(this._repository, {ProjectListCubit? projectListCubit})
    : _projectListCubit = projectListCubit ?? getIt<ProjectListCubit>(),
      super(const StatusNoCurrentProject());

  final ProjectRepository _repository;
  final ProjectListCubit _projectListCubit;

  /// Redeploys the current project.
  Future<bool> redeploy() async {
    final current = _projectListCubit.currentProject;
    if (current == null) return false;

    try {
      await _repository.redeployCapsule(current.id);
      await loadStatus();
      return true;
    } catch (e) {
      AppDebug.logError('StatusCubit', 'redeploy error: $e');
      return false;
    }
  }

  /// Loads status for the current project from [ProjectListCubit].
  Future<void> loadStatus() async {
    final current = _projectListCubit.currentProject;

    if (current == null) {
      emit(const StatusNoCurrentProject());
      return;
    }

    emit(const StatusLoading());
    AppDebug.log('StatusCubit', 'loadStatus for ${current.id}');
    try {
      final details = await _repository.fetchProjectDetails(current.id);
      emit(
        StatusLoaded(
          projectId: current.id,
          status: details.status,
          deployAttempts: details.deployAttempts,
        ),
      );
    } catch (e) {
      AppDebug.logError('StatusCubit', 'loadStatus error: $e');
      emit(StatusError(e.toString()));
    }
  }
}
