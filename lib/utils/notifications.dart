import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );
  
  await notificationsPlugin.initialize(
    settings: initializationSettings,
  );
}

Future<void> showUpdateNotification(BuildContext context, String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'zerotier_channel',
    'ZeroTier Updates',
    channelDescription: 'ZeroTier device status updates',
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
    title: 'ZeroTier 状态更新',
    body: body,
    notificationDetails: platformChannelSpecifics,
  );
}
