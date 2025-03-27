import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../format/formatDate.dart';

class RoomBox extends StatefulWidget {
  final int chatId;
  final String chatName;
  final String lastMsg;
  final int index;
  final int chatNum;
  final DateTime createTime;

  const RoomBox({
    Key? key,
    required this.chatId,
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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/chat', extra: {
          'id': widget.chatId,
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
