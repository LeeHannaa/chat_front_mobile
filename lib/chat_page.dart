import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key, required this.chatId, required this.chatName});
  final int chatId;
  final String chatName;

  final ScrollController chatInputScrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();

  // TODO : 채팅방 내 채팅 내용들 우선 더미데이터 사용 -> DB에서 가져오기
  final Map<int, List<String>> chatMessages = {
    1: ["장성동 매물 문의드립니다.", "안녕하세요~ 안녕부동산입니다. 어떤 궁금한 점이 있으신가요?", "가격 조정이 가능한가요?"],
    2: ["채팅방 2의 첫 번째 메시지", "채팅방 2의 두 번째 메시지"],
    3: ["채팅방 3의 첫 번째 메시지", "채팅방 3의 두 번째 메시지"],
  };
  @override
  Widget build(BuildContext context) {
    final List<String> messages = chatMessages[chatId] ?? ["기본 메시지입니다."];

    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: index.isOdd
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.grey[300] : Colors.blue[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(messages[index]),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: TextFormField(
                                maxLines: 4,
                                minLines: 1,
                                onChanged: (value) {},
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
                          onTap: () {},
                          child: const Icon(
                            Icons.send,
                            color: Color.fromARGB(255, 43, 145, 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
