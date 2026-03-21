import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void>? _notificationsInitFuture;

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: '打开通知');

  const WindowsInitializationSettings initializationSettingsWindows =
      WindowsInitializationSettings(
        appName: 'ZeroTier One Management',
        appUserModelId: 'com.example.zerotierapi',
        guid: '8f7de4dd-f7c7-4ac8-b598-9b9f6ca85ca8',
      );
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
    windows: initializationSettingsWindows,
  );

  try {
    await notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  } catch (_) {
    return;
  }
}

Future<void> ensureNotificationsInitialized() {
  return _notificationsInitFuture ??= initNotifications();
}

Future<void> showUpdateNotification(BuildContext context, String message) async {
  await ensureNotificationsInitialized();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'zerotier_channel',
    'ZeroTier One Updates',
    channelDescription: 'ZeroTier One device status updates',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    showWhen: false,
  );

  const DarwinNotificationDetails darwinPlatformChannelSpecifics =
      DarwinNotificationDetails();

  final sanitizedBody = message
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), ' ')
      .trim();
  final body = sanitizedBody.length > 240
      ? '${sanitizedBody.substring(0, 240)}...'
      : sanitizedBody;
  
  final NotificationDetails platformChannelSpecifics = kIsWeb
      ? const NotificationDetails()
      : const NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: darwinPlatformChannelSpecifics,
          macOS: darwinPlatformChannelSpecifics,
        );
  
  if (body.isEmpty) return;

  await notificationsPlugin.show(
    id: 0,
    title: 'ZeroTier One 状态更新',
    body: body,
    notificationDetails: platformChannelSpecifics,
  );
}
