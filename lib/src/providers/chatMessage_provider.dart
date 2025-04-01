import 'package:chat_application/model/model_message.dart';
import 'package:chat_application/src/services/DatabaseHelper.dart';
import 'package:flutter/material.dart';

class ChatmessageProvider with ChangeNotifier {
  List<Message> _chatMessage = [];

  List<Message> get chatMessage => _chatMessage;

  Future<List> loadChatMessages(int roomId) async {
    _chatMessage = await DatabaseHelper().getChatMessagesByRoomId(roomId);
    for (var message in _chatMessage) {
      print(
          'Message ID: ${message.id}, Name: ${message.name}, Msg: ${message.message}, Time: ${message.createTime}');
    }
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
