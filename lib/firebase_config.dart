import 'package:chat_application/apis/userApi.dart';
import 'package:chat_application/fcmAlram.dart';
import 'package:chat_application/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// FCM 토큰 요청 함수
Future<void> requestForToken(int? myId) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // 알림 권한 요청 (iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        print('FCM Token: $fcmToken');
        if (myId != null) {
          await sendFcmToken(myId, fcmToken);
        } else {
          print("⚠️ 사용자 ID가 없습니다. 먼저 ID를 받아오세요.");
        }
      } else {
        print('토큰을 가져올 수 없습니다.');
      }
    } else {
      print('알림 권한이 거부되었습니다.');
    }
  } catch (e) {
    print('FCM 토큰 요청 중 오류 발생: $e');
  }
}

// 메시지 리스너
void onMessageListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // print(
    //     'FCM 메시지 수신: ${message.notification?.title} - ${message.notification?.body}');
    showLocalNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // print('사용자가 알림을 클릭하여 앱을 열었습니다: ${message.notification?.title}');
    final roomId = message.data['roomId'];
    final roomName = message.data['roomName'];
    // print("알림 받은 데이터에서 roomId랑 roomName 확인!! : $roomId, $roomName");
    if (roomId != null) {
      router.push('/chat', extra: {
        'id': int.parse(roomId),
        'name': roomName,
        'from': 'chatlist'
      });
    }
  });
}

// 백그라운드 메시지 알림 처리
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('백그라운드에서 메시지 수신: ${message.messageId}');
}
