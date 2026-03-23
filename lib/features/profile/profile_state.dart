import 'package:ground_control_client/ground_control_client.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.user});

  final User user;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}
