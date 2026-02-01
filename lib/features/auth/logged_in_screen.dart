import 'package:flutter/material.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';

import 'auth_cubit.dart';

/// Logged-in screen: account identity and Sign out button.
class LoggedInScreen extends StatelessWidget {
  const LoggedInScreen({
    super.key,
    required this.cubit,
    required this.identity,
  });

  final AuthCubit cubit;
  final String identity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                identity,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => cubit.signOut(),
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
