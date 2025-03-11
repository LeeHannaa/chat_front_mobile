import 'dart:developer';

import 'package:chat_application/model/model_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatId, required this.chatName});
  final int chatId;
  final String chatName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController chatInputScrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  bool isBtActive = false;
  // TODO : 나의 userId를 저장시키고 message의 userId와 비교해서 ui 설계
  int myId = 1;

  // TODO : 채팅방 내 채팅 내용들 우선 더미데이터 사용 -> DB에서 가져오기
  final List<Message> allMessages = [
    Message(
      id: 1,
      name: "장성동",
      userId: 1,
      message: "매물 문의드립니다.",
      roomId: 1,
      createTime: "2025-03-11 14:30:00",
    ),
    Message(
      id: 2,
      name: "안녕부동산",
      userId: 2,
      message: "안녕하세요~ 안녕부동산입니다. 어떤 궁금한 점이 있으신가요?",
      roomId: 1,
      createTime: "2025-03-11 14:32:00",
    ),
    Message(
      id: 3,
      name: "장성동",
      userId: 1,
      message: "가격 조정이 가능한가요?",
      roomId: 1,
      createTime: "2025-03-11 14:35:00",
    ),
    Message(
      id: 4,
      name: "감자",
      userId: 3,
      message: "채팅방 2의 첫 번째 메시지",
      roomId: 2,
      createTime: "2025-03-11 14:40:00",
    ),
    Message(
      id: 5,
      name: "고구마",
      userId: 4,
      message: "채팅방 2의 두 번째 메시지",
      roomId: 2,
      createTime: "2025-03-11 14:42:00",
    ),
    Message(
      id: 6,
      name: "사과",
      userId: 5,
      message: "채팅방 3의 첫 번째 메시지",
      roomId: 3,
      createTime: "2025-03-11 14:45:00",
    ),
    Message(
      id: 7,
      name: "땅콩",
      userId: 6,
      message: "채팅방 3의 두 번째 메시지",
      roomId: 3,
      createTime: "2025-03-11 14:47:00",
    ),
  ];
  late List<Message> messages;

  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      final isBtActive = messageController.text.isNotEmpty;
      setState(() {
        this.isBtActive = isBtActive;
      });
    });
    messages = allMessages
        .where((message) => message.roomId == widget.chatId)
        .toList();
    if (messages.isEmpty) {
      messages = [];
    }
  }

  @override
  void dispose() {
    messageController.dispose();
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
                  child: Column(
                    children: [
                      messages[index].userId != myId
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
                        alignment: messages[index].userId != myId
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 300,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: messages[index].userId != myId
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
                                messages[index].createTime, // 메시지 시간
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

  void _sendMessage() {
    String message = messageController.text;
    if (message.isNotEmpty) {
      log("전송된 메시지: $message");
      messageController.clear();
      setState(() {
        isBtActive = false;
      });
    }
  }
}
