import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/src/services/DatabaseHelper.dart';
import 'package:flutter/material.dart';

class ChatRoomProvider with ChangeNotifier {
  List<ChatRoom> _chatRooms = [];

  List<ChatRoom> get chatRooms => _chatRooms;

  Future<List<ChatRoom>> loadChatRooms() async {
    _chatRooms = await DatabaseHelper().getChatRooms();
    for (var chatRoom in _chatRooms) {
      print(
          'ChatRooms ID: ${chatRoom.id}, Name: ${chatRoom.name}, lastmsg: ${chatRoom.lastmsg}, Time: ${chatRoom.dateTime}');
    }
    notifyListeners();
    return _chatRooms;
  }

  Future<void> addChatRoom(ChatRoom chatRoom) async {
    await DatabaseHelper().insertChatRoom(chatRoom);
    await loadChatRooms();
  }

  Future<void> removeChatRoom(int id) async {
    await DatabaseHelper().deleteChatRoom(id);
    // await loadChatRooms();
  }
}
