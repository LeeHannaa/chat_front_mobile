import 'dart:developer';
import 'dart:math' as math;
import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/apis/chatMessageApi.dart';
import 'package:chat_application/model/model_message.dart';
import 'package:chat_application/src/providers/sqflite/chat_message_sqflite_provider.dart';
import 'package:chat_application/src/services/websocket_service.dart';
import 'package:chat_application/utils/moveScroll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatMessageProvider extends ChangeNotifier {
  int myId = 0;
  int? unreadCountByMe;

  final _messagesNoType = [];
  final List<Message> _messages = List.empty(growable: true);
  List<Message> get chatmessages => _messages;

  var _roomId = 0;
  int get roomId => _roomId;

  final Set<String> _hiddenBtId = Set<String>();
  Set<String> get hiddenBtId => _hiddenBtId;

  Future<void> loadChatMessages(int myId, int? roomId, BuildContext context,
      String from, int? aptId, ScrollController scrollController) async {
    myId = myId;
    if (from == 'chatlist') {
      _messagesNoType.clear();
      _messages.clear();
      _roomId = roomId!;
      try {
        final response = await fetchChatsByRoom(_roomId, myId);
        _messagesNoType.addAll(response);
      } catch (e) {
        // sqflite로 앱 내에 저장된 채팅 내역 데이터 가져오기 (바로 Message 타입으로 저장)
        List<Message> list = await Provider.of<ChatmessageSqfliteProvider>(
                context,
                listen: false)
            .loadChatMessages(_roomId);
        _messages.addAll(list);
        notifyListeners();
        log('Error loading chat message: $e');
      }
    } else {
      // 아파트 목록에서 채팅으로 넘어가는 경우
      try {
        final response = await fetchChatsByApt(myId, aptId!);
        _messagesNoType.addAll(response);
        _roomId = _messagesNoType[0]['roomId']; // roomId 저장
        notifyListeners();
      } catch (e) {
        log('Error loading chat rooms by apt: $e');
      }
    }
    // 채팅방 웹소켓 경로 추가
    WebSocketService().subscribeToChatRoom(_roomId, myId);
    if (_messagesNoType[0]['id'] != null) {
      // messages list에 타입 변환해서 정보 담기
      late List<Message> list = _messagesNoType
          .map<Message>((json) => Message.fromJson(json))
          .toList();
      _messages.addAll(list);
      notifyListeners();
    }

    // 메시지 추가 후 스크롤
    moveScroll(scrollController);
    // 내가 안읽은 메시지 수 가져오기
    loadUnreadCountByRoom(myId);
  }

  void loadUnreadCountByRoom(int myId) async {
    try {
      unreadCountByMe = await fetchUnreadCountByRoom(_roomId, myId);
      for (int i = _messages.length - 1;
          i > _messages.length - unreadCountByMe! - 1;
          i--) {
        if (_messages[i].unreadCount == 0) break;
        _messages[i].unreadCount = (_messages[i].unreadCount ?? 1) - 1;
      }
      notifyListeners();
    } catch (e) {
      log('Error load unread count by room: $e');
    }
  }

  void deleteForAll(Message message, int myId, BuildContext context) async {
    await deleteChatMessageToAll(message.id, myId);

    final index = _messages.indexOf(message);
    if (index != -1) {
      // messages[index] = message.copyWith(message: "삭제된 메시지입니다.", delete: true);
      _messages.removeAt(index);
      // sqflite에서도 삭제된 채팅 내역 지우기
      await Provider.of<ChatmessageSqfliteProvider>(context, listen: false)
          .removeChatMessages(message.id);
    }
  }

  void handleSocketMessage(Map<String, dynamic> data, BuildContext context) {
    if (data['type'] == 'CHAT') {
      final messagePayload = data['message'];
      final receivedChat = Message.fromJson(messagePayload);
      _messages.add(receivedChat);
      notifyListeners();
      // sqflite에 받은 채팅 메시지 저장
      Provider.of<ChatmessageSqfliteProvider>(context, listen: false)
          .addChatMessages(receivedChat);
    } else if (data['type'] == 'INFO') {
      // 누가 들어왔다는 알림 메시지 처리
      int changeNumber = int.parse(data['message'].toString());
      log("상대방 입장!, 읽음처리해야할 메시지 개수 : $changeNumber");
      for (int i = _messages.length - 1;
          i > math.max(0, _messages.length - changeNumber - 1);
          i--) {
        if (_messages[i].type == 'TEXT') {
          if (_messages[i].unreadCount == 0) break;
          _messages[i].unreadCount = (_messages[i].unreadCount ?? 1) - 1;
        }
      }
      notifyListeners();
    } else if (data['type'] == 'OUT') {
      // 누가 나갔다는 알림 메시지 처리
      if (data['message'] == "상대방 퇴장") {
        log("상대방 나감!");
      }
    } else if (data['type'] == 'DELETE') {
      String deleteMsgId = data['messageId'];
      log("특정 메시지 삭제!! $deleteMsgId");
      int index = _messages.indexWhere((message) => message.id == deleteMsgId);
      if (index != -1) {
        _messages.removeAt(index);
      }
      notifyListeners();
    } else if (data['type'] == 'LEAVE') {
      // 유저가 채팅방을 나간 경우 실시간 알림 전달
      final messagePayload = data['message'];
      // 유저가 안읽은 메시지가 존재한 채 채팅방을 나간 경우
      int changeNumber = int.parse(data['msgToReadCount'].toString());
      // 메시지 읽음처리 (ui상)
      for (int i = _messages.length - 1;
          i > math.max(0, _messages.length - changeNumber - 1);
          i--) {
        if (_messages[i].type == 'TEXT') {
          if (_messages[i].unreadCount == 0) break;
          _messages[i].unreadCount = (_messages[i].unreadCount ?? 1) - 1;
        }
      }
      notifyListeners();
      // 채팅방 나갔다는 SYSTEM 메시지 저장
      if (messagePayload is Map<String, dynamic>) {
        final receivedChat = Message.fromJson(messagePayload);
        _messages.add(receivedChat);
        notifyListeners();
        // sqflite에도 SYSTEM 메시지 저장
        Provider.of<ChatmessageSqfliteProvider>(context, listen: false)
            .addChatMessages(receivedChat);
      } else {
        log("❌ message가 Map이 아님: ${messagePayload.runtimeType}");
      }
    } else if (data['type'] == 'INVITE') {
      // 초대되었다는 SYSTEM 메시지 처리
      final messagePayload = data['message'];
      if (messagePayload is Map<String, dynamic>) {
        final receivedChat = Message.fromJson(messagePayload);
        _messages.add(receivedChat);
        // 나갔다는 메시지에 '초대하기' 메시지가 안보이도록 처리
        if (receivedChat.beforeMsgId != null) {
          _hiddenBtId.add(receivedChat.beforeMsgId!);
        }
        // sqflite에도 SYSTEM 메시지 저장
        Provider.of<ChatmessageSqfliteProvider>(context, listen: false)
            .addChatMessages(receivedChat);
        notifyListeners();
      } else {
        log("❌ message가 Map이 아님: ${messagePayload.runtimeType}");
      }
    }
  }
}
