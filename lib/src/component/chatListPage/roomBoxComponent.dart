import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../format/formatDate.dart';

class RoomBox extends StatefulWidget {
  final int chatRoomId;
  final String chatName;
  final String lastMsg;
  final int index;
  final int chatNum;
  final DateTime createTime;

  const RoomBox({
    Key? key,
    required this.chatRoomId,
    required this.chatName,
    required this.lastMsg,
    required this.index,
    required this.chatNum,
    required this.createTime,
  }) : super(key: key);

  @override
  State<RoomBox> createState() => _RoomBoxState();
}

class _RoomBoxState extends State<RoomBox> {
  Future<void> leaveChatRoom(int roomId) async {
    await Provider.of<ChatRoomProvider>(context, listen: false)
        .removeChatRoom(roomId);
    deleteChatRoom(roomId);
    // TODO : 추후에 서버 db에서도 해당 사용자에 대한 채팅방 삭제 및 데이터 삭제 (아마 현재 방에 남아있는 사용자의 수를 체크한 후 0인 경우 지우면 될듯!!! 이거 지금!!!)
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.chatRoomId.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        leaveChatRoom(widget.chatRoomId);
      },
      background: Container(
        color: Colors.red, // 나가기 버튼이 보일 배경색
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 300),
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push('/chat', extra: {
            'id': widget.chatRoomId,
            'name': widget.chatName,
            'from': 'chatlist'
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              CircleAvatar(
                child: widget.chatNum > 2
                    ? const Icon(Icons.group)
                    : const Icon(Icons.person),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.chatName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          formatDate(widget.createTime),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 83, 83, 83),
                              fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lastMsg,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
