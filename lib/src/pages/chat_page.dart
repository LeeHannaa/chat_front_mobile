import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:chat_application/apis/chatMessageApi.dart';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/src/providers/chatMessage_provider.dart';
import 'package:provider/provider.dart';
import 'package:chat_application/src/component/chatPage/chatBoxComponent.dart';
import 'package:chat_application/src/component/chatPage/chatInputField.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:flutter/material.dart';
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
  int? unreadCountByMe; // 제일 처음 입장했을 때 내가 안읽은 메시지 수
  late List<Message> messages;
  Set<String> hiddenBtId = Set<String>();

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
          developer.log('Connected to WebSocket');
          if (roomId != null) {
            // 메시지 구독
            stompClient.subscribe(
              destination: '/topic/chatroom/$roomId',
              callback: (StompFrame frame) {
                final data = jsonDecode(frame.body!);
                developer.log("Received: type of $data");
                if (data['type'] == 'CHAT') {
                  // 일반 채팅 메시지 처리
                  final messagePayload = data['message'];
                  if (messagePayload is Map<String, dynamic>) {
                    setState(() {
                      final receivedChat = Message.fromJson(messagePayload);
                      messages.add(receivedChat);
                      // sqlite에 저장
                      Provider.of<ChatmessageProvider>(context, listen: false)
                          .addChatMessages(receivedChat);
                    });
                  } else {
                    developer.log(
                        "❌ message가 Map이 아님: ${messagePayload.runtimeType}");
                  }
                  moveScroll(chatInputScrollController);
                } else if (data['type'] == 'INFO') {
                  // 누가 들어왔다는 알림 메시지 처리
                  developer.log("상대방 입장!!!!!!!, 읽음처리해야할 메시지 개수 : ");
                  int changeNumber = int.parse(data['message'].toString());
                  developer.log(data['message'].toString());
                  setState(() {
                    for (int i = messages.length - 1;
                        i > max(0, messages.length - changeNumber - 1);
                        i--) {
                      if (messages[i].type == 'TEXT') {
                        if (messages[i].unreadCount == 0) break;
                        messages[i].unreadCount =
                            (messages[i].unreadCount ?? 1) - 1;
                      }
                    }
                  });
                } else if (data['type'] == 'OUT') {
                  // 누가 나갔다는 알림 메시지 처리
                  if (data['message'] == "상대방 퇴장") {
                    developer.log("상대방 퇴장!!!!!!!");
                  }
                } else if (data['type'] == 'DELETE') {
                  // 메시지가 삭제되었다!!
                  String deleteMsgId = data['messageId'];
                  developer.log("특정 메시지 삭제!! $deleteMsgId");
                  setState(() {
                    int index = messages
                        .indexWhere((message) => message.id == deleteMsgId);
                    if (index != -1) {
                      // messages[index].message = "삭제된 메시지입니다.";
                      messages.removeAt(index);
                      messages[index].delete = true;
                    }
                  });
                } else if (data['type'] == 'LEAVE') {
                  // 유저가 채팅방을 나간 경우 실시간 알림 전달
                  final messagePayload = data['message'];
                  // 유저가 안읽은 메시지가 존재한 채 채팅방을 나간 경우
                  int changeNumber =
                      int.parse(data['msgToReadCount'].toString());
                  developer.log(data['message'].toString());
                  setState(() {
                    for (int i = messages.length - 1;
                        i > max(0, messages.length - changeNumber - 1);
                        i--) {
                      if (messages[i].type == 'TEXT') {
                        if (messages[i].unreadCount == 0) break;
                        messages[i].unreadCount =
                            (messages[i].unreadCount ?? 1) - 1;
                      }
                    }
                  });
                  if (messagePayload is Map<String, dynamic>) {
                    setState(() {
                      final receivedChat = Message.fromJson(messagePayload);
                      messages.add(receivedChat);
                      // sqlite에 저장
                      Provider.of<ChatmessageProvider>(context, listen: false)
                          .addChatMessages(receivedChat);
                    });
                  } else {
                    developer.log(
                        "❌ message가 Map이 아님: ${messagePayload.runtimeType}");
                  }
                  moveScroll(chatInputScrollController);
                } else if (data['type'] == 'INVITE') {
                  // 일반 채팅 메시지 처리
                  final messagePayload = data['message'];
                  if (messagePayload is Map<String, dynamic>) {
                    setState(() {
                      final receivedChat = Message.fromJson(messagePayload);
                      messages.add(receivedChat);
                      setState(() {
                        if (receivedChat.beforeMsgId != null) {
                          hiddenBtId.add(receivedChat.beforeMsgId!);
                        }
                      });
                      // sqlite에 저장
                      Provider.of<ChatmessageProvider>(context, listen: false)
                          .addChatMessages(receivedChat);
                    });
                  } else {
                    developer.log(
                        "❌ message가 Map이 아님: ${messagePayload.runtimeType}");
                  }
                  moveScroll(chatInputScrollController);
                }
              },
            );
          }
        },
        onWebSocketError: (dynamic error) =>
            developer.log('WebSocket Error: $error'),
        onDisconnect: (StompFrame frame) => developer.log('Disconnected'),
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
        developer.log('Error loading chat rooms: $e');
      }
    } else {
      messageList = await fetchChatsByApt(myId!, widget.id);
      roomId = (messageList[0]['roomId']);
    }

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
      // 내가 안읽은 메시지 수 가져오기
      unreadCountByMe = await fetchUnreadCountByRoom(roomId!, myId!);
      setState(() {
        for (int i = messages.length - 1;
            i > messages.length - unreadCountByMe! - 1;
            i--) {
          if (messages[i].unreadCount == 0) break;
          messages[i].unreadCount = (messages[i].unreadCount ?? 1) - 1;
        }
      });
      moveScroll(chatInputScrollController);
    } else {
      // 처음 방 생성
      if (roomId != null) {
        final newChatRoom = ChatRoom(
          id: roomId!,
          name: messageList[0]['roomName'],
          lastmsg: '',
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
                    onLongPress: () => myId == message.writerId
                        ? _showDeleteOptions(context, message)
                        : (),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ChatBox(
                          myId: myId!,
                          writerId: message.writerId,
                          writerName: message.name,
                          message: message.message ?? '',
                          type: message.type ?? '',
                          createTime: message.createTime,
                          unreadCount: message.unreadCount ?? 0,
                          delete: message.delete ?? false,
                          roomId: roomId!,
                          msgId: message.id,
                          hiddenBtId: hiddenBtId),
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
      developer.log("roomId저장하는 Id 확인: $roomId");
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
      developer.log(
          "전송된 메시지: 내아이디 : $myId, 내이름 : $myName, 채팅방 아이디 : $roomId, 채팅방 이름 : ${widget.chatName}, 메시지 : $message, 시간: ${DateTime.now().toIso8601String()}");

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
              const ListTile(
                  // leading: const Icon(Icons.delete_outline),
                  // title: const Text("이 기기에서 삭제"),
                  // onTap: () {
                  //   Navigator.pop(context); // 닫고
                  //   _deleteForMe(message, myId!); // API 연결
                  // },
                  ),
              message.writerId == myId && !message.delete!
                  // && isWithin5Minutes(message.createTime)
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

  // bool isWithin5Minutes(DateTime chatTime) {
  //   final now = DateTime.now();
  //   final difference = now.difference(chatTime);
  //   return difference.inMinutes < 5;
  // }

  // void _deleteForMe(Message message, int myId) async {
  //   await deleteChatMessageToMe(message.id, myId);
  //   setState(() {
  //     messages.remove(message);
  //   });
  // }

  void _deleteForAll(Message message, int myId) async {
    await deleteChatMessageToAll(message.id, myId);
    setState(() {
      final index = messages.indexOf(message);
      if (index != -1) {
        // messages[index] = message.copyWith(message: "삭제된 메시지입니다.", delete: true);
        messages.removeAt(index);
      }
    });
  }
}
