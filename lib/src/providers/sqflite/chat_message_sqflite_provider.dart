import 'package:chat_application/model/model_message.dart';
import 'package:chat_application/src/services/databaseHelper_service.dart';
import 'package:flutter/material.dart';

class ChatmessageSqfliteProvider with ChangeNotifier {
  List _chatMessage = [];

  List get chatMessage => _chatMessage;

  Future<List> loadChatMessages(int roomId) async {
    _chatMessage = await DatabaseHelper().getChatMessagesByRoomId(roomId);
    notifyListeners();
    return _chatMessage;
  }

  Future<void> addChatMessages(Message message) async {
    await DatabaseHelper().insertChatMessage(message);
    await loadChatMessages(message.roomId);
  }

  Future<void> removeChatMessages(String id) async {
    await DatabaseHelper().deleteChatMessage(id);
    // await loadChatMessages();
  }
}
