import 'dart:developer';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/src/services/databaseHelper_service.dart';
import 'package:flutter/material.dart';

class ChatRoomSqfliteProvider with ChangeNotifier {
  List<ChatRoom> _chatRooms = [];

  List<ChatRoom> get chatRooms => _chatRooms;

  Future<List<ChatRoom>> loadChatRooms() async {
    _chatRooms = await DatabaseHelper().getChatRooms();
    for (var chatRoom in _chatRooms) {
      log('ChatRooms ID: ${chatRoom.id}, Name: ${chatRoom.name}, lastmsg: ${chatRoom.lastmsg}, Time: ${chatRoom.updateLastMsgTime}');
    }
    notifyListeners();
    return _chatRooms;
  }

  Future<void> addChatRoom(ChatRoom chatRoom) async {
    await DatabaseHelper().insertChatRoom(chatRoom);
    await loadChatRooms();
  }

  Future<void> updateLastMessages() async {
    await DatabaseHelper().updateLastMessages();
  }

  Future<void> removeChatRoom(int roomId) async {
    await DatabaseHelper().deleteChatRoomAndMessages(roomId);
    // await loadChatRooms();
  }
}
