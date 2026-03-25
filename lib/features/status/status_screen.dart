import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:scloud_desktop/features/deploy/deploy_cubit.dart';
import 'package:scloud_desktop/features/deploy/deploy_state.dart';
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
    if (widget.cubit.state is! StatusLoaded) {
      widget.cubit.loadStatus();
    }
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
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.retry,
                    onPressed: () => cubit.loadStatus(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.terminal),
                    tooltip: l10n.containerLogsTitle,
                    onPressed: () => context.push(
                      AppRoutes.containerLogs,
                      extra: {'projectId': projectId},
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (route) =>
                        context.push(route, extra: {'projectId': projectId}),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: AppRoutes.envVars,
                        child: ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text(l10n.envVarsTitle),
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: AppRoutes.secrets,
                        child: ListTile(
                          leading: const Icon(Icons.key),
                          title: Text(l10n.secretsTitle),
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: AppRoutes.domains,
                        child: ListTile(
                          leading: const Icon(Icons.dns),
                          title: Text(l10n.domainsTitle),
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: AppRoutes.database,
                        child: ListTile(
                          leading: const Icon(Icons.storage),
                          title: Text(l10n.databaseTitle),
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: AppRoutes.users,
                        child: ListTile(
                          leading: const Icon(Icons.group),
                          title: Text(l10n.usersTitle),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
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
              :final defaultDomainsByTarget,
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
                    if (defaultDomainsByTarget.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.projectLinks,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final entry in defaultDomainsByTarget.entries)
                        _LinkRow(
                          label: _domainTargetLabel(entry.key),
                          url: entry.value,
                        ),
                    ],
                    const SizedBox(height: 24),
                    _DeploySection(projectId: projectId, l10n: l10n),
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

String _domainTargetLabel(DomainNameTarget target) {
  return switch (target) {
    DomainNameTarget.api => 'API',
    DomainNameTarget.web => 'Web',
    DomainNameTarget.insights => 'Insights',
  };
}

class _DeploySection extends StatelessWidget {
  const _DeploySection({required this.projectId, required this.l10n});

  final String projectId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<DeployCubit, DeployState>(
      listener: (context, state) {
        if (state is DeployError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.deployFailed}: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final deployCubit = context.read<DeployCubit>();
        return switch (state) {
          DeployDirectoryNotConfigured() => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_off,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.projectNotLinked,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.projectNotLinkedDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: Text(l10n.linkDirectory),
                    onPressed: () => _pickDirectory(context, deployCubit),
                  ),
                ],
              ),
            ),
          ),
          DeployDirectoryConfigured(:final directoryPath) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.linkedDirectory, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(directoryPath, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.rocket_launch),
                        label: Text(l10n.deploy),
                        onPressed: () => _deploy(context, deployCubit),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _pickDirectory(context, deployCubit),
                        child: Text(l10n.changeDirectory),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DeployInProgress(:final directoryPath) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.linkedDirectory, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(directoryPath, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.deploying),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DeployError(:final directoryPath) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.linkedDirectory, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(directoryPath, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.rocket_launch),
                        label: Text(l10n.deploy),
                        onPressed: () => _deploy(context, deployCubit),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _pickDirectory(context, deployCubit),
                        child: Text(l10n.changeDirectory),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        };
      },
    );
  }

  Future<void> _pickDirectory(
    BuildContext context,
    DeployCubit deployCubit,
  ) async {
    final error = await deployCubit.pickDirectory(projectId);
    if (error == 'invalidDirectory' && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidDirectory)));
    }
  }

  Future<void> _deploy(BuildContext context, DeployCubit deployCubit) async {
    final success = await deployCubit.deploy(projectId);
    if (context.mounted && success) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deployStarted)));
      // Refresh deploy history
      context.read<StatusCubit>().loadStatus();
    }
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Flexible(
            child: InkWell(
              onTap: () => launchUrl(Uri.parse('https://$url')),
              child: Text(
                url,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
