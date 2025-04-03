import 'dart:convert';
import 'dart:developer';

import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

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

  late StompClient stompClient;
  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        // url: 'ws://localhost:8080/ws-stomp',
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: (StompFrame frame) {
          log('Connected to WebSocket');
          if (myId != null) {
            // 메시지 구독
            stompClient.subscribe(
              destination: '/topic/chatlist/$myId', // 받는 사람이 myId인 경우 구독
              callback: (StompFrame frame) {
                if (frame.body != null) {
                  final parsedData =
                      jsonDecode(frame.body!) as Map<String, dynamic>;
                  log("새로운 채팅 목록 업데이트 데이터: $parsedData");

                  setState(() {
                    int index = _data
                        .indexWhere((chat) => chat.id == parsedData['roomId']);
                    if (index != -1) {
                      _data[index] = _data[index].copyWith(
                        lastmsg: parsedData['msg'],
                        updateLastMsgTime:
                            DateTime.parse(parsedData['updateLastMsgTime']),
                      );
                    }
                    _data = List.from(_data)
                      ..sort((a, b) =>
                          b.updateLastMsgTime.compareTo(a.updateLastMsgTime));
                  });
                }
              },
            );
          }
        },
        onWebSocketError: (dynamic error) => log('WebSocket Error: $error'),
        onDisconnect: (StompFrame frame) => log('Disconnected'),
      ),
    );

    // WebSocket 연결 시작
    stompClient.activate();
  }

  void disconnect() {
    stompClient.deactivate();
  }

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    connect();
  }

  bool isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    disconnect();
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
                key: ValueKey(chat.updateLastMsgTime),
                chatRoomId: chat.id,
                chatName: chat.name,
                lastMsg: chat.lastmsg,
                chatNum: chat.num,
                createTime: chat.dateTime,
                updateLastMsgTime: chat.updateLastMsgTime,
              );
            },
          ),
        ],
      ),
    );
  }
}
