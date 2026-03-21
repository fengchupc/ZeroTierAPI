// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZeroTier One Management';

  @override
  String get homeTitle => 'ZeroTier One Device Status';

  @override
  String get stats => 'Device Stats';

  @override
  String get advancedAdmin => 'Advanced Admin';

  @override
  String get config => 'Configuration';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get notFoundDevices => 'No devices found';

  @override
  String loadFailed(Object error) {
    return 'Load failed: $error';
  }

  @override
  String get configNeeded => 'Please configure API Token and Network ID first';

  @override
  String get unnamedDevice => 'Unnamed Device';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String ipLabel(Object ip) {
    return 'IP: $ip';
  }

  @override
  String get configTitle => 'Configuration';

  @override
  String get apiToken => 'API Token';

  @override
  String get apiTokenHint => 'Get from ZeroTier One Central';

  @override
  String get showToken => 'Show Token';

  @override
  String get hideToken => 'Hide Token';

  @override
  String get copyToken => 'Copy Token';

  @override
  String get tokenCopied => 'Token copied to clipboard';

  @override
  String get networkId => 'Network ID';

  @override
  String get networkIdHint => 'Example: 0000000000000000';

  @override
  String get timeZone => 'Time Zone';

  @override
  String get timeZoneHint => 'Example: Asia/Shanghai, America/New_York';

  @override
  String get language => 'Language';

  @override
  String get saveConfig => 'Save Configuration';

  @override
  String get configSaved => 'Configuration saved';

  @override
  String get configHelp => 'Configuration Help:';

  @override
  String get configHelp1 =>
      '1. Log in to ZeroTier One Central (https://my.zerotier.com)';

  @override
  String get configHelp2 => '2. Find your Network ID on the Networks page';

  @override
  String get configHelp3 => '3. Generate API Token in Settings > API';

  @override
  String version(Object version) {
    return 'Version: $version';
  }

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get deviceDetail => 'Device Detail';

  @override
  String loadDeviceDetailFailed(Object error) {
    return 'Failed to load device detail: $error';
  }

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get memberId => 'Member ID';

  @override
  String get deviceName => 'Device Name';

  @override
  String get description => 'Description';

  @override
  String get status => 'Status';

  @override
  String get lastOnlineTime => 'Last Online Time';

  @override
  String get lastOnline => 'Last Online';

  @override
  String get networkInfo => 'Network Info';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get publicIp => 'Public IP';

  @override
  String get ipAssignments => 'IP Assignments';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get authorized => 'Authorized';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get managementSwitches => 'Management Switches';

  @override
  String get hiddenMember => 'Hidden Member';

  @override
  String get disableAutoAssignIp => 'Disable Auto IP Assign';

  @override
  String get activeBridge => 'Active Bridge';

  @override
  String get ssoExempt => 'SSO Exempt';

  @override
  String get technicalInfo => 'Technical Info';

  @override
  String get nodeId => 'Node ID';

  @override
  String get deviceId => 'Device ID';

  @override
  String get clientVersion => 'Client Version';

  @override
  String get unknown => 'Unknown';

  @override
  String get memberActions => 'Member Actions';

  @override
  String get editMember => 'Edit Member';

  @override
  String get deleteMember => 'Delete Member';

  @override
  String get missingTokenOrNetwork =>
      'Missing API Token or Network ID configuration';

  @override
  String get updateSuccess => 'Member updated';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get deleteSuccess => 'Member deleted';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get copyError => 'Copy Error';

  @override
  String get errorCopied => 'Error copied';

  @override
  String get neverOnline => 'Never online';

  @override
  String get justNowOnline => 'Online just now';

  @override
  String minutesAgo(Object count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count h ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count d ago';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get name => 'Name';

  @override
  String get memberEditTitle => 'Edit Member';

  @override
  String get ipAssignmentsHint => 'Separate multiple IPs with commas';

  @override
  String get deleteMemberTitle => 'Delete Member';

  @override
  String get deleteMemberWarning =>
      'This member will be removed from current network.';

  @override
  String confirmDeleteMember(Object id) {
    return 'Enter member ID to confirm: $id';
  }

  @override
  String get confirmMemberId => 'Confirm Member ID';

  @override
  String get adminTitle => 'ZeroTier One Management';

  @override
  String adminLoadFailed(Object error) {
    return 'Failed to load admin data: $error';
  }

  @override
  String get noAdminData => 'No admin data available';

  @override
  String get centralStatus => 'Central Status';

  @override
  String get centralVersion => 'Central Version';

  @override
  String get apiVersion => 'API Version';

  @override
  String get readOnlyMode => 'Read-only Mode';

  @override
  String get currentNetwork => 'Current Network';

  @override
  String get networkNotConfigured =>
      'Network ID is not configured or inaccessible.';

  @override
  String get networkName => 'Name';

  @override
  String get privateNetwork => 'Private Network';

  @override
  String get defaultValue => 'Default';

  @override
  String get broadcast => 'Broadcast';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get editNetwork => 'Edit Network';

  @override
  String get createNetwork => 'Create Network';

  @override
  String get accessibleNetworks => 'Accessible Networks';

  @override
  String get noAccessibleNetworks => 'No accessible networks for this account';

  @override
  String get noDescription => 'No description';

  @override
  String get current => 'Current';

  @override
  String get setCurrent => 'Set Current';

  @override
  String switchedCurrentNetwork(Object id) {
    return 'Current network switched to $id';
  }

  @override
  String get currentUser => 'Current User';

  @override
  String get cannotFetchCurrentUser => 'Unable to fetch current user';

  @override
  String get userId => 'User ID';

  @override
  String get displayName => 'Display Name';

  @override
  String get email => 'Email';

  @override
  String get orgId => 'Org ID';

  @override
  String get smsNumber => 'SMS Number';

  @override
  String get none => 'None';

  @override
  String get unset => 'Unset';

  @override
  String get editUser => 'Edit User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get apiTokenManagement => 'API Token Management';

  @override
  String get noVisibleApiToken =>
      'No visible API token records for current user';

  @override
  String get deleteToken => 'Delete Token';

  @override
  String get addApiToken => 'Add API Token';

  @override
  String get networkNameLabel => 'Network Name';

  @override
  String get rulesSource => 'Rules Source';

  @override
  String get allowBroadcast => 'Allow Broadcast';

  @override
  String get setCurrentAfterCreate => 'Set as current after creation';

  @override
  String get create => 'Create';

  @override
  String networkCreated(Object id) {
    return 'Network created: $id';
  }

  @override
  String get userUpdated => 'User updated';

  @override
  String get deleteUserTitle => 'Delete User';

  @override
  String get deleteUserWarning =>
      'This operation deletes the user and associated networks. Cannot undo.';

  @override
  String confirmDeleteUser(Object id) {
    return 'Enter user ID to confirm deletion: $id';
  }

  @override
  String get confirmUserId => 'Confirm User ID';

  @override
  String get deleteUserButton => 'Delete User';

  @override
  String get userDeleted => 'User deleted';

  @override
  String get tokenName => 'Token Name';

  @override
  String get tokenValue => 'Token Value';

  @override
  String get generateRandomToken => 'Generate Random Token';

  @override
  String get add => 'Add';

  @override
  String get tokenNameValueRequired =>
      'Token name and token value are both required';

  @override
  String get apiTokenAdded => 'API Token added';

  @override
  String get deleteApiTokenTitle => 'Delete API Token';

  @override
  String confirmDeleteToken(Object name) {
    return 'Confirm deleting token: $name?';
  }

  @override
  String get delete => 'Delete';

  @override
  String tokenDeleted(Object name) {
    return 'Token $name deleted';
  }
}
