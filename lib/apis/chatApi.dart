import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../model/model_chatroom.dart';
import '../model/model_message.dart';

Future<List<ChatRoom>> fetchChatRooms(int myId) async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/chat?myId=$myId'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    final List<ChatRoom> chatRooms =
        jsonData.map((json) => ChatRoom.fromJson(json)).toList();
    chatRooms.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    log(response.body);
    return chatRooms;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load chat rooms');
  }
}

Future<List> fetchChatsByRoom(int roomId) async {
  log("chatlist에서 옴!!! roomId : $roomId");
  final response = await http
      .get(Uri.parse('http://localhost:8080/chatmsg/find/list/$roomId'));

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
  final response = await http.get(Uri.parse(
      'http://localhost:8080/chatmsg/apt/find/list/$aptId?myId=$myId'));

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
