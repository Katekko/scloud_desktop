import 'package:ground_control_client/ground_control_client.dart';

sealed class UsersState {
  const UsersState();
}

final class UsersLoading extends UsersState {
  const UsersLoading();
}

final class UsersLoaded extends UsersState {
  const UsersLoaded({
    required this.projectId,
    required this.users,
    required this.roles,
  });

  final String projectId;
  final List<User> users;
  final List<Role> roles;
}

final class UsersError extends UsersState {
  const UsersError(this.message);

  final String message;
}

final class UsersOperationInProgress extends UsersState {
  const UsersOperationInProgress({required this.projectId});

  final String projectId;
}
