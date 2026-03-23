import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:scloud_desktop/di/injection.dart';
import 'package:scloud_desktop/features/auth/auth_cubit.dart';
import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'project_list_cubit.dart';
import 'project_list_state.dart';

/// Project list screen: shows linked/available projects with indicator,
/// loading/empty/error states. Tapping a project navigates to its status screen.
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({
    super.key,
    required this.cubit,
    required this.authCubit,
  });

  final ProjectListCubit cubit;
  final AuthCubit authCubit;

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = widget.cubit;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: l10n.billingTitle,
            onPressed: () => context.push(AppRoutes.billing),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.profileTitle,
            onPressed: () => context.push(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              getIt<ProjectListCubit>().clearCurrentProject();
              widget.authCubit.signOut();
            },
            tooltip: l10n.signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, cubit, l10n),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ProjectListCubit, ProjectListState>(
        bloc: cubit,
        builder: (context, state) {
          return switch (state) {
            ProjectListLoading() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.projectListLoading),
                ],
              ),
            ),
            ProjectListEmpty() => Center(
              child: Text(
                l10n.noProjectsYet,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ProjectListError() => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.projectListErrorRetry,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => cubit.loadProjects(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            ProjectListLoaded(:final projects) => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final isSelected = cubit.currentProject?.id == project.id;
                return ListTile(
                  leading: Icon(
                    project.isLinked ? Icons.link : Icons.folder_outlined,
                    color: project.isLinked
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(project.displayName),
                  subtitle: Text(
                    project.isLinked ? l10n.linked : l10n.available,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  selected: isSelected,
                  onTap: () {
                    cubit.selectProject(project);
                    context.push(AppRoutes.status);
                  },
                  onLongPress: () =>
                      _showDeleteDialog(context, cubit, project.id, l10n),
                );
              },
            ),
          };
        },
      ),
    );
  }

  void _showCreateDialog(
    BuildContext context,
    ProjectListCubit cubit,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createProject),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.projectId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final id = controller.text.trim();
              if (id.isEmpty) return;
              Navigator.pop(ctx);
              final error = await cubit.createProject(id);
              if (!context.mounted) return;
              if (error == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.projectCreated)));
              } else {
                _showCreateErrorDialog(context, l10n, error);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProjectListCubit cubit,
    String projectId,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteProject),
        content: Text(l10n.confirmDeleteProject),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await cubit.deleteProject(projectId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? l10n.projectDeleted : l10n.error),
                  ),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showCreateErrorDialog(
    BuildContext context,
    AppLocalizations l10n,
    String error,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createProjectFailed),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error),
            const SizedBox(height: 16),
            Text(
              l10n.createProjectHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.openConsole),
            onPressed: () {
              launchUrl(
                Uri.parse('https://console.serverpod.cloud/project/create'),
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
