import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'model/model_chatroom.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ScrollController _scrollController = ScrollController();
  // TODO : 채팅방 리스트 더미데이터로 우선 설정 -> DB에서 가져오기
  final List<ChatRoom> _data = [
    ChatRoom(
        id: 1,
        name: '안녕부동산',
        lastmsg: '가격 조정이 가능한가요?',
        num: 2,
        dateTime: DateTime(2025, 3, 1, 10, 30)),
    ChatRoom(
        id: 2,
        name: '녹차마을',
        lastmsg: '매매가 조정 가능한가요?.',
        num: 4,
        dateTime: DateTime(2025, 3, 2, 14, 0)),
    ChatRoom(
        id: 3,
        name: 'Game Night',
        lastmsg: '보증금 조정 가능한가요?.',
        num: 2,
        dateTime: DateTime(2025, 3, 3, 18, 45)),
    ChatRoom(
        id: 4,
        name: '삐약이',
        lastmsg: '너무 비싼 것 같은데욥.',
        num: 9,
        dateTime: DateTime(2025, 3, 4, 11, 15)),
    ChatRoom(
        id: 5,
        name: '콩콩이',
        lastmsg: '스티커를 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 5, 13, 0)),
    ChatRoom(
        id: 6,
        name: '한전',
        lastmsg: '매매가 조정 가능한가요?.',
        num: 8,
        dateTime: DateTime(2025, 3, 6, 16, 30)),
    ChatRoom(
        id: 7,
        name: '배구팟',
        lastmsg: '사진을 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 7, 9, 0)),
    ChatRoom(
        id: 8,
        name: '지호',
        lastmsg: '스티커를 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 6, 20, 0)),
    ChatRoom(
        id: 9,
        name: '태훈',
        lastmsg: '스티커를 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 6, 22, 0)),
    ChatRoom(
        id: 10,
        name: '보배교',
        lastmsg: '사진을 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 7, 7, 30)),
    ChatRoom(
        id: 11,
        name: '은비',
        lastmsg: '스티커를 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 7, 12, 0)),
    ChatRoom(
        id: 12,
        name: '강산',
        lastmsg: '사진3장을 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 6, 14, 45)),
    ChatRoom(
        id: 13,
        name: '민호',
        lastmsg: '사진30장을 보냈어요.',
        num: 2,
        dateTime: DateTime(2025, 3, 6, 17, 30)),
  ];
  @override
  void initState() {
    super.initState();
    _data.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  bool isLoading = false;

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
      // 그 외에는 년.월.일 형식으로 출력
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }

  @override
  void dispose() {
    // 위젯이 소멸될 때 스크롤 컨트롤러 해제
    _scrollController.dispose();
    super.dispose();
  }

  int _clickedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          // 리스트 뷰 생성
          ListView.builder(
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final chat = _data[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _clickedIndex = index;
                  });
                  context
                      .push('/chat', extra: {'id': chat.id, 'name': chat.name});
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: _clickedIndex == index
                        ? Colors.grey.shade300 // 클릭 시 색상 변경
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: chat.num > 2
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
                                  chat.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  _formatDate(chat.dateTime),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 83, 83, 83),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat.lastmsg,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
