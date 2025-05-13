import 'package:chat_application/src/providers/chatroom_provider.dart';
import 'package:chat_application/src/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../component/chatListPage/roomBoxComponent.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final WebSocketService _socketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    final chatRoomProvider =
        Provider.of<ChatRoomProvider>(context, listen: false);
    chatRoomProvider.loadChatRooms();
    _socketService.setMessageHandler((message) {
      chatRoomProvider.handleSocketMessage(message);
    });
  }

  bool isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('채팅방 목록'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Consumer<ChatRoomProvider>(builder: (context, provider, child) {
          final chatRooms = provider.chatRooms;
          return Stack(
            children: <Widget>[
              // 리스트 뷰 생성
              ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final chat = chatRooms[index];
                  return RoomBox(
                      key: ValueKey(chat.updateLastMsgTime),
                      chatroom: chat,
                      onTap: () async {
                        final result = await context.push('/chat', extra: {
                          'id': chat.id,
                          'name': chat.name,
                          'from': 'chatlist',
                        });
                        if (result == true) {
                          provider.loadChatRooms();
                        }
                      });
                },
              ),
            ],
          );
        }));
  }
}
