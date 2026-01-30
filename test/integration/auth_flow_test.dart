import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scloud_desktop/app.dart';
import 'package:scloud_desktop/di/injection.dart';
import 'package:scloud_desktop/features/auth/auth_cubit.dart';
import 'package:scloud_desktop/features/auth/auth_repository.dart';
import 'package:scloud_desktop/features/auth/login_screen.dart';
import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/l10n/app_localizations_en.dart'
    show AppLocalizationsEn;
import 'package:scloud_desktop/router/app_router.dart';

/// Integration test for auth flow (per constitution):
/// Start login → waiting state → success path or cancel.
void main() {
  setUp(() async {
    getIt.reset();
    await configureDependencies();
    initRouter();
  });

  testWidgets('App shows login screen when unauthenticated', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().logIn), findsOneWidget);
  });

  testWidgets('Tapping Log in shows waiting screen', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppLocalizationsEn().logIn));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text(AppLocalizationsEn().completeSignInInBrowser),
      findsOneWidget,
    );
  });

  testWidgets('Error state shows signInNotCompleted message on login screen', (
    tester,
  ) async {
    final cubit = AuthCubit(AuthRepository());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginScreen(
          cubit: cubit,
          errorMessage: 'signInNotCompleted',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().signInNotCompleted), findsOneWidget);
  });
}
