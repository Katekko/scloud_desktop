import 'package:ground_control_client/ground_control_client.dart';

/// State for the environment variables screen.
sealed class EnvVarsState {
  const EnvVarsState();
}

/// Loading env vars list.
final class EnvVarsLoading extends EnvVarsState {
  const EnvVarsLoading();
}

/// Env vars loaded successfully.
final class EnvVarsLoaded extends EnvVarsState {
  const EnvVarsLoaded({required this.projectId, required this.variables});

  final String projectId;
  final List<EnvironmentVariable> variables;
}

/// Error loading env vars.
final class EnvVarsError extends EnvVarsState {
  const EnvVarsError(this.message);

  final String message;
}

/// An env var operation (create/update/delete) is in progress.
final class EnvVarsOperationInProgress extends EnvVarsState {
  const EnvVarsOperationInProgress({
    required this.projectId,
    required this.variables,
  });

  final String projectId;
  final List<EnvironmentVariable> variables;
}
