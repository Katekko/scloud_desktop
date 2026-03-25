import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @completeSignInInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Complete sign-in in browser'**
  String get completeSignInInBrowser;

  /// No description provided for @signInNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was not completed.'**
  String get signInNotCompleted;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Please try again.'**
  String get networkError;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @projectListTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectListTitle;

  /// No description provided for @noProjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjectsYet;

  /// No description provided for @projectListLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading projects…'**
  String get projectListLoading;

  /// No description provided for @projectListErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load projects. Tap to retry.'**
  String get projectListErrorRetry;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @noProjectSelected.
  ///
  /// In en, this message translates to:
  /// **'No project selected'**
  String get noProjectSelected;

  /// No description provided for @chooseProjectToViewStatus.
  ///
  /// In en, this message translates to:
  /// **'Choose a project from the list to view its details.'**
  String get chooseProjectToViewStatus;

  /// No description provided for @goToProjectList.
  ///
  /// In en, this message translates to:
  /// **'Go to project list'**
  String get goToProjectList;

  /// No description provided for @viewStatus.
  ///
  /// In en, this message translates to:
  /// **'View status'**
  String get viewStatus;

  /// No description provided for @statusTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusTitle;

  /// No description provided for @projectDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Project details'**
  String get projectDetailsTitle;

  /// No description provided for @deployHistory.
  ///
  /// In en, this message translates to:
  /// **'Deploy history'**
  String get deployHistory;

  /// No description provided for @deployId.
  ///
  /// In en, this message translates to:
  /// **'Deploy ID'**
  String get deployId;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @noDeploysYet.
  ///
  /// In en, this message translates to:
  /// **'No deploys yet'**
  String get noDeploysYet;

  /// No description provided for @deploymentState.
  ///
  /// In en, this message translates to:
  /// **'Deployment state'**
  String get deploymentState;

  /// No description provided for @lastDeployTime.
  ///
  /// In en, this message translates to:
  /// **'Last deploy'**
  String get lastDeployTime;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @projectLinks.
  ///
  /// In en, this message translates to:
  /// **'Project links'**
  String get projectLinks;

  /// No description provided for @statusErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load status. Tap to retry.'**
  String get statusErrorRetry;

  /// No description provided for @invalidServerDirectory.
  ///
  /// In en, this message translates to:
  /// **'The selected folder is not a valid Serverpod server linked to Cloud.'**
  String get invalidServerDirectory;

  /// No description provided for @chooseServerDirectory.
  ///
  /// In en, this message translates to:
  /// **'Choose server directory'**
  String get chooseServerDirectory;

  /// No description provided for @buildLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Build log - {attemptId}'**
  String buildLogTitle(String attemptId);

  /// No description provided for @loadingLogs.
  ///
  /// In en, this message translates to:
  /// **'Loading logs…'**
  String get loadingLogs;

  /// No description provided for @noLogs.
  ///
  /// In en, this message translates to:
  /// **'No logs.'**
  String get noLogs;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @containerLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Container logs'**
  String get containerLogsTitle;

  /// No description provided for @tailingLogs.
  ///
  /// In en, this message translates to:
  /// **'Tailing logs…'**
  String get tailingLogs;

  /// No description provided for @copyAllLogs.
  ///
  /// In en, this message translates to:
  /// **'Copy all logs'**
  String get copyAllLogs;

  /// No description provided for @logsCopied.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get logsCopied;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @envVarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Environment variables'**
  String get envVarsTitle;

  /// No description provided for @noEnvVars.
  ///
  /// In en, this message translates to:
  /// **'No environment variables.'**
  String get noEnvVars;

  /// No description provided for @addEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Add environment variable'**
  String get addEnvVar;

  /// No description provided for @editEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Edit environment variable'**
  String get editEnvVar;

  /// No description provided for @deleteEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Delete environment variable'**
  String get deleteEnvVar;

  /// No description provided for @confirmDeleteEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get confirmDeleteEnvVar;

  /// No description provided for @envVarName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get envVarName;

  /// No description provided for @envVarValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get envVarValue;

  /// No description provided for @secretsTitle.
  ///
  /// In en, this message translates to:
  /// **'Secrets'**
  String get secretsTitle;

  /// No description provided for @noSecrets.
  ///
  /// In en, this message translates to:
  /// **'No secrets.'**
  String get noSecrets;

  /// No description provided for @addSecret.
  ///
  /// In en, this message translates to:
  /// **'Add secret'**
  String get addSecret;

  /// No description provided for @deleteSecret.
  ///
  /// In en, this message translates to:
  /// **'Delete secret'**
  String get deleteSecret;

  /// No description provided for @confirmDeleteSecret.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete secret'**
  String get confirmDeleteSecret;

  /// No description provided for @secretKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get secretKey;

  /// No description provided for @secretValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get secretValue;

  /// No description provided for @secretsNote.
  ///
  /// In en, this message translates to:
  /// **'Secret values are write-only and cannot be read back.'**
  String get secretsNote;

  /// No description provided for @domainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom domains'**
  String get domainsTitle;

  /// No description provided for @noDomains.
  ///
  /// In en, this message translates to:
  /// **'No custom domains.'**
  String get noDomains;

  /// No description provided for @addDomain.
  ///
  /// In en, this message translates to:
  /// **'Add domain'**
  String get addDomain;

  /// No description provided for @removeDomain.
  ///
  /// In en, this message translates to:
  /// **'Remove domain'**
  String get removeDomain;

  /// No description provided for @confirmRemoveDomain.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove domain'**
  String get confirmRemoveDomain;

  /// No description provided for @domainName.
  ///
  /// In en, this message translates to:
  /// **'Domain name'**
  String get domainName;

  /// No description provided for @domainTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get domainTarget;

  /// No description provided for @domainTargetApi.
  ///
  /// In en, this message translates to:
  /// **'API'**
  String get domainTargetApi;

  /// No description provided for @domainTargetWeb.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get domainTargetWeb;

  /// No description provided for @domainTargetInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get domainTargetInsights;

  /// No description provided for @refreshDns.
  ///
  /// In en, this message translates to:
  /// **'Refresh DNS'**
  String get refreshDns;

  /// No description provided for @dnsStatus.
  ///
  /// In en, this message translates to:
  /// **'DNS status'**
  String get dnsStatus;

  /// No description provided for @databaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get databaseTitle;

  /// No description provided for @connectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Connection details'**
  String get connectionDetails;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @databaseName.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get databaseName;

  /// No description provided for @databaseUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get databaseUser;

  /// No description provided for @requiresSsl.
  ///
  /// In en, this message translates to:
  /// **'Requires SSL'**
  String get requiresSsl;

  /// No description provided for @createSuperUser.
  ///
  /// In en, this message translates to:
  /// **'Create super user'**
  String get createSuperUser;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password copied to clipboard'**
  String get passwordCopied;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get copyPassword;

  /// No description provided for @redeploy.
  ///
  /// In en, this message translates to:
  /// **'Redeploy'**
  String get redeploy;

  /// No description provided for @confirmRedeploy.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to redeploy this project?'**
  String get confirmRedeploy;

  /// No description provided for @redeployStarted.
  ///
  /// In en, this message translates to:
  /// **'Redeploy started'**
  String get redeployStarted;

  /// No description provided for @redeployFailed.
  ///
  /// In en, this message translates to:
  /// **'Redeploy failed'**
  String get redeployFailed;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProject;

  /// No description provided for @deleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get deleteProject;

  /// No description provided for @confirmDeleteProject.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this project? This action cannot be undone.'**
  String get confirmDeleteProject;

  /// No description provided for @projectId.
  ///
  /// In en, this message translates to:
  /// **'Project ID'**
  String get projectId;

  /// No description provided for @projectCreated.
  ///
  /// In en, this message translates to:
  /// **'Project created'**
  String get projectCreated;

  /// No description provided for @projectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Project deleted'**
  String get projectDeleted;

  /// No description provided for @createProjectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create project'**
  String get createProjectFailed;

  /// No description provided for @createProjectHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure you have a valid payment method registered at the Serverpod Cloud console before creating a project.'**
  String get createProjectHint;

  /// No description provided for @openConsole.
  ///
  /// In en, this message translates to:
  /// **'Open console'**
  String get openConsole;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users & roles'**
  String get usersTitle;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users.'**
  String get noUsers;

  /// No description provided for @inviteUser.
  ///
  /// In en, this message translates to:
  /// **'Invite user'**
  String get inviteUser;

  /// No description provided for @revokeUser.
  ///
  /// In en, this message translates to:
  /// **'Revoke user'**
  String get revokeUser;

  /// No description provided for @confirmRevokeUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke all roles from'**
  String get confirmRevokeUser;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @selectRoles.
  ///
  /// In en, this message translates to:
  /// **'Select roles'**
  String get selectRoles;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get accountStatus;

  /// No description provided for @billingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing & plans'**
  String get billingTitle;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planName;

  /// No description provided for @planDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get planDescription;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @trialEndDate.
  ///
  /// In en, this message translates to:
  /// **'Trial ends'**
  String get trialEndDate;

  /// No description provided for @projectsLimit.
  ///
  /// In en, this message translates to:
  /// **'Projects limit'**
  String get projectsLimit;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethodsTitle;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods on file.'**
  String get noPaymentMethods;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @availablePlans.
  ///
  /// In en, this message translates to:
  /// **'Your plans'**
  String get availablePlans;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
