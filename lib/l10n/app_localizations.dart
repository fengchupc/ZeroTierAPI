import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ZeroTier One Management'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'ZeroTier One Device Status'**
  String get homeTitle;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Device Stats'**
  String get stats;

  /// No description provided for @advancedAdmin.
  ///
  /// In en, this message translates to:
  /// **'Advanced Admin'**
  String get advancedAdmin;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get config;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @notFoundDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get notFoundDevices;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}'**
  String loadFailed(Object error);

  /// No description provided for @configNeeded.
  ///
  /// In en, this message translates to:
  /// **'Please configure API Token and Network ID first'**
  String get configNeeded;

  /// No description provided for @unnamedDevice.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Device'**
  String get unnamedDevice;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @ipLabel.
  ///
  /// In en, this message translates to:
  /// **'IP: {ip}'**
  String ipLabel(Object ip);

  /// No description provided for @configTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configTitle;

  /// No description provided for @apiToken.
  ///
  /// In en, this message translates to:
  /// **'API Token'**
  String get apiToken;

  /// No description provided for @apiTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Get from ZeroTier One Central'**
  String get apiTokenHint;

  /// No description provided for @showToken.
  ///
  /// In en, this message translates to:
  /// **'Show Token'**
  String get showToken;

  /// No description provided for @hideToken.
  ///
  /// In en, this message translates to:
  /// **'Hide Token'**
  String get hideToken;

  /// No description provided for @copyToken.
  ///
  /// In en, this message translates to:
  /// **'Copy Token'**
  String get copyToken;

  /// No description provided for @tokenCopied.
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard'**
  String get tokenCopied;

  /// No description provided for @networkId.
  ///
  /// In en, this message translates to:
  /// **'Network ID'**
  String get networkId;

  /// No description provided for @networkIdHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 0000000000000000'**
  String get networkIdHint;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get timeZone;

  /// No description provided for @timeZoneHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Asia/Shanghai, America/New_York'**
  String get timeZoneHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @saveConfig.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfig;

  /// No description provided for @configSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved'**
  String get configSaved;

  /// No description provided for @configHelp.
  ///
  /// In en, this message translates to:
  /// **'Configuration Help:'**
  String get configHelp;

  /// No description provided for @configHelp1.
  ///
  /// In en, this message translates to:
  /// **'1. Log in to ZeroTier One Central (https://my.zerotier.com)'**
  String get configHelp1;

  /// No description provided for @configHelp2.
  ///
  /// In en, this message translates to:
  /// **'2. Find your Network ID on the Networks page'**
  String get configHelp2;

  /// No description provided for @configHelp3.
  ///
  /// In en, this message translates to:
  /// **'3. Generate API Token in Settings > API'**
  String get configHelp3;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version(Object version);

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @deviceDetail.
  ///
  /// In en, this message translates to:
  /// **'Device Detail'**
  String get deviceDetail;

  /// No description provided for @loadDeviceDetailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load device detail: {error}'**
  String loadDeviceDetailFailed(Object error);

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @memberId.
  ///
  /// In en, this message translates to:
  /// **'Member ID'**
  String get memberId;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @lastOnlineTime.
  ///
  /// In en, this message translates to:
  /// **'Last Online Time'**
  String get lastOnlineTime;

  /// No description provided for @lastOnline.
  ///
  /// In en, this message translates to:
  /// **'Last Online'**
  String get lastOnline;

  /// No description provided for @networkInfo.
  ///
  /// In en, this message translates to:
  /// **'Network Info'**
  String get networkInfo;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @publicIp.
  ///
  /// In en, this message translates to:
  /// **'Public IP'**
  String get publicIp;

  /// No description provided for @ipAssignments.
  ///
  /// In en, this message translates to:
  /// **'IP Assignments'**
  String get ipAssignments;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorized;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @managementSwitches.
  ///
  /// In en, this message translates to:
  /// **'Management Switches'**
  String get managementSwitches;

  /// No description provided for @hiddenMember.
  ///
  /// In en, this message translates to:
  /// **'Hidden Member'**
  String get hiddenMember;

  /// No description provided for @disableAutoAssignIp.
  ///
  /// In en, this message translates to:
  /// **'Disable Auto IP Assign'**
  String get disableAutoAssignIp;

  /// No description provided for @activeBridge.
  ///
  /// In en, this message translates to:
  /// **'Active Bridge'**
  String get activeBridge;

  /// No description provided for @ssoExempt.
  ///
  /// In en, this message translates to:
  /// **'SSO Exempt'**
  String get ssoExempt;

  /// No description provided for @technicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Technical Info'**
  String get technicalInfo;

  /// No description provided for @nodeId.
  ///
  /// In en, this message translates to:
  /// **'Node ID'**
  String get nodeId;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @clientVersion.
  ///
  /// In en, this message translates to:
  /// **'Client Version'**
  String get clientVersion;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @memberActions.
  ///
  /// In en, this message translates to:
  /// **'Member Actions'**
  String get memberActions;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get editMember;

  /// No description provided for @deleteMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get deleteMember;

  /// No description provided for @missingTokenOrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Missing API Token or Network ID configuration'**
  String get missingTokenOrNetwork;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Member updated'**
  String get updateSuccess;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Member deleted'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @copyError.
  ///
  /// In en, this message translates to:
  /// **'Copy Error'**
  String get copyError;

  /// No description provided for @errorCopied.
  ///
  /// In en, this message translates to:
  /// **'Error copied'**
  String get errorCopied;

  /// No description provided for @neverOnline.
  ///
  /// In en, this message translates to:
  /// **'Never online'**
  String get neverOnline;

  /// No description provided for @justNowOnline.
  ///
  /// In en, this message translates to:
  /// **'Online just now'**
  String get justNowOnline;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String daysAgo(Object count);

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

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @memberEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get memberEditTitle;

  /// No description provided for @ipAssignmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Separate multiple IPs with commas'**
  String get ipAssignmentsHint;

  /// No description provided for @deleteMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get deleteMemberTitle;

  /// No description provided for @deleteMemberWarning.
  ///
  /// In en, this message translates to:
  /// **'This member will be removed from current network.'**
  String get deleteMemberWarning;

  /// No description provided for @confirmDeleteMember.
  ///
  /// In en, this message translates to:
  /// **'Enter member ID to confirm: {id}'**
  String confirmDeleteMember(Object id);

  /// No description provided for @confirmMemberId.
  ///
  /// In en, this message translates to:
  /// **'Confirm Member ID'**
  String get confirmMemberId;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'ZeroTier One Management'**
  String get adminTitle;

  /// No description provided for @adminLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load admin data: {error}'**
  String adminLoadFailed(Object error);

  /// No description provided for @noAdminData.
  ///
  /// In en, this message translates to:
  /// **'No admin data available'**
  String get noAdminData;

  /// No description provided for @centralStatus.
  ///
  /// In en, this message translates to:
  /// **'Central Status'**
  String get centralStatus;

  /// No description provided for @centralVersion.
  ///
  /// In en, this message translates to:
  /// **'Central Version'**
  String get centralVersion;

  /// No description provided for @apiVersion.
  ///
  /// In en, this message translates to:
  /// **'API Version'**
  String get apiVersion;

  /// No description provided for @readOnlyMode.
  ///
  /// In en, this message translates to:
  /// **'Read-only Mode'**
  String get readOnlyMode;

  /// No description provided for @currentNetwork.
  ///
  /// In en, this message translates to:
  /// **'Current Network'**
  String get currentNetwork;

  /// No description provided for @networkNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Network ID is not configured or inaccessible.'**
  String get networkNotConfigured;

  /// No description provided for @networkName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get networkName;

  /// No description provided for @privateNetwork.
  ///
  /// In en, this message translates to:
  /// **'Private Network'**
  String get privateNetwork;

  /// No description provided for @defaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultValue;

  /// No description provided for @broadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get broadcast;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @editNetwork.
  ///
  /// In en, this message translates to:
  /// **'Edit Network'**
  String get editNetwork;

  /// No description provided for @createNetwork.
  ///
  /// In en, this message translates to:
  /// **'Create Network'**
  String get createNetwork;

  /// No description provided for @accessibleNetworks.
  ///
  /// In en, this message translates to:
  /// **'Accessible Networks'**
  String get accessibleNetworks;

  /// No description provided for @noAccessibleNetworks.
  ///
  /// In en, this message translates to:
  /// **'No accessible networks for this account'**
  String get noAccessibleNetworks;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @setCurrent.
  ///
  /// In en, this message translates to:
  /// **'Set Current'**
  String get setCurrent;

  /// No description provided for @switchedCurrentNetwork.
  ///
  /// In en, this message translates to:
  /// **'Current network switched to {id}'**
  String switchedCurrentNetwork(Object id);

  /// No description provided for @currentUser.
  ///
  /// In en, this message translates to:
  /// **'Current User'**
  String get currentUser;

  /// No description provided for @cannotFetchCurrentUser.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch current user'**
  String get cannotFetchCurrentUser;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @orgId.
  ///
  /// In en, this message translates to:
  /// **'Org ID'**
  String get orgId;

  /// No description provided for @smsNumber.
  ///
  /// In en, this message translates to:
  /// **'SMS Number'**
  String get smsNumber;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @unset.
  ///
  /// In en, this message translates to:
  /// **'Unset'**
  String get unset;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @apiTokenManagement.
  ///
  /// In en, this message translates to:
  /// **'API Token Management'**
  String get apiTokenManagement;

  /// No description provided for @noVisibleApiToken.
  ///
  /// In en, this message translates to:
  /// **'No visible API token records for current user'**
  String get noVisibleApiToken;

  /// No description provided for @deleteToken.
  ///
  /// In en, this message translates to:
  /// **'Delete Token'**
  String get deleteToken;

  /// No description provided for @addApiToken.
  ///
  /// In en, this message translates to:
  /// **'Add API Token'**
  String get addApiToken;

  /// No description provided for @networkNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Network Name'**
  String get networkNameLabel;

  /// No description provided for @rulesSource.
  ///
  /// In en, this message translates to:
  /// **'Rules Source'**
  String get rulesSource;

  /// No description provided for @allowBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Allow Broadcast'**
  String get allowBroadcast;

  /// No description provided for @setCurrentAfterCreate.
  ///
  /// In en, this message translates to:
  /// **'Set as current after creation'**
  String get setCurrentAfterCreate;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @networkCreated.
  ///
  /// In en, this message translates to:
  /// **'Network created: {id}'**
  String networkCreated(Object id);

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated'**
  String get userUpdated;

  /// No description provided for @deleteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUserTitle;

  /// No description provided for @deleteUserWarning.
  ///
  /// In en, this message translates to:
  /// **'This operation deletes the user and associated networks. Cannot undo.'**
  String get deleteUserWarning;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID to confirm deletion: {id}'**
  String confirmDeleteUser(Object id);

  /// No description provided for @confirmUserId.
  ///
  /// In en, this message translates to:
  /// **'Confirm User ID'**
  String get confirmUserId;

  /// No description provided for @deleteUserButton.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUserButton;

  /// No description provided for @userDeleted.
  ///
  /// In en, this message translates to:
  /// **'User deleted'**
  String get userDeleted;

  /// No description provided for @tokenName.
  ///
  /// In en, this message translates to:
  /// **'Token Name'**
  String get tokenName;

  /// No description provided for @tokenValue.
  ///
  /// In en, this message translates to:
  /// **'Token Value'**
  String get tokenValue;

  /// No description provided for @generateRandomToken.
  ///
  /// In en, this message translates to:
  /// **'Generate Random Token'**
  String get generateRandomToken;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @tokenNameValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Token name and token value are both required'**
  String get tokenNameValueRequired;

  /// No description provided for @apiTokenAdded.
  ///
  /// In en, this message translates to:
  /// **'API Token added'**
  String get apiTokenAdded;

  /// No description provided for @deleteApiTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete API Token'**
  String get deleteApiTokenTitle;

  /// No description provided for @confirmDeleteToken.
  ///
  /// In en, this message translates to:
  /// **'Confirm deleting token: {name}?'**
  String confirmDeleteToken(Object name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @tokenDeleted.
  ///
  /// In en, this message translates to:
  /// **'Token {name} deleted'**
  String tokenDeleted(Object name);
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
