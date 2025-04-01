import 'dart:developer';

import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../apis/chatApi.dart';
import '../../model/model_chatroom.dart';
import '../component/chatListPage/roomBoxComponent.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ScrollController _scrollController = ScrollController();
  late List<ChatRoom> _data = [];
  // CHECK : 나의 id를 프론트에서 넘겨서 백엔드에서 비교 후 확인하기
  int? myId;
  // myId 불러오는 함수
  Future<void> _loadMyId() async {
    myId = await SharedPreferencesHelper.getMyId();
  }

  Future<void> _loadChatRooms() async {
    var chatRooms;
    await _loadMyId();
    try {
      chatRooms = await fetchChatRooms(myId!);
    } catch (e) {
      chatRooms = await Provider.of<ChatRoomProvider>(context, listen: false)
          .loadChatRooms();
      log('Error loading chat rooms: $e');
    }
    setState(() {
      _data = chatRooms;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
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
      body: Stack(
        children: <Widget>[
          // 리스트 뷰 생성
          ListView.builder(
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final chat = _data[index];
              return RoomBox(
                chatId: chat.id,
                chatName: chat.name,
                lastMsg: chat.lastmsg,
                index: index,
                chatNum: chat.num,
                createTime: chat.dateTime,
              );
            },
          ),
        ],
      ),
    );
  }
}
