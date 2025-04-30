import 'dart:convert';

import 'package:chat_application/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 알림 플러그인 인스턴스 생성
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initLocalNotification() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        final roomId = data['roomId'];
        final roomName = data['roomName'];

        router.push('/chat', extra: {
          'id': int.parse(roomId),
          'name': roomName,
          'from': 'chatlist',
        });
      } else {
        router.push('/note');
      }
    },
  );
}

void showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'ddhouse-chat',
    'DDHOUSE',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  final payload = jsonEncode({
    'roomId': message.data['roomId'],
    'roomName': message.data['roomName'],
  });

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
    payload: payload,
  );
}
