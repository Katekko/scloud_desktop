import '../projects/project_status.dart';

/// State for the project details screen.
sealed class StatusState {
  const StatusState();
}

/// No current project selected.
final class StatusNoCurrentProject extends StatusState {
  const StatusNoCurrentProject();
}

/// Fetching project details.
final class StatusLoading extends StatusState {
  const StatusLoading();
}

/// Project details (status + deploy history) available.
final class StatusLoaded extends StatusState {
  const StatusLoaded({
    required this.status,
    required this.deployAttempts,
  });

  final ProjectStatus status;
  final List<DeployAttemptInfo> deployAttempts;
}

/// Network or API error.
final class StatusError extends StatusState {
  const StatusError(this.message);

  final String message;
}
