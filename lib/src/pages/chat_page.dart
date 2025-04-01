import 'dart:convert';
import 'dart:developer';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/src/providers/chatMessage_provider.dart';
import 'package:provider/provider.dart';

import 'package:chat_application/src/component/chatPage/chatBoxComponent.dart';
import 'package:chat_application/src/component/chatPage/chatInputField.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:chat_application/model/model_message.dart';
import '../../apis/chatApi.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.id,
      required this.chatName,
      required this.from});
  final int id; // 매물 id이거나 roomId이거나
  final String chatName;
  final String from;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController chatInputScrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();
  final TextEditingController messageController = TextEditingController();
  // late StompClient stompClient;
  bool isBtActive = false;
  int? myId;
  String? myName;
  Future<void> _loadMyIdAndMyName() async {
    myId = await SharedPreferencesHelper.getMyId();
    myName = await SharedPreferencesHelper.getMyName();
  }

  int? roomId;
  late List<Message> messages;

  late StompClient stompClient;
  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        // url: 'ws://localhost:8080/ws-stomp',
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: (StompFrame frame) {
          log('Connected to WebSocket');
          if (roomId != null) {
            // 메시지 구독
            stompClient.subscribe(
              destination: '/topic/chatroom/$roomId',
              callback: (StompFrame frame) {
                if (frame.body != null) {
                  log("Received: type of ${frame.body}");
                  setState(() {
                    final parsedMessage =
                        jsonDecode(frame.body!) as Map<String, dynamic>;
                    final receivedChat = Message.fromJson(parsedMessage);
                    messages.add(receivedChat);
                    // sqlite에 저장
                    Provider.of<ChatmessageProvider>(context, listen: false)
                        .addChatMessages(receivedChat);
                  });
                  moveScroll(chatInputScrollController);
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

  Future<void> fetchChatsData() async {
    await _loadMyIdAndMyName();
    var messageList = [];
    if (widget.from == 'chatlist') {
      roomId = widget.id;
      // TODO : 타입 통일 -> Provider로 가져온 것은 에러뜸!!!
      try {
        messageList = await fetchChatsByRoom(roomId!, context); // List 형태
      } catch (e) {
        // sqlite에서 데이터 가져오기
        messageList =
            await Provider.of<ChatmessageProvider>(context, listen: false)
                .loadChatMessages(roomId!);
        log('Error loading chat rooms: $e');
      }
    } else {
      messageList = await fetchChatsByApt(myId!, widget.id);
      roomId = (messageList[0]['roomId']);
    }
    connect(); // 웹소켓 연결
    if (messageList[0]['id'] != null) {
      setState(() {
        messages =
            messageList.map<Message>((json) => Message.fromJson(json)).toList();
      });
      moveScroll(chatInputScrollController);
    } else {
      // 처음 방 생성
      if (roomId != null) {
        final newChatRoom = ChatRoom(
          id: roomId!,
          name: messageList[0]['roomName'],
          lastmsg: '',
          dateTime: DateTime.parse(messageList[0]['regDate']),
          num: messageList[0]['memberNum'],
        );
        // sqlite에 저장
        Provider.of<ChatRoomProvider>(context, listen: false)
            .addChatRoom(newChatRoom);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChatsData();
    messageController.addListener(() {
      final isBtActive = messageController.text.isNotEmpty;
      setState(() {
        this.isBtActive = isBtActive;
      });
    });
    messages = [];
  }

  @override
  void dispose() {
    messageController.dispose();
    chatInputScrollController.dispose();
    messageFocusNode.dispose();
    stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.chatName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // <-- 가상 키보드 숨기기
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                shrinkWrap: true,
                controller: chatInputScrollController,
                itemBuilder: (context, index) => Align(
                  alignment: Alignment.centerLeft,
                  child: ChatBox(
                    myId: myId!,
                    writerId: messages[index].writerId,
                    writerName: messages[index].name,
                    message: messages[index].message,
                    createTime: messages[index].createTime,
                  ),
                ),
                itemCount: messages.length,
              ),
            ),
          ),
          const Divider(height: 1.0),
          Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputField(
              messageController: messageController,
              messageFocusNode: messageFocusNode,
              onSendMessage: _sendMessage,
              onChanged: (value) {
                setState(() {
                  isBtActive = value.trim().isNotEmpty;
                });
              },
              isBtActive: isBtActive,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String message = messageController.text;
    if (message.isNotEmpty) {
      log("roomId저장하는 Id 확인: $roomId");
      final messageData = {
        'roomId': roomId,
        'msg': message,
        'writerId': myId,
        'writerName': myName,
        'createdDate':
            DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now()),
      };
      stompClient.send(
        destination: '/app/message',
        body: jsonEncode(messageData),
      );
      log("전송된 메시지: 내아이디 : $myId, 내이름 : $myName, 채팅방 아이디 : $roomId, 메시지 : $message, 시간: ${DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now())} ");

      messageController.clear();
      setState(() {
        isBtActive = false;
      });
      messageFocusNode.requestFocus();
    }
  }

  void moveScroll(ScrollController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
