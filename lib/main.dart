import 'package:chat_application/apt_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'chat_page.dart';
import 'chatlist_page.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomePage(
        title: 'DDHOUSE',
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
        final chatId = extra['id'] as int? ?? -1;
        final chatName = extra['name'] as String? ?? '알 수 없음';
        return ChatPage(
          chatId: chatId,
          chatName: chatName,
        );
      },
    ),
    GoRoute(
      path: '/apt',
      builder: (BuildContext context, GoRouterState state) => const AptPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
