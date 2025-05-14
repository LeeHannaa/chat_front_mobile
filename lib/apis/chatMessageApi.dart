import 'package:chat_application/apis/dio_client.dart';
import 'package:flutter/material.dart';

Future<List> fetchChatsByRoom(
    int roomId, int myId, BuildContext context) async {
  try {
    final response =
        await DioClient.dio.get('/chatmsg/find/list/$roomId?myId=$myId');
    final List<dynamic> chatList = response.data;
    return chatList;
  } catch (e) {
    throw Exception('Failed to load chats by chatroom');
  }
}

Future<List> fetchChatsByApt(int myId, int aptId) async {
  try {
    final response =
        await DioClient.dio.get('/chatmsg/apt/find/list/$aptId?myId=$myId');
    final List<dynamic> chatList = response.data;
    return chatList;
  } catch (e) {
    throw Exception('Failed to load chats by aptlist');
  }
}

Future<void> deleteChatMessageToMe(String msgId, int myId) async {
  await DioClient.dio.delete('/chatmsg/delete/me/$msgId?myId=$myId');
}

Future<void> deleteChatMessageToAll(String msgId, int myId) async {
  await DioClient.dio.delete('/chatmsg/delete/all/$msgId?myId=$myId');
}
