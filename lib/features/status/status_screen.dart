import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:scloud_desktop/features/projects/project_status.dart';
import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'status_cubit.dart';
import 'status_state.dart';

/// Project details screen: status summary + deploy history for current project.
class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key, required this.cubit});

  final StatusCubit cubit;

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  void initState() {
    super.initState();
    widget.cubit.loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectDetailsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          BlocSelector<StatusCubit, StatusState, String?>(
            bloc: cubit,
            selector: (state) {
              if (state is StatusLoaded) return state.projectId;
              return null;
            },
            builder: (context, projectId) {
              if (projectId == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.terminal),
                tooltip: l10n.containerLogsTitle,
                onPressed: () => context.push(
                  AppRoutes.containerLogs,
                  extra: {'projectId': projectId},
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StatusCubit, StatusState>(
        bloc: cubit,
        buildWhen: (prev, next) => true,
        builder: (context, state) {
          return switch (state) {
            StatusNoCurrentProject() => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.noProjectSelected,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.chooseProjectToViewStatus,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text(l10n.goToProjectList),
                    ),
                  ],
                ),
              ),
            ),
            StatusLoading() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.projectDetailsTitle),
                ],
              ),
            ),
            StatusError() => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.statusErrorRetry,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => cubit.loadStatus(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            StatusLoaded(
              :final projectId,
              :final status,
              :final deployAttempts,
            ) =>
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusRow(
                      label: l10n.deploymentState,
                      value: status.deploymentState,
                    ),
                    if (status.lastDeployTime != null)
                      _StatusRow(
                        label: l10n.lastDeployTime,
                        value: status.lastDeployTime!,
                      ),
                    if (status.environment != null)
                      _StatusRow(
                        label: l10n.environment,
                        value: status.environment!,
                      ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.deployHistory,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (deployAttempts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          l10n.noDeploysYet,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      _DeployList(
                        projectId: projectId,
                        deployAttempts: deployAttempts,
                        l10n: l10n,
                      ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _DeployList extends StatelessWidget {
  const _DeployList({
    required this.projectId,
    required this.deployAttempts,
    required this.l10n,
  });

  final String projectId;
  final List<DeployAttemptInfo> deployAttempts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          children: [
            _tableHeader(context, l10n.deployId),
            _tableHeader(context, l10n.deploymentState),
            _tableHeader(context, l10n.started),
            _tableHeader(context, l10n.finished),
          ],
        ),
        for (final attempt in deployAttempts)
          TableRow(
            children: [
              _deployCell(context, attempt.id),
              _tableCell(context, attempt.status),
              _tableCell(context, attempt.startedAt ?? '—'),
              _tableCell(context, attempt.endedAt ?? '—'),
            ],
          ),
      ],
    );
  }

  Widget _deployCell(BuildContext context, String attemptId) {
    return InkWell(
      onTap: () => context.push(
        AppRoutes.deployLog,
        extra: {'projectId': projectId, 'attemptId': attemptId},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                attemptId,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }

  Widget _tableCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
