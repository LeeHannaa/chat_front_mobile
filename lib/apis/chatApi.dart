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

Future<int> fetchUnreadCountByRoom(int roomId) async {
  final response =
      await http.get(Uri.parse('$apiAddress/chat/unread/count?roomId=$roomId'));

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
