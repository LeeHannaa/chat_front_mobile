import 'dart:developer';
import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:chat_application/src/providers/sqflite/chatroom_sqflite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatRoomProvider extends ChangeNotifier {
  int? myId;

  final List<ChatRoom> _chatRooms = List.empty(growable: true);
  List<ChatRoom> get chatRooms => _chatRooms;

  Future<void> loadChatRooms(BuildContext context) async {
    myId ??= await SharedPreferencesHelper.getMyId();
    try {
      final response = await fetchChatRooms(myId!);
      _chatRooms.clear();
      _chatRooms.addAll(response);
      notifyListeners();
    } catch (e) {
      if (!context.mounted) return;
      // sqflite로 채팅방 데이터 불러오기
      final response =
          await Provider.of<ChatRoomSqfliteProvider>(context, listen: false)
              .loadChatRooms();
      _chatRooms.clear();
      _chatRooms.addAll(response);
      log('Error loading chat rooms: $e');
    }
  }

  void handleSocketMessage(Map<String, dynamic> message, BuildContext context) {
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
        final newChatRoom = ChatRoom(
          id: message['message']['roomId'],
          name: message['message']['name'],
          lastmsg: message['message']['lastMsg'],
          num: message['message']['memberNum'] ?? 2,
          updateLastMsgTime:
              DateTime.parse(message['message']['updateLastMsgTime']),
          unreadCount: message['message']['unreadCount'],
        );
        _chatRooms.add(newChatRoom);
        // sqflite 채팅방 정보로 저장하기
        Provider.of<ChatRoomSqfliteProvider>(context, listen: false)
            .addChatRoom(newChatRoom);
      }

      _chatRooms
          .sort((a, b) => b.updateLastMsgTime.compareTo(a.updateLastMsgTime));
      notifyListeners();
    }
  }
}
