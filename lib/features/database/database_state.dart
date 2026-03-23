import 'package:ground_control_client/ground_control_client.dart';

sealed class DatabaseState {
  const DatabaseState();
}

final class DatabaseLoading extends DatabaseState {
  const DatabaseLoading();
}

final class DatabaseLoaded extends DatabaseState {
  const DatabaseLoaded({required this.projectId, required this.connection});

  final String projectId;
  final DatabaseConnection connection;
}

final class DatabaseError extends DatabaseState {
  const DatabaseError(this.message);

  final String message;
}

final class DatabaseOperationInProgress extends DatabaseState {
  const DatabaseOperationInProgress({required this.projectId});

  final String projectId;
}
