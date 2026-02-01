/// Status of a project shown on the project details screen.
///
/// Maps from serverpod_cloud_cli / Cloud API (DeployAttempt, etc.).
class ProjectStatus {
  const ProjectStatus({
    required this.deploymentState,
    this.lastDeployTime,
    this.environment,
  });

  /// Deployment state, e.g. Live, Deploying, Failed.
  final String deploymentState;

  /// Last deploy timestamp or formatted string.
  final String? lastDeployTime;

  /// Environment if CLI exposes it; otherwise null.
  final String? environment;
}

/// A deploy attempt for display in the project details deploy history.
class DeployAttemptInfo {
  const DeployAttemptInfo({
    required this.id,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.statusInfo,
  });

  final String id;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final String? statusInfo;
}
