import 'dart:developer';

import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';

class ChatRoomProvider extends ChangeNotifier {
  int? myId;

  final List<ChatRoom> _chatRooms = List.empty(growable: true);
  List<ChatRoom> get chatRooms => _chatRooms;

  Future<void> loadChatRooms() async {
    myId ??= await SharedPreferencesHelper.getMyId();
    try {
      final response = await fetchChatRooms(myId!);
      _chatRooms.clear();
      _chatRooms.addAll(response);
      notifyListeners();
    } catch (e) {
      // _chatRooms =
      //     await Provider.of<ChatRoomSqfliteProvider>()
      //         .loadChatRooms();
      log('Error loading chat rooms: $e');
    }
  }

  void handleSocketMessage(Map<String, dynamic> message) {
    if (message['type'] == 'CHATLIST') {
      int index = _chatRooms
          .indexWhere((chat) => chat.id == message['message']['roomId']);

      if (index != -1) {
        _chatRooms[index] = _chatRooms[index].copyWith(
          lastmsg: message['message']['lastMsg'],
          updateLastMsgTime:
              DateTime.parse(message['message']['updateLastMsgTime']),
          unreadCount: message['message']['unreadCount'],
        );
      } else {
        _chatRooms.add(ChatRoom(
          id: message['message']['roomId'],
          name: message['message']['name'],
          lastmsg: message['message']['lastMsg'],
          num: message['message']['memberNum'] ?? 2,
          updateLastMsgTime:
              DateTime.parse(message['message']['updateLastMsgTime']),
          unreadCount: message['message']['unreadCount'],
        ));
      }

      _chatRooms
          .sort((a, b) => b.updateLastMsgTime.compareTo(a.updateLastMsgTime));
      notifyListeners();
    }
  }
}
