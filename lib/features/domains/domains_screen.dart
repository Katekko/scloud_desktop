import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'domains_cubit.dart';
import 'domains_state.dart';

class DomainsScreen extends StatelessWidget {
  const DomainsScreen({super.key, required this.projectId});

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
    final cubit = context.read<DomainsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.domainsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.status),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, cubit),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<DomainsCubit, DomainsState>(
        builder: (context, state) {
          return switch (state) {
            DomainsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DomainsError(:final message) => Center(
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
            DomainsLoaded(:final domainList) ||
            DomainsOperationInProgress(:final domainList) => Stack(
              children: [
                domainList.customDomainNames.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noDomains,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: domainList.customDomainNames.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final domain = domainList.customDomainNames[index];
                          return ListTile(
                            title: Text(
                              domain.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                            subtitle: Text(
                              '${l10n.domainTarget}: ${domain.target.name}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: l10n.refreshDns,
                                  onPressed: () =>
                                      cubit.refreshDns(domain.name),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => _showRemoveDialog(
                                    context,
                                    cubit,
                                    domain.name,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                if (state is DomainsOperationInProgress)
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

  void _showAddDialog(BuildContext context, DomainsCubit cubit) {
    final nameController = TextEditingController();
    var selectedTarget = DomainNameTarget.api;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.addDomain),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.domainName),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DomainNameTarget>(
                initialValue: selectedTarget,
                decoration: InputDecoration(labelText: l10n.domainTarget),
                items: DomainNameTarget.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedTarget = v);
                },
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
                if (name.isNotEmpty) {
                  Navigator.pop(ctx);
                  cubit.add(name, selectedTarget);
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    DomainsCubit cubit,
    String domainName,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeDomain),
        content: Text('${l10n.confirmRemoveDomain} "$domainName"?'),
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
              cubit.remove(domainName);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
