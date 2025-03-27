import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:chat_application/src/pages/aptDetail_page.dart';

import 'src/pages/chat_page.dart';
import 'src/pages/chatlist_page.dart';
import 'src/pages/aptlist_page.dart';
import 'src/pages/home_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomePage(
        title: 'DDHOUSE 사용자 로그인',
      ),
    ),
    GoRoute(
      path: '/chatlist',
      builder: (BuildContext context, GoRouterState state) =>
          const ChatListPage(),
    ),
    GoRoute(
      path: '/chat',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final id = extra['id'] as int? ?? -1; // 채팅방 id || 매물 id
        final chatName = extra['name'] as String? ?? '알 수 없음';
        final from = extra['from'] as String? ?? '경로 없음';
        return ChatPage(
          id: id,
          chatName: chatName,
          from: from,
        );
      },
    ),
    GoRoute(
      path: '/aptlist',
      builder: (BuildContext context, GoRouterState state) => const AptListPage(
        title: 'DDHOUSE 매물리스트',
      ),
    ),
    GoRoute(
        path: '/aptDetail',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final aptId = extra['aptId'] as int? ?? -1;
          final aptName = extra['aptName'] as String? ?? '알 수 없음';
          return AptDetailPage(
            aptId: aptId,
            aptName: aptName,
          );
        }),
  ],
);

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
      routerConfig: _router,
    );
  }
}
