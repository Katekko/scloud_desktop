import 'package:flutter/material.dart';

import 'package:scloud_desktop/l10n/app_localizations.dart';

import 'auth_service.dart';

/// Login screen: Log in button and error message area.
/// Shows error when auth_state is error (e.g. signInNotCompleted).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.authService, this.errorMessage});

  final AuthService authService;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = errorMessage;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (error != null) ...[
                Text(
                  _localizeError(error, l10n),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              FilledButton(
                onPressed: () => authService.login(),
                child: Text(l10n.logIn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _localizeError(String key, AppLocalizations l10n) {
    return switch (key) {
      'signInNotCompleted' => l10n.signInNotCompleted,
      'sessionExpired' => l10n.sessionExpired,
      'networkError' => l10n.networkError,
      _ => key,
    };
  }
}
