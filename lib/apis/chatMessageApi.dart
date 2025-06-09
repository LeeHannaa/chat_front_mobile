import 'package:chat_application/apis/dio_client.dart';

Future<List> fetchChatsByRoom(int roomId, int myId) async {
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

Future<void> deleteChatMessageToMe(int msgId, int myId) async {
  await DioClient.dio.delete('/chatmsg/delete/me/$msgId?myId=$myId');
}

Future<void> deleteChatMessageToAll(int msgId, int myId) async {
  await DioClient.dio.delete('/chatmsg/delete/all/$msgId?myId=$myId');
}
