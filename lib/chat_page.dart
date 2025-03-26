import 'dart:convert';
import 'dart:developer';

import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:chat_application/model/model_message.dart';

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
        url: 'ws://localhost:8080/ws-stomp',
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

  // 채팅 방 id를 넘기는 api
  Future<void> fetchData() async {
    String apiUrl;
    await _loadMyIdAndMyName();
    if (widget.from == 'chatlist') {
      log("chatlist에서 옴!!! roomId : ${widget.id}");
      roomId = widget.id;
      apiUrl =
          'http://localhost:8080/chatmsg/find/list/${widget.id}'; // 채팅 방 id 전달
    } else {
      log("apt에서 옴!!! aptId : ${widget.id}");
      apiUrl =
          'http://localhost:8080/chatmsg/apt/find/list/${widget.id}?myId=$myId'; // 매물 id 전달
    }
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // JSON 형식의 응답을 Dart 객체로 변환하여 데이터 리스트에 저장
      var decodedResponse = json.decode(response.body);
      var messageList = decodedResponse[0]['body'] as List;

      if (roomId == null) {
        roomId = (messageList[0]['roomId']);
      } else {
        setState(() {
          messages = messageList
              .map<Message>((json) => Message.fromJson(json))
              .toList();
        });
        moveScroll(chatInputScrollController);
      }
      connect(); // 웹소켓 연결

      log(response.body);
    } else {
      log('Failed to load data: ${response.statusCode}');
    }
  }

  String _formatDate(DateTime dateTime) {
    final today = DateTime.now();
    final isSameDay = dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day;
    final isYesterday = dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day + 1 == today.day;

    if (isSameDay) {
      // 오늘 날짜와 동일하면 시간만 출력
      return DateFormat('HH:mm').format(dateTime);
    } else if (isYesterday) {
      return '어제';
    } else {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
    super.dispose();
  }

  void moveScroll(ScrollController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 80), // 부드러운 스크롤
          curve: Curves.easeOut,
        );
      }
    });
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
                  child: Column(
                    children: [
                      messages[index].writerId != myId
                          ? Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18, // 동그라미 아이콘 크기 조정
                                  backgroundColor: Colors.blue, // 아이콘 배경색
                                  child: Icon(
                                    Icons.person, // 사람 아이콘
                                    color: Colors.white, // 아이콘 색상
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  messages[index].name, // 메시지를 보낸 사람
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : const Row(),
                      Align(
                        alignment: messages[index].writerId != myId
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 300,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: messages[index].writerId != myId
                                ? const Color.fromARGB(255, 218, 232, 217)
                                : const Color.fromARGB(
                                    255, 239, 243, 226), // 메시지 박스 배경 색
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4), // 이름과 메시지 간의 간격
                              Text(
                                messages[index].message, // 메시지 내용
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8), // 메시지와 시간 간의 간격
                              Text(
                                _formatDate(
                                    messages[index].createTime), // 메시지 시간
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                itemCount: messages.length,
              ),
            ),
          ),
          const Divider(height: 1.0),
          Align(
            alignment: Alignment.bottomCenter,
            child: _bottomInputField(),
          ),
        ],
      ),
    );
  }

  Widget _bottomInputField() {
    // 채팅 키보드 파트
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        controller: messageController,
                        focusNode: messageFocusNode,
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (value) => _sendMessage(),
                        maxLines: 4,
                        minLines: 1,
                        onChanged: (value) {
                          setState(() {
                            isBtActive =
                                value.trim().isNotEmpty; // 입력값 여부에 따라 버튼 활성화
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: '메세지 보내기',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // 버튼과 입력 칸 사이 여백
                GestureDetector(
                  onTap: isBtActive ? _sendMessage : null,
                  child: Icon(
                    Icons.send,
                    color: isBtActive
                        ? const Color.fromARGB(255, 26, 106, 6) // 활성(초록색)
                        : Colors.grey, // 비활성(회색)
                  ),
                ),
              ],
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
}
