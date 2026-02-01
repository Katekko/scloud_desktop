import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:scloud_desktop/di/injection.dart';
import 'package:scloud_desktop/features/auth/auth_cubit.dart';
import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'project_list_cubit.dart';
import 'project_list_state.dart';

/// Project list screen: shows linked/available projects with indicator,
/// loading/empty/error states. Tapping a project navigates to its status screen.
class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({
    super.key,
    required this.cubit,
    required this.authCubit,
  });

  final ProjectListCubit cubit;
  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              getIt<ProjectListCubit>().clearCurrentProject();
              authCubit.signOut();
            },
            tooltip: l10n.signOut,
          ),
        ],
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
                );
              },
            ),
          };
        },
      ),
    );
  }
}
