import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/sqflite/chatroom_sqflite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../format/formatDate.dart';

class RoomBox extends StatefulWidget {
  final ChatRoom chatroom;
  final VoidCallback? onTap;

  const RoomBox({
    Key? key,
    required this.chatroom,
    this.onTap,
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
    await Provider.of<ChatRoomSqfliteProvider>(context, listen: false)
        .removeChatRoom(roomId);
    deleteChatRoom(roomId, myId!);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.chatroom.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        leaveChatRoom(widget.chatroom.id);
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
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              CircleAvatar(
                  child: widget.chatroom.num > 1
                      ? widget.chatroom.num > 2
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
                          widget.chatroom.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        widget.chatroom.num > 2
                            ? Text(
                                widget.chatroom.num.toString(),
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 141, 141, 141),
                                    fontSize: 10),
                              )
                            : const SizedBox(),
                        Text(
                          formatDate(widget.chatroom.updateLastMsgTime),
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
                            widget.chatroom.lastmsg,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          widget.chatroom.unreadCount == null ||
                                  widget.chatroom.unreadCount == 0
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(
                                        255, 255, 47, 47), // 빨간색 배경
                                    shape: BoxShape.circle, // 원형
                                  ),
                                  child: Text(
                                    widget.chatroom.unreadCount.toString(),
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
