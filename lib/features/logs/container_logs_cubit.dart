import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/shared/debug_log.dart';

import 'container_logs_state.dart';

/// Cubit for the container logs screen: tails log records and appends to list.
class ContainerLogsCubit extends Cubit<ContainerLogsState> {
  ContainerLogsCubit(this._repository) : super(const ContainerLogsLoading());

  final ProjectRepository _repository;
  StreamSubscription<LogRecord>? _subscription;

  /// Starts tailing container logs for [projectId].
  void startTailing(String projectId) {
    if (_subscription != null) return;
    final stream = _repository.streamContainerLogs(projectId, limit: 500);
    final records = <LogRecord>[];
    _subscription = stream.listen(
      (record) {
        records.add(record);
        emit(ContainerLogsStreaming(List.from(records)));
      },
      onError: (e, st) {
        AppDebug.logError('ContainerLogsCubit', 'stream error: $e');
        emit(ContainerLogsError(e.toString()));
      },
    );
    // Show streaming UI immediately so we don't stay in loading if the stream
    // doesn't emit until new log lines arrive (e.g. idle container).
    emit(const ContainerLogsStreaming([]));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
