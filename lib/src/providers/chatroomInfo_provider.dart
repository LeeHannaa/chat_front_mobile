import 'dart:developer';

import 'package:chat_application/model/model_chatroomInfo.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatRoomInfoProvider extends ChangeNotifier {
  late ChatRoomInfo _chatRoomInfo;
  ChatRoomInfo get chatRoomInfo => _chatRoomInfo;
  int? myId;
  void handleSocketMessage(
      Map<String, dynamic> message, BuildContext context) async {
    myId ??= await SharedPreferencesHelper.getMyId();
    if (message['type'] == 'CLEAR_ROOM' && message['message'] != null) {
      log('매물 문의한 후 방의 정보를 받아온 경우 !! ' + message['type']);
      _chatRoomInfo = ChatRoomInfo.fromJson(message['message']);
      context.push('/chat', extra: {
        'id': _chatRoomInfo.roomId,
        'myId': myId,
        'name': _chatRoomInfo.name,
        'from': 'chatlist'
      }); // 채팅 페이지로 이동
    }
  }
}
