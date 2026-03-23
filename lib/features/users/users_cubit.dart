import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._repository) : super(const UsersLoading());

  final ProjectRepository _repository;
  String? _projectId;

  Future<void> load(String projectId) async {
    _projectId = projectId;
    emit(const UsersLoading());
    try {
      final results = await Future.wait([
        _repository.listProjectUsers(projectId),
        _repository.fetchProjectRoles(projectId),
      ]);
      emit(
        UsersLoaded(
          projectId: projectId,
          users: results[0] as dynamic,
          roles: results[1] as dynamic,
        ),
      );
    } catch (e) {
      AppDebug.logError('UsersCubit', 'load error: $e');
      emit(UsersError(e.toString()));
    }
  }

  Future<void> invite(String email, List<String> roleNames) async {
    final projectId = _projectId;
    if (projectId == null) return;

    emit(UsersOperationInProgress(projectId: projectId));
    try {
      await _repository.inviteUser(projectId, email, roleNames);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('UsersCubit', 'invite error: $e');
      emit(UsersError(e.toString()));
    }
  }

  Future<void> revoke(String email) async {
    final projectId = _projectId;
    if (projectId == null) return;

    emit(UsersOperationInProgress(projectId: projectId));
    try {
      await _repository.revokeUser(projectId, email);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('UsersCubit', 'revoke error: $e');
      emit(UsersError(e.toString()));
    }
  }
}
