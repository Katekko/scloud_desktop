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

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get email => 'Email';

  @override
  String get name => 'Name';

  @override
  String get value => 'Value';

  @override
  String get success => 'Success';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Error';

  @override
  String get envVarsTitle => 'Environment variables';

  @override
  String get noEnvVars => 'No environment variables.';

  @override
  String get addEnvVar => 'Add environment variable';

  @override
  String get editEnvVar => 'Edit environment variable';

  @override
  String get deleteEnvVar => 'Delete environment variable';

  @override
  String get confirmDeleteEnvVar => 'Are you sure you want to delete';

  @override
  String get envVarName => 'Name';

  @override
  String get envVarValue => 'Value';

  @override
  String get secretsTitle => 'Secrets';

  @override
  String get noSecrets => 'No secrets.';

  @override
  String get addSecret => 'Add secret';

  @override
  String get deleteSecret => 'Delete secret';

  @override
  String get confirmDeleteSecret => 'Are you sure you want to delete secret';

  @override
  String get secretKey => 'Key';

  @override
  String get secretValue => 'Value';

  @override
  String get secretsNote =>
      'Secret values are write-only and cannot be read back.';

  @override
  String get domainsTitle => 'Custom domains';

  @override
  String get noDomains => 'No custom domains.';

  @override
  String get addDomain => 'Add domain';

  @override
  String get removeDomain => 'Remove domain';

  @override
  String get confirmRemoveDomain => 'Are you sure you want to remove domain';

  @override
  String get domainName => 'Domain name';

  @override
  String get domainTarget => 'Target';

  @override
  String get domainTargetApi => 'API';

  @override
  String get domainTargetWeb => 'Web';

  @override
  String get domainTargetInsights => 'Insights';

  @override
  String get refreshDns => 'Refresh DNS';

  @override
  String get dnsStatus => 'DNS status';

  @override
  String get databaseTitle => 'Database';

  @override
  String get connectionDetails => 'Connection details';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get databaseName => 'Database';

  @override
  String get databaseUser => 'User';

  @override
  String get requiresSsl => 'Requires SSL';

  @override
  String get createSuperUser => 'Create super user';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get passwordCopied => 'Password copied to clipboard';

  @override
  String get newPassword => 'New password';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get redeploy => 'Redeploy';

  @override
  String get confirmRedeploy =>
      'Are you sure you want to redeploy this project?';

  @override
  String get redeployStarted => 'Redeploy started';

  @override
  String get redeployFailed => 'Redeploy failed';

  @override
  String get createProject => 'Create project';

  @override
  String get deleteProject => 'Delete project';

  @override
  String get confirmDeleteProject =>
      'Are you sure you want to permanently delete this project? This action cannot be undone.';

  @override
  String get projectId => 'Project ID';

  @override
  String get projectCreated => 'Project created';

  @override
  String get projectDeleted => 'Project deleted';

  @override
  String get createProjectFailed => 'Failed to create project';

  @override
  String get createProjectHint =>
      'Make sure you have a valid payment method registered at the Serverpod Cloud console before creating a project.';

  @override
  String get openConsole => 'Open console';

  @override
  String get usersTitle => 'Users & roles';

  @override
  String get noUsers => 'No users.';

  @override
  String get inviteUser => 'Invite user';

  @override
  String get revokeUser => 'Revoke user';

  @override
  String get confirmRevokeUser =>
      'Are you sure you want to revoke all roles from';

  @override
  String get roles => 'Roles';

  @override
  String get selectRoles => 'Select roles';

  @override
  String get profileTitle => 'Profile';

  @override
  String get accountStatus => 'Account status';

  @override
  String get billingTitle => 'Billing & plans';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get planName => 'Plan';

  @override
  String get planDescription => 'Description';

  @override
  String get startDate => 'Start date';

  @override
  String get trialEndDate => 'Trial ends';

  @override
  String get projectsLimit => 'Projects limit';

  @override
  String get paymentMethodsTitle => 'Payment methods';

  @override
  String get noPaymentMethods => 'No payment methods on file.';

  @override
  String get expires => 'Expires';

  @override
  String get defaultLabel => 'Default';

  @override
  String get availablePlans => 'Your plans';
}
