import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/shared/debug_log.dart';

import 'project.dart';
import 'project_list_state.dart';
import 'project_repository.dart';

/// Cubit for project list and current project selection.
///
/// Loads projects, manages current project (session-only), and provides
/// load/retry/select/clear actions.
class ProjectListCubit extends Cubit<ProjectListState> {
  ProjectListCubit(this._repository) : super(const ProjectListLoading()) {
    loadProjects();
  }

  final ProjectRepository _repository;

  /// Current project selected by user (session-only, not persisted).
  Project? currentProject;

  /// Fetches project list from Cloud.
  Future<void> loadProjects() async {
    emit(const ProjectListLoading());
    AppDebug.log('ProjectListCubit', 'loadProjects started');
    try {
      final projects = await _repository.fetchProjectList();
      if (projects.isEmpty) {
        AppDebug.log('ProjectListCubit', 'loadProjects empty');
        emit(const ProjectListEmpty());
      } else {
        AppDebug.log(
          'ProjectListCubit',
          'loadProjects loaded ${projects.length}',
        );
        emit(ProjectListLoaded(projects));
      }
    } catch (e) {
      AppDebug.logError('ProjectListCubit', 'loadProjects error: $e');
      emit(ProjectListError(e.toString()));
    }
  }

  /// Sets the current project for the session.
  void selectProject(Project project) {
    currentProject = project;
    AppDebug.log('ProjectListCubit', 'selectProject ${project.id}');
  }

  /// Clears the current project (e.g. on sign out).
  void clearCurrentProject() {
    currentProject = null;
    AppDebug.log('ProjectListCubit', 'clearCurrentProject');
  }
}
