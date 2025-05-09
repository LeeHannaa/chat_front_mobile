import 'dart:developer';
import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:chat_application/src/services/websocket_service.dart';
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

class _ChatListPageState extends State<ChatListPage> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  late List<ChatRoom> _data = [];
  // CHECK : 나의 id를 프론트에서 넘겨서 백엔드에서 비교 후 확인하기
  int? myId;
  // myId 불러오는 함수
  Future<void> _loadMyId() async {
    myId = await SharedPreferencesHelper.getMyId();
  }

  Future<void> _loadChatRooms() async {
    List<ChatRoom> chatRooms;
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

  final WebSocketService _socketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _loadChatRooms(); // 채팅방 목록 불러오기
    _socketService.setMessageHandler((message) {
      //
      if (message['type'] == 'CHATLIST') {
        setState(() {
          int index = _data
              .indexWhere((chat) => chat.id == message['message']['roomId']);
          // 채팅방이 업데이트 된 경우
          if (index != -1) {
            _data[index] = _data[index].copyWith(
                lastmsg: message['message']['lastmsg'],
                updateLastMsgTime:
                    DateTime.parse(message['message']['updateLastMsgTime']),
                unreadCount: message['message']['unreadCount']);
          } else {
            // 새로운 채팅방 추가
            _data.add(ChatRoom(
              id: message['message']['roomId'],
              name: message['message']['name'],
              lastmsg: message['message']['lastmsg'],
              num: message['message']['memberNum'] ?? 2,
              updateLastMsgTime:
                  DateTime.parse(message['message']['updateLastMsgTime']),
              unreadCount: message['message']['unreadCount'],
            ));
          }
          _data = List.from(_data)
            ..sort(
                (a, b) => b.updateLastMsgTime.compareTo(a.updateLastMsgTime));
        });
      }
    });
  }

  bool isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool refreshTrigger = false;
  @override
  void didPopNext() {
    // 이게 핵심!
    setState(() {
      refreshTrigger = !refreshTrigger;
    });
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
              // TODO : 여기서 터치이벤트 처리
              // 제스처디렉터
              return RoomBox(
                key: ValueKey(chat.updateLastMsgTime),
                loadChatRooms: _loadChatRooms,
                chatRoomId: chat.id,
                chatName: chat.name,
                lastMsg: chat.lastmsg,
                chatNum: chat.num,
                updateLastMsgTime: chat.updateLastMsgTime,
                unreadCount: chat.unreadCount,
              );
            },
          ),
        ],
      ),
    );
  }
}
