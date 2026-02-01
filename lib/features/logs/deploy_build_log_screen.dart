import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:scloud_desktop/l10n/app_localizations.dart';

import 'deploy_build_log_cubit.dart';
import 'deploy_build_log_state.dart';

/// Screen showing historical build log for a deploy attempt.
class DeployBuildLogScreen extends StatelessWidget {
  const DeployBuildLogScreen({
    super.key,
    required this.projectId,
    required this.attemptId,
  });

  final String projectId;
  final String attemptId;

  /// Extracts route args from [GoRouterState.extra].
  static ({String projectId, String attemptId})? argsFromExtra(dynamic extra) {
    if (extra is! Map<String, dynamic>) return null;
    final projectId = extra['projectId'] as String?;
    final attemptId = extra['attemptId'] as String?;
    if (projectId == null ||
        projectId.isEmpty ||
        attemptId == null ||
        attemptId.isEmpty) {
      return null;
    }
    return (projectId: projectId, attemptId: attemptId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.buildLogTitle(attemptId)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<DeployBuildLogCubit, DeployBuildLogState>(
        builder: (context, state) {
          final cubit = context.read<DeployBuildLogCubit>();
          return switch (state) {
            DeployBuildLogLoading() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.loadingLogs),
                  ],
                ),
              ),
            DeployBuildLogError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => cubit.retry(projectId, attemptId),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            DeployBuildLogLoaded(:final records) => records.isEmpty
                ? Center(child: Text(l10n.noLogs))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final r = records[index];
                      return _LogRow(record: r);
                    },
                  ),
          };
        },
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.record});

  final LogRecord record;

  static String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              _formatTimestamp(record.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              record.severity ?? '—',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              record.content,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
