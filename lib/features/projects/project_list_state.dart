import 'project.dart';

/// State for the project list screen.
sealed class ProjectListState {
  const ProjectListState();
}

/// Fetching project list from Cloud.
final class ProjectListLoading extends ProjectListState {
  const ProjectListLoading();
}

/// List of projects available.
final class ProjectListLoaded extends ProjectListState {
  const ProjectListLoaded(this.projects);

  final List<Project> projects;
}

/// No projects for account.
final class ProjectListEmpty extends ProjectListState {
  const ProjectListEmpty();
}

/// Network or API error.
final class ProjectListError extends ProjectListState {
  const ProjectListError(this.message);

  final String message;
}
