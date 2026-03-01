import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
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
  
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  
  await notificationsPlugin.show(
    id: 0,
    title: 'ZeroTier 状态更新',
    body: message,
    notificationDetails: platformChannelSpecifics,
  );
}