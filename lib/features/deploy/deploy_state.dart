/// State for the deploy feature (directory linking + deployment).
sealed class DeployState {
  const DeployState();
}

/// No directory configured for the current project.
final class DeployDirectoryNotConfigured extends DeployState {
  const DeployDirectoryNotConfigured();
}

/// Directory is configured and ready for deploy.
final class DeployDirectoryConfigured extends DeployState {
  const DeployDirectoryConfigured(this.directoryPath);

  final String directoryPath;
}

/// Deploy is in progress.
final class DeployInProgress extends DeployState {
  const DeployInProgress(this.directoryPath);

  final String directoryPath;
}

/// Deploy failed.
final class DeployError extends DeployState {
  const DeployError({required this.directoryPath, required this.message});

  final String directoryPath;
  final String message;
}
