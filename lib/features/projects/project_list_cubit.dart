import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_control_client/ground_control_client.dart' hide Project;

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

  /// Creates a new project and reloads the list.
  /// Returns null on success, or the error message on failure.
  Future<String?> createProject(String projectId) async {
    try {
      await _repository.createProject(projectId);
      await loadProjects();
      return null;
    } catch (e) {
      AppDebug.logError('ProjectListCubit', 'createProject error: $e');
      return _extractErrorMessage(e);
    }
  }

  String _extractErrorMessage(Object e) {
    return switch (e) {
      InvalidValueException(:final message) => message,
      DuplicateEntryException(:final message) => message,
      NotFoundException(:final message) => message,
      UnauthorizedException(:final message) => message,
      NoSubscriptionException(:final message) => message,
      ProcurementDeniedException(:final message) => message,
      _ => e.toString(),
    };
  }

  /// Deletes a project and reloads the list.
  Future<bool> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);
      if (currentProject?.id == projectId) {
        currentProject = null;
      }
      await loadProjects();
      return true;
    } catch (e) {
      AppDebug.logError('ProjectListCubit', 'deleteProject error: $e');
      return false;
    }
  }
}
