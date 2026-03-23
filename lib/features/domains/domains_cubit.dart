import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'domains_state.dart';

class DomainsCubit extends Cubit<DomainsState> {
  DomainsCubit(this._repository) : super(const DomainsLoading());

  final ProjectRepository _repository;
  String? _projectId;

  Future<void> load(String projectId) async {
    _projectId = projectId;
    emit(const DomainsLoading());
    try {
      final list = await _repository.listDomains(projectId);
      emit(DomainsLoaded(projectId: projectId, domainList: list));
    } catch (e) {
      AppDebug.logError('DomainsCubit', 'load error: $e');
      emit(DomainsError(e.toString()));
    }
  }

  Future<void> add(String domainName, DomainNameTarget target) async {
    final projectId = _projectId;
    if (projectId == null) return;

    final current = state;
    if (current is DomainsLoaded) {
      emit(
        DomainsOperationInProgress(
          projectId: projectId,
          domainList: current.domainList,
        ),
      );
    }

    try {
      await _repository.addDomain(projectId, domainName, target);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('DomainsCubit', 'add error: $e');
      emit(DomainsError(e.toString()));
    }
  }

  Future<void> remove(String domainName) async {
    final projectId = _projectId;
    if (projectId == null) return;

    final current = state;
    if (current is DomainsLoaded) {
      emit(
        DomainsOperationInProgress(
          projectId: projectId,
          domainList: current.domainList,
        ),
      );
    }

    try {
      await _repository.removeDomain(projectId, domainName);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('DomainsCubit', 'remove error: $e');
      emit(DomainsError(e.toString()));
    }
  }

  Future<void> refreshDns(String domainName) async {
    final projectId = _projectId;
    if (projectId == null) return;

    try {
      await _repository.refreshDomain(projectId, domainName);
      await load(projectId);
    } catch (e) {
      AppDebug.logError('DomainsCubit', 'refreshDns error: $e');
      emit(DomainsError(e.toString()));
    }
  }
}
