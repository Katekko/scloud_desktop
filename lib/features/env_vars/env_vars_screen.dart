import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'env_vars_cubit.dart';
import 'env_vars_state.dart';

/// Screen for managing environment variables of a project.
class EnvVarsScreen extends StatefulWidget {
  const EnvVarsScreen({super.key, required this.projectId});

  final String projectId;

  static String? projectIdFromExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      return extra['projectId'] as String?;
    }
    return null;
  }

  @override
  State<EnvVarsScreen> createState() => _EnvVarsScreenState();
}

class _EnvVarsScreenState extends State<EnvVarsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<EnvVarsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.envVarsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.status),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, cubit),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<EnvVarsCubit, EnvVarsState>(
        builder: (context, state) {
          return switch (state) {
            EnvVarsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            EnvVarsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => cubit.load(widget.projectId),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            EnvVarsLoaded(:final variables) ||
            EnvVarsOperationInProgress(:final variables) => Stack(
              children: [
                variables.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noEnvVars,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: variables.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final v = variables[index];
                          return _EnvVarTile(
                            variable: v,
                            onEdit: () => _showEditDialog(context, cubit, v),
                            onDelete: () =>
                                _showDeleteDialog(context, cubit, v.name),
                          );
                        },
                      ),
                if (state is EnvVarsOperationInProgress)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black26,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          };
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, EnvVarsCubit cubit) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addEnvVar),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.envVarName),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: l10n.envVarValue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final value = valueController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                cubit.create(name, value);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    EnvVarsCubit cubit,
    EnvironmentVariable variable,
  ) {
    final valueController = TextEditingController(text: variable.value);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.editEnvVar}: ${variable.name}'),
        content: TextField(
          controller: valueController,
          decoration: InputDecoration(labelText: l10n.envVarValue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = valueController.text.trim();
              Navigator.pop(ctx);
              cubit.update(variable.name, value);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    EnvVarsCubit cubit,
    String name,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteEnvVar),
        content: Text('${l10n.confirmDeleteEnvVar} "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.delete(name);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _EnvVarTile extends StatelessWidget {
  const _EnvVarTile({
    required this.variable,
    required this.onEdit,
    required this.onDelete,
  });

  final EnvironmentVariable variable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        variable.name,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontFamily: 'monospace'),
      ),
      subtitle: Text(
        variable.value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
