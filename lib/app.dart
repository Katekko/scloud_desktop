import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/auth/auth_service.dart';
import 'features/auth/auth_state.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/login_waiting_screen.dart';
import 'features/auth/logged_in_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.restoreSession();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'scloud_desktop',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: StreamBuilder<AuthState>(
        stream: _authService.authStateStream,
        initialData: _authService.authState,
        builder: (context, snapshot) {
          final state = snapshot.data ?? _authService.authState;
          return _buildScreenForState(state);
        },
      ),
    );
  }

  Widget _buildScreenForState(AuthState state) {
    return switch (state) {
      Unauthenticated() => LoginScreen(authService: _authService),
      LoginInProgress() => LoginWaitingScreen(),
      Authenticated(:final identity) => LoggedInScreen(
        authService: _authService,
        identity: identity,
      ),
      AuthError(:final message) => LoginScreen(
        authService: _authService,
        errorMessage: message,
      ),
    };
  }
}
