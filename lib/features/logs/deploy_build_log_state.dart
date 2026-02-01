import 'package:ground_control_client/ground_control_client.dart';

/// State for the deploy build log screen.
sealed class DeployBuildLogState {
  const DeployBuildLogState();
}

/// Loading build log.
final class DeployBuildLogLoading extends DeployBuildLogState {
  const DeployBuildLogLoading();
}

/// Build log loaded (historical records).
final class DeployBuildLogLoaded extends DeployBuildLogState {
  const DeployBuildLogLoaded(this.records);

  final List<LogRecord> records;
}

/// Error while loading.
final class DeployBuildLogError extends DeployBuildLogState {
  const DeployBuildLogError(this.message);

  final String message;
}
