import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'secrets_cubit.dart';
import 'secrets_state.dart';

class SecretsScreen extends StatelessWidget {
  const SecretsScreen({super.key, required this.projectId});

  final String projectId;

  static String? projectIdFromExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      return extra['projectId'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SecretsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.secretsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.status),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, cubit),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<SecretsCubit, SecretsState>(
        builder: (context, state) {
          return switch (state) {
            SecretsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            SecretsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => cubit.load(projectId),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            SecretsLoaded(:final keys) ||
            SecretsOperationInProgress(:final keys) => Stack(
              children: [
                keys.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noSecrets,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.secretsNote,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: keys.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final key = keys[index];
                          return ListTile(
                            title: Text(
                              key,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () =>
                                  _showDeleteDialog(context, cubit, key),
                            ),
                          );
                        },
                      ),
                if (state is SecretsOperationInProgress)
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

  void _showAddDialog(BuildContext context, SecretsCubit cubit) {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addSecret),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.secretsNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: InputDecoration(labelText: l10n.secretKey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: l10n.secretValue),
              obscureText: true,
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
              final key = keyController.text.trim();
              final value = valueController.text.trim();
              if (key.isNotEmpty && value.isNotEmpty) {
                Navigator.pop(ctx);
                cubit.upsert(key, value);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SecretsCubit cubit, String key) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSecret),
        content: Text('${l10n.confirmDeleteSecret} "$key"?'),
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
              cubit.delete(key);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
