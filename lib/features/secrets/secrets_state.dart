/// State for the secrets screen.
sealed class SecretsState {
  const SecretsState();
}

final class SecretsLoading extends SecretsState {
  const SecretsLoading();
}

final class SecretsLoaded extends SecretsState {
  const SecretsLoaded({required this.projectId, required this.keys});

  final String projectId;

  /// Secret keys only — values are not readable.
  final List<String> keys;
}

final class SecretsError extends SecretsState {
  const SecretsError(this.message);

  final String message;
}

final class SecretsOperationInProgress extends SecretsState {
  const SecretsOperationInProgress({
    required this.projectId,
    required this.keys,
  });

  final String projectId;
  final List<String> keys;
}
