import 'dart:developer' as developer;
import 'dart:math';
import 'package:chat_application/apis/chatApi.dart';
import 'package:chat_application/apis/chatMessageApi.dart';
import 'package:chat_application/model/model_chatroom.dart';
import 'package:chat_application/model/model_message.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';

class ChatMessageProvider extends ChangeNotifier {
  int? myId;
  int? roomId;
  int? unreadCountByMe;

  // var messageList = [];
  final List<Message> _messages = List.empty(growable: true);
  List<Message> get chatmessages => _messages;

  // Future<void> loadChatMessages(int? roomId, int? aptId, String from) async {
  //   myId ??= await SharedPreferencesHelper.getMyId();
  //   if (from == 'chatlist') {
  //     if (roomId != null) {
  //       try {
  //         final response = await fetchChatsByRoom(roomId, myId!);
  //         messageList = response;
  //         _messages.clear();
  //         _messages.addAll(response);
  //         notifyListeners();
  //       } catch (e) {
  //         developer.log('Error loading chatMessages by chatList: $e');
  //       }
  //     }
  //   } else {
  //     if (aptId != null) {
  //       try {
  //         final response = await fetchChatsByApt(aptId, myId!);
  //         messageList = response;
  //         _messages.clear();
  //         _messages.addAll(response);
  //         notifyListeners();
  //         // roomId 설정되는 상황
  //         roomId = _messages[0].roomId;
  //       } catch (e) {
  //         developer.log('Error loading chatMessages by apt: $e');
  //       }
  //     }
  //   }
  //   // 웹소켓 연결
  //   if (_messages[0].id != null) {
  //     // 내가 안읽은 메시지 수 가져오기
  //     unreadCountByMe = await fetchUnreadCountByRoom(roomId!, myId!);
  //     for (int i = _messages.length - 1;
  //         i > _messages.length - unreadCountByMe! - 1;
  //         i--) {
  //       if (_messages[i].unreadCount == 0) break;
  //       _messages[i].unreadCount = (_messages[i].unreadCount ?? 1) - 1;
  //     }
  //     notifyListeners();
  //   } else {
  //     if (roomId != null) {
  //       final newChatRoom = ChatRoom(
  //         id: roomId,
  //         name: messageList[0]['roomName'],
  //         lastmsg: '',
  //         num: messageList[0]['memberNum'],
  //         updateLastMsgTime:
  //             DateTime.parse(messageList[0]['updateLastMsgTime']),
  //       );
  //       // sqlite에 저장
  //       // Provider.of<ChatRoomSqfliteProvider>(context, listen: false)
  //       //     .addChatRoom(newChatRoom);
  //     }
  //   }
  // }

  // void handleSocketMessage(Map<String, dynamic> data) {
  //   if (data['type'] == 'CHAT') {
  //     // 일반 채팅 메시지 처리
  //     final messagePayload = data['message'];
  //     if (messagePayload is Map<String, dynamic>) {
  //       final receivedChat = Message.fromJson(messagePayload);
  //       _messages.add(receivedChat);
  //       // sqlite에 저장
  //       // Provider.of<ChatmessageSqfliteProvider>(context, listen: false)
  //       //     .addChatMessages(receivedChat);
  //       notifyListeners();
  //     } else {
  //       developer.log("❌ message가 Map이 아님: ${messagePayload.runtimeType}");
  //     }
  //   } else if (data['type'] == 'INFO') {
  //     // 누가 들어왔다는 알림 메시지 처리
  //     developer.log("상대방 입장!!!!!!!, 읽음처리해야할 메시지 개수 : ");
  //     int changeNumber = int.parse(data['message'].toString());
  //     developer.log(data['message'].toString());
  //     for (int i = _messages.length - 1;
  //         i > max(0, _messages.length - changeNumber - 1);
  //         i--) {
  //       if (_messages[i].type == 'TEXT') {
  //         if (_messages[i].unreadCount == 0) break;
  //         _messages[i].unreadCount = (_messages[i].unreadCount ?? 1) - 1;
  //       }
  //     }
  //     notifyListeners();
  //   } else if (data['type'] == 'OUT') {
  //     // 누가 나갔다는 알림 메시지 처리
  //     if (data['message'] == "상대방 퇴장") {
  //       developer.log("상대방 퇴장!!!!!!!");
  //     }
  //   } else if (data['type'] == 'DELETE') {
  //     // 메시지가 삭제되었다!!
  //     String deleteMsgId = data['messageId'];
  //     developer.log("특정 메시지 삭제!! $deleteMsgId");
  //     int index = _messages.indexWhere((message) => message.id == deleteMsgId);
  //     if (index != -1) {
  //       // messages[index].message = "삭제된 메시지입니다.";
  //       _messages.removeAt(index);
  //       _messages[index].delete = true;
  //     }
  //     notifyListeners();
  //   } else if (data['type'] == 'LEAVE') {
  //     // 유저가 채팅방을 나간 경우 실시간 알림 전달
  //     final messagePayload = data['message'];
  //     // 유저가 안읽은 메시지가 존재한 채 채팅방을 나간 경우
  //     int changeNumber = int.parse(data['msgToReadCount'].toString());
  //     developer.log(data['message'].toString());
  //     for (int i = _messages.length - 1;
  //         i > max(0, _messages.length - changeNumber - 1);
  //         i--) {
  //       if (_messages[i].type == 'TEXT') {
  //         if (_messages[i].unreadCount == 0) break;
  //         _messages[i].unreadCount = (_messages[i].unreadCount ?? 1) - 1;
  //       }
  //     }
  //     notifyListeners();
  //     if (messagePayload is Map<String, dynamic>) {
  //       final receivedChat = Message.fromJson(messagePayload);
  //       _messages.add(receivedChat);
  //       // sqlite에 저장
  //       // Provider.of<ChatmessageSqfliteProvider>(context, listen: false)
  //       //     .addChatMessages(receivedChat);
  //       notifyListeners();
  //     } else {
  //       developer.log("❌ message가 Map이 아님: ${messagePayload.runtimeType}");
  //     }
  //   } else if (data['type'] == 'INVITE') {
  //     // 일반 채팅 메시지 처리
  //     final messagePayload = data['message'];
  //     if (messagePayload is Map<String, dynamic>) {
  //       final receivedChat = Message.fromJson(messagePayload);
  //       _messages.add(receivedChat);
  //       if (receivedChat.beforeMsgId != null) {
  //         hiddenBtId.add(receivedChat.beforeMsgId!);
  //       }
  //       // sqlite에 저장
  //       // Provider.of<ChatmessageSqfliteProvider>(context, listen: false)
  //       //     .addChatMessages(receivedChat);
  //       notifyListeners();
  //     } else {
  //       developer.log("❌ message가 Map이 아님: ${messagePayload.runtimeType}");
  //     }
  //   }
  // }
}
