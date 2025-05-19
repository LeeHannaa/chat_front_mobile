import 'package:chat_application/main.dart';
import 'package:chat_application/src/pages/aptDetail_page.dart';
import 'package:chat_application/src/pages/aptlist_page.dart';
import 'package:chat_application/src/pages/chat_page.dart';
import 'package:chat_application/src/pages/chatlist_page.dart';
import 'package:chat_application/src/pages/home_page.dart';
import 'package:chat_application/src/pages/note_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  navigatorKey: navigatorKey,
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
        final myId = extra['myId'] as int? ?? -1;
        final chatName = extra['name'] as String? ?? '알 수 없음';
        final from = extra['from'] as String? ?? '경로 없음';
        return ChatPage(
          id: id,
          myId: myId,
          chatName: chatName,
          from: from,
        );
      },
    ),
    GoRoute(
      path: '/note',
      builder: (BuildContext context, GoRouterState state) => const NotePage(),
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
