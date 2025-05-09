import 'dart:developer';
import 'package:chat_application/apis/chatApi.dart';
import 'package:flutter/material.dart';
import '../../format/formatDate.dart';

class ChatBox extends StatefulWidget {
  final int myId;
  final int writerId;
  final String writerName;
  final String message;
  final DateTime createTime;
  final int unreadCount;
  final String type;
  final bool delete;
  final int roomId;
  final String msgId;
  final Set<String> hiddenBtId;
  const ChatBox({
    Key? key,
    required this.myId,
    required this.writerId,
    required this.writerName,
    required this.message,
    required this.createTime,
    required this.unreadCount,
    required this.type,
    required this.delete,
    required this.roomId,
    required this.msgId,
    required this.hiddenBtId,
  }) : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.type == 'TEXT'
            ? widget.writerId != widget.myId
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
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        widget.type == 'TEXT'
            ? Align(
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
                        : const Color.fromARGB(
                            255, 239, 243, 226), // 메시지 박스 배경 색
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
                      widget.unreadCount == 0
                          ? const SizedBox(height: 0.1)
                          : Text(
                              widget.unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color.fromARGB(255, 134, 134, 134),
                              ),
                            )
                    ],
                  ),
                ),
              )
            : Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      widget.message, // 메시지 내용
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 202, 123, 89),
                      ),
                    ),
                    widget.message.contains("초대")
                        ? const SizedBox.shrink()
                        : widget.delete
                            ? const SizedBox.shrink()
                            : widget.hiddenBtId.contains(widget.msgId)
                                ? const SizedBox.shrink()
                                : ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        int unreadCount =
                                            await postInviteUserInGroupChat(
                                                widget.roomId,
                                                widget.writerId,
                                                widget.msgId);
                                        setState(() {
                                          widget.hiddenBtId.add(widget.msgId);
                                        });
                                        // 초대된 후 unreadCount를 사용하여 추가 로직 처리
                                        log('Unread Count: $unreadCount');
                                      } catch (e) {
                                        log('Error occurred: $e');
                                        // 실패 처리 로직 (예: 사용자에게 알림 표시)
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text(
                                      "다시 채팅방에 초대하기",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Color.fromARGB(255, 142, 84, 59)),
                                    ),
                                  )
                  ],
                )),
      ],
    );
  }
}
