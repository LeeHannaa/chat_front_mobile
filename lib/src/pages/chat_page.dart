import 'dart:convert';
import 'dart:developer';
import 'package:chat_application/apis/chatMessageApi.dart';
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
  int? unreadCount; // 제일 처음 입장했을 때 상대가 안읽은 메시지 수
  bool userInRoom = false;
  late List<Message> messages;

  late StompClient stompClient;
  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        // url: 'ws://localhost:8080/ws-stomp',
        url: 'ws://10.0.2.2:8080/ws-stomp',
        stompConnectHeaders: {
          'roomId': roomId!.toString(),
          'myId': myId!.toString(),
        },
        onConnect: (StompFrame frame) {
          log('Connected to WebSocket');
          if (roomId != null) {
            // 메시지 구독
            stompClient.subscribe(
              destination: '/topic/chatroom/$roomId',
              callback: (StompFrame frame) {
                final data = jsonDecode(frame.body!);
                log("Received: type of $data");
                if (data['type'] == 'CHAT') {
                  // 일반 채팅 메시지 처리
                  final messagePayload = data['message'];
                  if (messagePayload is Map<String, dynamic>) {
                    setState(() {
                      final receivedChat = Message.fromJson(messagePayload);

                      if (receivedChat.count! > 1) {
                        userInRoom = true;
                        receivedChat.isRead = true;
                      } else {
                        userInRoom = false;
                        receivedChat.isRead = false;
                      }
                      messages.add(receivedChat);

                      // sqlite에 저장
                      Provider.of<ChatmessageProvider>(context, listen: false)
                          .addChatMessages(receivedChat);
                    });
                  } else {
                    log("❌ message가 Map이 아님: ${messagePayload.runtimeType}");
                  }
                  moveScroll(chatInputScrollController);
                } else if (data['type'] == 'INFO') {
                  // 누가 들어왔다는 알림 메시지 처리
                  if (data['message'] == "상대방 입장") {
                    log("상대방 입장!!!!!!!");
                    setState(() {
                      userInRoom = true;
                      for (int i = messages.length - 1; i > 0; i--) {
                        if (messages[i].isRead == true) break;
                        messages[i].isRead = true;
                      }
                    });
                  }
                } else if (data['type'] == 'OUT') {
                  // 누가 나갔다는 알림 메시지 처리
                  if (data['message'] == "상대방 퇴장") {
                    log("상대방 퇴장!!!!!!!");
                    setState(() {
                      userInRoom = false;
                    });
                  }
                } else if (data['type'] == 'DELETE') {
                  // 메시지가 삭제되었다!!
                  String deleteMsgId = data['messageId'];
                  log("특정 메시지 삭제!! $deleteMsgId");
                  setState(() {
                    int index = messages
                        .indexWhere((message) => message.id == deleteMsgId);
                    if (index != -1) {
                      messages[index].message = "삭제된 메시지입니다.";
                      messages[index].isDelete = true;
                    }
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

  Future<void> fetchChatsData() async {
    await _loadMyIdAndMyName();
    var messageList = [];
    bool connectServer = true;
    if (widget.from == 'chatlist') {
      roomId = widget.id;
      try {
        messageList =
            await fetchChatsByRoom(roomId!, myId!, context); // List 형태
      } catch (e) {
        // sqlite에서 데이터 가져오기
        messageList =
            await Provider.of<ChatmessageProvider>(context, listen: false)
                .loadChatMessages(roomId!);
        connectServer = false;
        log('Error loading chat rooms: $e');
      }
    } else {
      messageList = await fetchChatsByApt(myId!, widget.id);
      roomId = (messageList[0]['roomId']);
    }
    // 상대방이 안읽은 메시지 수 가져오기
    unreadCount = await fetchUnreadCountByRoom(roomId!);
    connect(); // 웹소켓 연결
    if (messageList[0]['id'] != null) {
      setState(() {
        if (connectServer) {
          // api 연결로 받아온 경우
          messages = messageList
              .map<Message>((json) => Message.fromJson(json))
              .toList();
        } else {
          // 어플리케이션 내에 db에서 꺼내온 경우
          messages = messageList
              .map<Message>((json) => Message.fromJsonSqlite(json))
              .toList();
        }
      });
      for (int i = messages.length - 1;
          i >= messages.length - unreadCount!;
          i--) {
        messages[i].isRead = false; // 안읽음 표시
      }
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
          updateLastMsgTime:
              DateTime.parse(messageList[0]['updateLastMsgTime']),
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
    disconnect();
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
            onPressed: () async {
              // sqlite에서 lastmsg 데이터 업뎃
              Provider.of<ChatRoomProvider>(context, listen: false)
                  .updateLastMessages();
              Navigator.pop(context, true);
            }),
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
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return GestureDetector(
                    onLongPress: () => _showDeleteOptions(context, message),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ChatBox(
                        myId: myId!,
                        writerId: message.writerId,
                        writerName: message.name,
                        message: message.message ?? '',
                        createTime: message.createTime,
                        isRead: message.isRead ?? true,
                        userInRoom: userInRoom,
                      ),
                    ),
                  );
                },
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
        'chatName': widget.chatName,
        'msg': message,
        'writerId': myId,
        'writerName': myName,
        'regDate': DateTime.now().toIso8601String(),
      };
      stompClient.send(
        destination: '/app/message',
        body: jsonEncode(messageData),
      );
      log("전송된 메시지: 내아이디 : $myId, 내이름 : $myName, 채팅방 아이디 : $roomId, 채팅방 이름 : ${widget.chatName}, 메시지 : $message, 시간: ${DateTime.now().toIso8601String()}");

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

  void _showDeleteOptions(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("이 기기에서 삭제"),
                onTap: () {
                  Navigator.pop(context); // 닫고
                  _deleteForMe(message, myId!); // API 연결
                },
              ),
              message.writerId == myId && !message.isDelete!
                  ? ListTile(
                      leading: const Icon(Icons.delete_forever),
                      title: const Text("전체에게 삭제"),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteForAll(message, myId!); // API 연결
                      },
                    )
                  : const SizedBox()
            ],
          ),
        );
      },
    );
  }

  void _deleteForMe(Message message, int myId) async {
    await deleteChatMessageToMe(message.id, myId);
    setState(() {
      messages.remove(message);
    });
  }

  void _deleteForAll(Message message, int myId) async {
    await deleteChatMessageToAll(message.id, myId);
    setState(() {
      final index = messages.indexOf(message);
      if (index != -1) {
        messages[index] =
            message.copyWith(message: "삭제된 메시지입니다.", isDelete: true);
      }
    });
  }
}
