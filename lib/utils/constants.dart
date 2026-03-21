import 'package:flutter/material.dart';

class Constants {
  // API 基础URL
  static const String apiBaseUrl = 'https://api.zerotier.com/api/v1';
  
  // 默认网络ID
  static const String defaultNetworkId = '000000000000000';
  
  // 默认超时时间（秒）
  static const int apiTimeout = 15;
  
  // 应用名称
  static const String appName = 'ZeroTier One Management';
  
  // 本地数据库名称
  static const String databaseName = 'zerotier.db';
  
  // 设备在线判断时间阈值（毫秒），5分钟内在线
  static const int onlineThreshold = 5 * 60 * 1000;
  
  // 刷新间隔（分钟）
  // 颜色常量
  static Color onlineColor = Colors.green;
  static Color offlineColor = Colors.orange;
  static Color neverOnlineColor = Colors.grey;
  
  // 文本样式
  static TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );
  
  static TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  // 通知频道
  static const String notificationChannelId = 'zerotier_status';
  static const String notificationChannelName = 'ZeroTier One Status Updates';
  static const String notificationChannelDesc = 'ZeroTier One device status notifications';
  
  // 帮助链接
  static const String helpUrl = 'https://docs.zerotier.com';
  static const String apiTokenHelpUrl = 'https://my.zerotier.com/account';
}