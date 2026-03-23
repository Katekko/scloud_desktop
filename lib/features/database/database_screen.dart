import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'database_cubit.dart';
import 'database_state.dart';

class DatabaseScreen extends StatelessWidget {
  const DatabaseScreen({super.key, required this.projectId});

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
    final cubit = context.read<DatabaseCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.databaseTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.status),
        ),
      ),
      body: BlocBuilder<DatabaseCubit, DatabaseState>(
        builder: (context, state) {
          return switch (state) {
            DatabaseLoading() || DatabaseOperationInProgress() => const Center(
              child: CircularProgressIndicator(),
            ),
            DatabaseError(:final message) => Center(
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
            DatabaseLoaded(:final connection) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.connectionDetails,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: l10n.host, value: connection.host),
                  _InfoRow(label: l10n.port, value: connection.port.toString()),
                  _InfoRow(label: l10n.databaseName, value: connection.name),
                  _InfoRow(label: l10n.databaseUser, value: connection.user),
                  _InfoRow(
                    label: l10n.requiresSsl,
                    value: connection.requiresSsl ? 'Yes' : 'No',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: Text(l10n.createSuperUser),
                        onPressed: () =>
                            _showCreateSuperUserDialog(context, cubit),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.lock_reset),
                        label: Text(l10n.resetPassword),
                        onPressed: () =>
                            _showResetPasswordDialog(context, cubit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }

  void _showCreateSuperUserDialog(BuildContext context, DatabaseCubit cubit) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createSuperUser),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.username),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final username = controller.text.trim();
              if (username.isEmpty) return;
              Navigator.pop(ctx);
              final password = await cubit.createSuperUser(username);
              if (password != null && context.mounted) {
                _showPasswordDialog(context, password);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, DatabaseCubit cubit) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetPassword),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.username),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final username = controller.text.trim();
              if (username.isEmpty) return;
              Navigator.pop(ctx);
              final password = await cubit.resetPassword(username);
              if (password != null && context.mounted) {
                _showPasswordDialog(context, password);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, String password) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newPassword),
        content: SelectableText(
          password,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: password));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.passwordCopied)));
            },
            child: Text(l10n.copyPassword),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
