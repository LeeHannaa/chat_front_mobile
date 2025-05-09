import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final apiAddress = dotenv.get('API_ANDROID_ADDRESS');

Future<List> fetchChatsByRoom(
    int roomId, int myId, BuildContext context) async {
  log("chatlist에서 옴!!! roomId : $roomId");
  final response = await http
      .get(Uri.parse('$apiAddress/chatmsg/find/list/$roomId?myId=$myId'));

  if (response.statusCode == 200) {
    log(response.body);
    var decodedResponse = json.decode(response.body);
    var messageList = decodedResponse as List;
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
    log("채팅방 입장했을 때 정보 받아오기 : ${response.body}");
    var decodedResponse = json.decode(response.body);
    return decodedResponse;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load chats');
  }
}

Future<void> deleteChatMessageToMe(String msgId, int myId) async {
  log("$msgId 채팅 내역 내 기기에서 삭제하기");
  final response = await http
      .delete(Uri.parse('$apiAddress/chatmsg/delete/me/$msgId?myId=$myId'));
  if (response.statusCode == 200) {
    log(response.body);
  } else {
    throw Exception('Failed to delete chatMessage');
  }
}

Future<void> deleteChatMessageToAll(String msgId, int myId) async {
  log("$msgId 채팅 내역 전체에게 삭제하기");
  final response = await http
      .delete(Uri.parse('$apiAddress/chatmsg/delete/all/$msgId?myId=$myId'));
  if (response.statusCode == 200) {
    log(response.body);
  } else {
    throw Exception('Failed to delete chatRoom');
  }
}
