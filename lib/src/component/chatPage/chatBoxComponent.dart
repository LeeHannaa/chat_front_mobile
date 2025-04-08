import 'package:flutter/material.dart';

import '../../format/formatDate.dart';

class ChatBox extends StatefulWidget {
  final int myId;
  final int writerId;
  final String writerName;
  final String message;
  final DateTime createTime;
  final bool isRead;
  final bool userInRoom;

  const ChatBox({
    Key? key,
    required this.myId,
    required this.writerId,
    required this.writerName,
    required this.message,
    required this.createTime,
    required this.isRead, // 제일 처음 입장했을 때 상대가 안읽은 메시지 수
    required this.userInRoom, // 현재 방에 접속자 발생 여부
  }) : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.writerId != widget.myId
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
                    widget.writerName, // 메시지를 보낸 사람
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : const Row(),
        Align(
          alignment: widget.writerId != widget.myId
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.writerId != widget.myId
                  ? const Color.fromARGB(255, 218, 232, 217)
                  : const Color.fromARGB(255, 239, 243, 226), // 메시지 박스 배경 색
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4), // 이름과 메시지 간의 간격
                Text(
                  widget.message, // 메시지 내용
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8), // 메시지와 시간 간의 간격
                Text(
                  formatDate(widget.createTime), // 메시지 시간
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 79, 79, 79),
                  ),
                ),
                widget.myId == widget.writerId
                    ? widget.userInRoom
                        ? const Text(
                            "읽음",
                            style: TextStyle(
                              fontSize: 8,
                              color: Color.fromARGB(255, 134, 134, 134),
                            ),
                          )
                        : Text(
                            widget.isRead ? "읽음" : "안읽음",
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color.fromARGB(255, 134, 134, 134),
                            ),
                          )
                    : const SizedBox(height: 0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
