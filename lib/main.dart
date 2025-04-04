import 'package:chat_application/fcmAlram.dart';
import 'package:chat_application/firebase_config.dart';
import 'package:chat_application/src/providers/chatMessage_provider.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';

import 'router.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initLocalNotification();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  onMessageListener();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatmessageProvider()),
        ChangeNotifierProvider(create: (_) => ChatRoomProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KFACE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 39, 126, 5)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
