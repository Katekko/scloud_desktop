// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get logIn => 'Log in';

  @override
  String get completeSignInInBrowser => 'Complete sign-in in browser';

  @override
  String get signInNotCompleted => 'Sign-in was not completed.';

  @override
  String get sessionExpired => 'Session expired. Please sign in again.';

  @override
  String get networkError => 'A network error occurred. Please try again.';

  @override
  String get signOut => 'Sign out';
}
