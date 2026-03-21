// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ZeroTier One 管理';

  @override
  String get homeTitle => 'ZeroTier One 设备状态';

  @override
  String get stats => '设备统计';

  @override
  String get advancedAdmin => '高级管理';

  @override
  String get config => '配置';

  @override
  String get refresh => '刷新';

  @override
  String get retry => '重试';

  @override
  String get notFoundDevices => '未找到设备';

  @override
  String loadFailed(Object error) {
    return '加载失败: $error';
  }

  @override
  String get configNeeded => '请先配置 API Token 和 Network ID';

  @override
  String get unnamedDevice => '未命名设备';

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String ipLabel(Object ip) {
    return 'IP: $ip';
  }

  @override
  String get configTitle => '配置';

  @override
  String get apiToken => 'API Token';

  @override
  String get apiTokenHint => '从 ZeroTier One 控制台获取';

  @override
  String get showToken => '显示 Token';

  @override
  String get hideToken => '隐藏 Token';

  @override
  String get copyToken => '复制 Token';

  @override
  String get tokenCopied => 'Token 已复制到剪贴板';

  @override
  String get networkId => '网络ID';

  @override
  String get networkIdHint => '例如: 0000000000000000';

  @override
  String get timeZone => '时区';

  @override
  String get timeZoneHint => '例如: Asia/Shanghai, America/New_York';

  @override
  String get language => '语言';

  @override
  String get saveConfig => '保存配置';

  @override
  String get configSaved => '配置已保存';

  @override
  String get configHelp => '配置说明:';

  @override
  String get configHelp1 =>
      '1. 登录 ZeroTier One Central (https://my.zerotier.com)';

  @override
  String get configHelp2 => '2. 在 Networks 页面找到您的网络ID';

  @override
  String get configHelp3 => '3. 在 Settings > API 生成 API Token';

  @override
  String version(Object version) {
    return '版本: $version';
  }

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get deviceDetail => '设备详情';

  @override
  String loadDeviceDetailFailed(Object error) {
    return '加载设备详情失败: $error';
  }

  @override
  String get basicInfo => '基本信息';

  @override
  String get memberId => '成员ID';

  @override
  String get deviceName => '设备名称';

  @override
  String get description => '描述';

  @override
  String get status => '状态';

  @override
  String get lastOnlineTime => '最后在线时间';

  @override
  String get lastOnline => '最后在线';

  @override
  String get networkInfo => '网络信息';

  @override
  String get ipAddress => 'IP地址';

  @override
  String get publicIp => '公网IP';

  @override
  String get ipAssignments => 'IP Assignments';

  @override
  String get unassigned => '未分配';

  @override
  String get authorized => '已授权';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get managementSwitches => '管理开关';

  @override
  String get hiddenMember => '隐藏成员';

  @override
  String get disableAutoAssignIp => '禁止自动分配 IP';

  @override
  String get activeBridge => '活动桥接';

  @override
  String get ssoExempt => 'SSO 豁免';

  @override
  String get technicalInfo => '技术信息';

  @override
  String get nodeId => '节点ID';

  @override
  String get deviceId => '设备ID';

  @override
  String get clientVersion => '客户端版本';

  @override
  String get unknown => '未知';

  @override
  String get memberActions => '成员操作';

  @override
  String get editMember => '编辑成员';

  @override
  String get deleteMember => '删除成员';

  @override
  String get missingTokenOrNetwork => '缺少 API Token 或 Network ID 配置';

  @override
  String get updateSuccess => '成员信息已更新';

  @override
  String get updateFailed => '更新失败';

  @override
  String get deleteSuccess => '成员已删除';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get copyError => '复制错误';

  @override
  String get errorCopied => '错误信息已复制';

  @override
  String get neverOnline => '从未在线';

  @override
  String get justNowOnline => '刚刚在线';

  @override
  String minutesAgo(Object count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(Object count) {
    return '$count小时前';
  }

  @override
  String daysAgo(Object count) {
    return '$count天前';
  }

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get close => '关闭';

  @override
  String get name => '名称';

  @override
  String get memberEditTitle => '编辑成员';

  @override
  String get ipAssignmentsHint => '多个 IP 用逗号分隔';

  @override
  String get deleteMemberTitle => '删除成员';

  @override
  String get deleteMemberWarning => '该成员会从当前网络中删除。';

  @override
  String confirmDeleteMember(Object id) {
    return '请输入成员 ID 以确认: $id';
  }

  @override
  String get confirmMemberId => '确认成员 ID';

  @override
  String get adminTitle => 'ZeroTier One 管理';

  @override
  String adminLoadFailed(Object error) {
    return '加载管理信息失败: $error';
  }

  @override
  String get noAdminData => '没有可用的管理数据';

  @override
  String get centralStatus => 'Central 状态';

  @override
  String get centralVersion => 'Central 版本';

  @override
  String get apiVersion => 'API 版本';

  @override
  String get readOnlyMode => '只读模式';

  @override
  String get currentNetwork => '当前网络';

  @override
  String get networkNotConfigured => '当前未配置 Network ID，或该网络无法访问。';

  @override
  String get networkName => '名称';

  @override
  String get privateNetwork => '私有网络';

  @override
  String get defaultValue => '默认';

  @override
  String get broadcast => '广播';

  @override
  String get enabled => '已启用';

  @override
  String get disabled => '未启用';

  @override
  String get editNetwork => '编辑网络';

  @override
  String get createNetwork => '新建网络';

  @override
  String get accessibleNetworks => '可访问网络';

  @override
  String get noAccessibleNetworks => '当前账号下没有可访问网络';

  @override
  String get noDescription => '无描述';

  @override
  String get current => '当前';

  @override
  String get setCurrent => '设为当前';

  @override
  String switchedCurrentNetwork(Object id) {
    return '当前网络已切换为 $id';
  }

  @override
  String get currentUser => '当前用户';

  @override
  String get cannotFetchCurrentUser => '无法获取当前用户信息';

  @override
  String get userId => '用户 ID';

  @override
  String get displayName => '显示名称';

  @override
  String get email => '邮箱';

  @override
  String get orgId => '组织 ID';

  @override
  String get smsNumber => '短信号码';

  @override
  String get none => '无';

  @override
  String get unset => '未设置';

  @override
  String get editUser => '编辑用户';

  @override
  String get deleteUser => '删除用户';

  @override
  String get apiTokenManagement => 'API Token 管理';

  @override
  String get noVisibleApiToken => '当前用户还没有可见的 API Token 记录';

  @override
  String get deleteToken => '删除 Token';

  @override
  String get addApiToken => '添加 API Token';

  @override
  String get networkNameLabel => '网络名称';

  @override
  String get rulesSource => 'Rules Source';

  @override
  String get allowBroadcast => '允许广播';

  @override
  String get setCurrentAfterCreate => '创建后设为当前网络';

  @override
  String get create => '创建';

  @override
  String networkCreated(Object id) {
    return '网络已创建: $id';
  }

  @override
  String get userUpdated => '用户信息已更新';

  @override
  String get deleteUserTitle => '删除用户';

  @override
  String get deleteUserWarning => '该操作会删除用户及其关联网络，无法撤销。';

  @override
  String confirmDeleteUser(Object id) {
    return '请输入用户 ID 以确认删除: $id';
  }

  @override
  String get confirmUserId => '确认用户 ID';

  @override
  String get deleteUserButton => '删除用户';

  @override
  String get userDeleted => '用户已删除';

  @override
  String get tokenName => 'Token 名称';

  @override
  String get tokenValue => 'Token 值';

  @override
  String get generateRandomToken => '生成随机 Token';

  @override
  String get add => '添加';

  @override
  String get tokenNameValueRequired => 'Token 名称和 Token 值都不能为空';

  @override
  String get apiTokenAdded => 'API Token 已添加';

  @override
  String get deleteApiTokenTitle => '删除 API Token';

  @override
  String confirmDeleteToken(Object name) {
    return '确认删除 Token: $name ?';
  }

  @override
  String get delete => '删除';

  @override
  String tokenDeleted(Object name) {
    return 'Token $name 已删除';
  }
}
