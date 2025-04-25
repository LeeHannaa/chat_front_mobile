import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/model_chatroom.dart';

final apiAddress = dotenv.get('API_ANDROID_ADDRESS');
Future<List<ChatRoom>> fetchChatRooms(int myId) async {
  final response = await http.get(Uri.parse('$apiAddress/chat?myId=$myId'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    final List<ChatRoom> chatRooms =
        jsonData.map((json) => ChatRoom.fromJson(json)).toList();
    chatRooms
        .sort((a, b) => b.updateLastMsgTime.compareTo(a.updateLastMsgTime));

    log(response.body);
    return chatRooms;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load chatRoom');
  }
}

Future<int> fetchUnreadCountByRoom(int roomId, int myId) async {
  final response = await http
      .get(Uri.parse('$apiAddress/chat/unread/count/$roomId?myId=$myId'));

  if (response.statusCode == 200) {
    log(response.body);
    int unreadCount = int.parse(response.body);
    return unreadCount;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load unreadCount by chatRoom');
  }
}

Future<void> deleteChatRoom(int roomId, int myId) async {
  log("$roomId 채팅방 삭제하기");
  final response = await http
      .delete(Uri.parse('$apiAddress/chat/delete/$roomId?myId=$myId'));
  if (response.statusCode == 200) {
    log(response.body);
  } else {
    throw Exception('Failed to delete chatRoom');
  }
}

// TODO : 초대된 데이터 넘어오면 유저 초대되었다고 확인
// TODO :다시 들어왔다는 것도 채팅 내역에 (db) 추가해야함.......(함) 백에서 따로 추가하고 프론트에서도 일단 일시적으로 추가해두는걸로!!
Future<int> postInviteUserInGroupChat(int roomId, int myId) async {
  final response = await http.post(
    Uri.parse('$apiAddress/chat/invite/user/group'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'userId': myId,
      'roomId': roomId,
    }),
  );

  if (response.statusCode == 200) {
    log(response.body);
    int unreadCount = int.parse(response.body);
    return unreadCount;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load unreadCount by chatRoom');
  }
}
