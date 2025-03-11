import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'model/model_chatroom.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ScrollController _scrollController = ScrollController();
  late List<ChatRoom> _data = [
    // ChatRoom(
    //     id: 1,
    //     name: '안녕부동산',
    //     lastmsg: '가격 조정이 가능한가요?',
    //     num: 2,
    //     dateTime: DateTime(2025, 3, 1, 10, 30)),
    // ChatRoom(
    //     id: 2,
    //     name: '녹차마을',
    //     lastmsg: '매매가 조정 가능한가요?.',
    //     num: 4,
    //     dateTime: DateTime(2025, 3, 2, 14, 0)),
  ];

  // API를 호출하여 데이터를 가져오는 함수
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:8080/chat'));

    if (response.statusCode == 200) {
      // JSON 형식의 응답을 Dart 객체로 변환하여 데이터 리스트에 저장
      setState(() {
        _data = json
            .decode(response.body)
            .map<ChatRoom>((json) => ChatRoom.fromJson(json))
            .toList();
        _data.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        log(response.body);
      });
    } else {
      log('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
