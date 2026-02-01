import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';

import 'container_logs_cubit.dart';
import 'container_logs_state.dart';

/// Screen showing real-time container logs for a project.
class ContainerLogsScreen extends StatefulWidget {
  const ContainerLogsScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  /// Extracts route args from [GoRouterState.extra].
  static String? projectIdFromExtra(dynamic extra) {
    if (extra is! Map<String, dynamic>) return null;
    final projectId = extra['projectId'] as String?;
    if (projectId == null || projectId.isEmpty) return null;
    return projectId;
  }

  @override
  State<ContainerLogsScreen> createState() => _ContainerLogsScreenState();
}

class _ContainerLogsScreenState extends State<ContainerLogsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Text(l10n.containerLogsTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<ContainerLogsCubit, ContainerLogsState>(
          listenWhen: (prev, next) =>
              next is ContainerLogsStreaming && prev is ContainerLogsStreaming,
          listener: (context, state) {
            if (state is ContainerLogsStreaming && _autoScroll) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
          },
          builder: (context, state) {
            return switch (state) {
              ContainerLogsLoading() => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.tailingLogs),
                    ],
                  ),
                ),
              ContainerLogsError(:final message) => Center(
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
                      ],
                    ),
                  ),
                ),
              ContainerLogsStreaming(:final records) => Column(
                  children: [
                    if (records.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${records.length} records',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            CheckboxListTile(
                              value: _autoScroll,
                              onChanged: (v) {
                                setState(() => _autoScroll = v ?? true);
                              },
                              title: Text(
                                'Auto-scroll',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: records.isEmpty
                          ? Center(child: Text(l10n.tailingLogs))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                final r = records[index];
                                return _LogRow(record: r);
                              },
                            ),
                    ),
                  ],
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
