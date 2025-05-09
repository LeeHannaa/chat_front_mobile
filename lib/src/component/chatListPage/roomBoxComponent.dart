import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/chatRoom_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../format/formatDate.dart';

class RoomBox extends StatefulWidget {
  final Future<void> Function() loadChatRooms;
  final int chatRoomId;
  final String chatName;
  final String lastMsg;
  final int chatNum;
  final DateTime updateLastMsgTime;
  int? unreadCount;

  RoomBox({
    Key? key,
    required this.loadChatRooms,
    required this.chatRoomId,
    required this.chatName,
    required this.lastMsg,
    required this.chatNum,
    required this.updateLastMsgTime,
    this.unreadCount,
  }) : super(key: key);

  @override
  State<RoomBox> createState() => _RoomBoxState();
}

class _RoomBoxState extends State<RoomBox> {
  int? myId;
  // myId 불러오는 함수
  Future<void> _loadMyId() async {
    myId = await SharedPreferencesHelper.getMyId();
  }

  Future<void> leaveChatRoom(int roomId) async {
    _loadMyId();
    await Provider.of<ChatRoomProvider>(context, listen: false)
        .removeChatRoom(roomId);
    deleteChatRoom(roomId, myId!);
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
        // TODO : 이거를 RoomBox를 선언하는 페이지에서 처리
        onTap: () async {
          final result = await context.push('/chat', extra: {
            'id': widget.chatRoomId,
            'name': widget.chatName,
            'from': 'chatlist',
          });
          if (result == true) {
            // 여기서 새로고침 로직 실행
            await widget.loadChatRooms();
          }
          // 채팅방에서 돌아오면 setState로 갱신
          if (mounted) {
            setState(() {
              widget.unreadCount = 0;
            });
          }
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
                  child: widget.chatNum > 1
                      ? widget.chatNum > 2
                          ? const Icon(Icons.group)
                          : const Icon(Icons.person)
                      : const Icon(Icons.person_off)),
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
                        widget.chatNum > 2
                            ? Text(
                                widget.chatNum.toString(),
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 141, 141, 141),
                                    fontSize: 10),
                              )
                            : const SizedBox(),
                        Text(
                          formatDate(widget.updateLastMsgTime),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 83, 83, 83),
                              fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.lastMsg,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          widget.unreadCount == null || widget.unreadCount == 0
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(
                                        255, 255, 47, 47), // 빨간색 배경
                                    shape: BoxShape.circle, // 원형
                                  ),
                                  child: Text(
                                    widget.unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white, // 글자색 흰색
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                        ]),
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
