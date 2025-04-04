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
    chatRooms.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    log(response.body);
    return chatRooms;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load chatRoom');
  }
}

Future<List> fetchChatsByRoom(int roomId, BuildContext context) async {
  log("chatlist에서 옴!!! roomId : $roomId");
  final response =
      await http.get(Uri.parse('$apiAddress/chatmsg/find/list/$roomId'));

  if (response.statusCode == 200) {
    log(response.body);
    var decodedResponse = json.decode(response.body);
    var messageList = decodedResponse[0]['body'] as List;
    return messageList;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load chats');
  }
}

Future<List> fetchChatsByApt(int myId, int aptId) async {
  log("apt에서 옴!!! aptId : $aptId");
  final response = await http
      .get(Uri.parse('$apiAddress/chatmsg/apt/find/list/$aptId?myId=$myId'));

  if (response.statusCode == 200) {
    log(response.body);
    var decodedResponse = json.decode(response.body);
    var messageList = decodedResponse[0]['body'] as List;
    return messageList;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load chats');
  }
}

Future<void> deleteChatRoom(int roomId) async {
  log("$roomId 채팅방 삭제하기");
  final response =
      await http.delete(Uri.parse('$apiAddress/chat/delete/$roomId'));
  if (response.statusCode == 200) {
    log(response.body);
  } else {
    throw Exception('Failed to delete chatRoom');
  }
}
