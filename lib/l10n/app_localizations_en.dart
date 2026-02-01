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

  @override
  String get projectListTitle => 'Projects';

  @override
  String get noProjectsYet => 'No projects yet';

  @override
  String get projectListLoading => 'Loading projects…';

  @override
  String get projectListErrorRetry => 'Failed to load projects. Tap to retry.';

  @override
  String get retry => 'Retry';

  @override
  String get linked => 'Linked';

  @override
  String get available => 'Available';

  @override
  String get noProjectSelected => 'No project selected';

  @override
  String get chooseProjectToViewStatus =>
      'Choose a project from the list to view its details.';

  @override
  String get goToProjectList => 'Go to project list';

  @override
  String get viewStatus => 'View status';

  @override
  String get statusTitle => 'Status';

  @override
  String get projectDetailsTitle => 'Project details';

  @override
  String get deployHistory => 'Deploy history';

  @override
  String get deployId => 'Deploy ID';

  @override
  String get started => 'Started';

  @override
  String get finished => 'Finished';

  @override
  String get noDeploysYet => 'No deploys yet';

  @override
  String get deploymentState => 'Deployment state';

  @override
  String get lastDeployTime => 'Last deploy';

  @override
  String get environment => 'Environment';

  @override
  String get statusErrorRetry => 'Failed to load status. Tap to retry.';

  @override
  String get invalidServerDirectory =>
      'The selected folder is not a valid Serverpod server linked to Cloud.';

  @override
  String get chooseServerDirectory => 'Choose server directory';

  @override
  String buildLogTitle(String attemptId) {
    return 'Build log - $attemptId';
  }

  @override
  String get loadingLogs => 'Loading logs…';

  @override
  String get noLogs => 'No logs.';

  @override
  String get timestamp => 'Timestamp';

  @override
  String get severity => 'Severity';

  @override
  String get content => 'Content';

  @override
  String get containerLogsTitle => 'Container logs';

  @override
  String get tailingLogs => 'Tailing logs…';
}
