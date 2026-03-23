import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/router/app_router.dart';

import 'billing_cubit.dart';
import 'billing_state.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BillingCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.billingTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: BlocBuilder<BillingCubit, BillingState>(
        builder: (context, state) {
          return switch (state) {
            BillingLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BillingError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<BillingCubit>().load(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            BillingLoaded(
              :final subscriptionInfo,
              :final paymentMethods,
              :final planNames,
            ) =>
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subscriptionTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: l10n.planName,
                      value: subscriptionInfo.planDisplayName,
                    ),
                    if (subscriptionInfo.planDescription != null)
                      _InfoRow(
                        label: l10n.planDescription,
                        value: subscriptionInfo.planDescription!,
                      ),
                    _InfoRow(
                      label: l10n.startDate,
                      value: _formatDate(subscriptionInfo.startDate),
                    ),
                    if (subscriptionInfo.trialEndDate != null)
                      _InfoRow(
                        label: l10n.trialEndDate,
                        value: _formatDate(subscriptionInfo.trialEndDate!),
                      ),
                    if (subscriptionInfo.projectsLimit != null)
                      _InfoRow(
                        label: l10n.projectsLimit,
                        value: subscriptionInfo.projectsLimit.toString(),
                      ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.paymentMethodsTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (paymentMethods.isEmpty)
                      Text(
                        l10n.noPaymentMethods,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      ...paymentMethods.map(
                        (pm) => Card(
                          child: ListTile(
                            leading: Icon(
                              pm.type == 'card'
                                  ? Icons.credit_card
                                  : Icons.payment,
                            ),
                            title: Text(
                              pm.card != null
                                  ? '${pm.card!.brand.toUpperCase()} **** ${pm.card!.last4}'
                                  : pm.type,
                            ),
                            subtitle: pm.card != null
                                ? Text(
                                    '${l10n.expires} ${pm.card!.expMonth}/${pm.card!.expYear}',
                                  )
                                : null,
                            trailing: pm.isDefault
                                ? Chip(label: Text(l10n.defaultLabel))
                                : null,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.availablePlans,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: planNames
                          .map((name) => Chip(label: Text(name)))
                          .toList(),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
