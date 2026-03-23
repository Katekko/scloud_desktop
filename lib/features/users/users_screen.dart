import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'users_cubit.dart';
import 'users_state.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key, required this.projectId});

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
    final cubit = context.read<UsersCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.usersTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.status),
        ),
      ),
      floatingActionButton: BlocSelector<UsersCubit, UsersState, List<Role>>(
        selector: (state) => state is UsersLoaded ? state.roles : <Role>[],
        builder: (context, roles) {
          if (roles.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showInviteDialog(context, cubit, roles),
            child: const Icon(Icons.person_add),
          );
        },
      ),
      body: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          return switch (state) {
            UsersLoading() || UsersOperationInProgress() => const Center(
              child: CircularProgressIndicator(),
            ),
            UsersError(:final message) => Center(
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
            UsersLoaded(:final users) =>
              users.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noUsers,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(user.email),
                          subtitle: Text(
                            '${l10n.accountStatus}: ${user.accountStatus.name}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.person_remove,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () =>
                                _showRevokeDialog(context, cubit, user.email),
                          ),
                        );
                      },
                    ),
          };
        },
      ),
    );
  }

  void _showInviteDialog(
    BuildContext context,
    UsersCubit cubit,
    List<Role> roles,
  ) {
    final emailController = TextEditingController();
    final selectedRoles = <String>{};
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.inviteUser),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.selectRoles,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              ...roles.map(
                (role) => CheckboxListTile(
                  title: Text(role.name),
                  value: selectedRoles.contains(role.name),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selectedRoles.add(role.name);
                      } else {
                        selectedRoles.remove(role.name);
                      }
                    });
                  },
                ),
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
                final email = emailController.text.trim();
                if (email.isNotEmpty && selectedRoles.isNotEmpty) {
                  Navigator.pop(ctx);
                  cubit.invite(email, selectedRoles.toList());
                }
              },
              child: Text(l10n.inviteUser),
            ),
          ],
        ),
      ),
    );
  }

  void _showRevokeDialog(BuildContext context, UsersCubit cubit, String email) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.revokeUser),
        content: Text('${l10n.confirmRevokeUser} "$email"?'),
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
              cubit.revoke(email);
            },
            child: Text(l10n.revokeUser),
          ),
        ],
      ),
    );
  }
}
