import 'dart:developer';

import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'apis/chatApi.dart';
import 'model/model_chatroom.dart';
import './src/format/formatDate.dart';

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
    await _loadMyId();
    try {
      final chatRooms = await fetchChatRooms(myId!);
      setState(() {
        _data = chatRooms;
      });
    } catch (e) {
      log('Error loading chat rooms: $e');
    }
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

  int _clickedIndex = -1;
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
              return InkWell(
                onTap: () {
                  setState(() {
                    _clickedIndex = index;
                  });
                  context.push('/chat', extra: {
                    'id': chat.id,
                    'name': chat.name,
                    'from': 'chatlist'
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: _clickedIndex == index
                        ? Colors.grey.shade300 // 클릭 시 색상 변경
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: chat.num > 2
                            ? const Icon(Icons.group)
                            : const Icon(Icons.person),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  chat.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  formatDate(chat.dateTime),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 83, 83, 83),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat.lastmsg,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
