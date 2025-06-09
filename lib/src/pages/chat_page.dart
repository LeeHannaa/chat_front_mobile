import 'dart:developer' as developer;
import 'package:chat_application/model/model_sendMsg.dart';
import 'package:chat_application/src/providers/chat_message_provider.dart';
import 'package:chat_application/src/providers/sqflite/chatroom_sqflite_provider.dart';
import 'package:chat_application/src/services/websocket_service.dart';
import 'package:chat_application/utils/moveScroll.dart';
import 'package:provider/provider.dart';
import 'package:chat_application/src/component/chatPage/chatBoxComponent.dart';
import 'package:chat_application/src/component/chatPage/chatInputField.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:chat_application/model/model_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.id,
      this.myId,
      required this.chatName,
      required this.from});
  final int id; // 매물 id이거나 roomId이거나
  final int? myId;
  final String chatName;
  final String from;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController chatInputScrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();
  final TextEditingController messageController = TextEditingController();
  final WebSocketService _socketService = WebSocketService();

  // late StompClient stompClient;
  bool isBtActive = false;
  late int myId = widget.myId ?? -1;

  String? myName;

  Future<void> _loadMyIdAndMyName() async {
    if (myId < 0) {
      myId = await SharedPreferencesHelper.getMyId();
    }
    myName = await SharedPreferencesHelper.getMyName();
  }

  Future<void> _initializeChat() async {
    await _loadMyIdAndMyName();
    developer.log("이름들 가져오기 성공");
    // 소켓 구독 경로 추가 포함
    final chatMessageProvider =
        Provider.of<ChatMessageProvider>(context, listen: false);
    chatMessageProvider.loadChatMessages(
      myId,
      widget.id,
      context,
      chatInputScrollController,
    );
    chatRoomId = chatMessageProvider.roomId;
    _socketService.setMessageHandler((message) {
      chatMessageProvider.handleSocketMessage(message, context);
      // 메시지가 화면에 추가된 후 스크롤 이동
      moveScroll(chatInputScrollController);
    });
  }

  late StompClient stompClient;
  int chatRoomId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat(); // context 안전하게 사용
    });
    messageController.addListener(() {
      final isBtActive = messageController.text.isNotEmpty;
      setState(() {
        this.isBtActive = isBtActive;
      });
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    chatInputScrollController.dispose();
    messageFocusNode.dispose();
    WebSocketService().unsubscribeFromChatRoom(chatRoomId, myId);
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
                // sqflite에서 lastmsg 데이터 업뎃
                await Provider.of<ChatRoomSqfliteProvider>(context,
                        listen: false)
                    .updateLastMessages();
                Navigator.pop(context, true);
              }),
        ),
        body:
            Consumer<ChatMessageProvider>(builder: (context, provider, child) {
          final chatMessages = provider.chatmessages;
          final hiddenBtId = provider.hiddenBtId;
          return Column(
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
                      final message = chatMessages[index];
                      return GestureDetector(
                        onLongPress: () => myId == message.writerId
                            ? _showDeleteOptions(context, message, provider)
                            : (),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ChatBox(
                              myId: myId,
                              roomId: provider.roomId,
                              chatmessage: message,
                              hiddenBtId: hiddenBtId),
                        ),
                      );
                    },
                    itemCount: chatMessages.length,
                  ),
                ),
              ),
              (chatMessages.isNotEmpty && chatMessages[0].writerId != null)
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: ChatInputField(
                        messageController: messageController,
                        messageFocusNode: messageFocusNode,
                        onSendMessage: () => _sendMessage(provider.roomId),
                        onChanged: (value) {
                          setState(() {
                            isBtActive = value.trim().isNotEmpty;
                          });
                        },
                        isBtActive: isBtActive,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }));
  }

  void _sendMessage(int roomId) async {
    String message = messageController.text;
    if (message.isNotEmpty) {
      developer.log("roomId저장하는 Id 확인: $roomId");
      final messageData = SendMessage(
        roomId: roomId,
        chatName: widget.chatName,
        msg: message,
        writerId: myId,
        writerName: myName!,
        regDate: DateTime.now().toIso8601String(),
      );
      _socketService.sendMessage(messageData);
      messageController.clear();
      setState(() {
        isBtActive = false;
      });
      messageFocusNode.requestFocus();
    }
  }

  void _showDeleteOptions(
      BuildContext context, Message message, ChatMessageProvider provider) {
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
                        provider.deleteForAll(message, myId, context); // API 연결
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
}
