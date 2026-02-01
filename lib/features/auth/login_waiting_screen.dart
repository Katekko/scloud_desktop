import 'package:flutter/material.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';

/// Waiting screen shown during login: "Complete sign-in in browser".
class LoginWaitingScreen extends StatelessWidget {
  const LoginWaitingScreen({super.key});

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
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                l10n.completeSignInInBrowser,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
