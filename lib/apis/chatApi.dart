import 'package:chat_application/apis/dio_client.dart';
import '../model/model_chatroom.dart';

Future<List<ChatRoom>> fetchChatRooms(int myId) async {
  try {
    final response = await DioClient.dio.get('/chat?myId=$myId');
    final List<dynamic> jsonData = response.data;
    final List<ChatRoom> chatRooms =
        jsonData.map((json) => ChatRoom.fromJson(json)).toList();
    chatRooms
        .sort((a, b) => b.updateLastMsgTime.compareTo(a.updateLastMsgTime));

    return chatRooms;
  } catch (e) {
    throw Exception('Failed to load chatRooms');
  }
}

Future<int> fetchUnreadCountByRoom(int roomId, int myId) async {
  try {
    final response =
        await DioClient.dio.get('/chat/unread/count/$roomId?myId=$myId');
    int unreadCount = int.parse(response.data.toString());
    return unreadCount;
  } catch (e) {
    throw Exception('Failed to load unreadCount by chatRoom');
  }
}

Future<void> deleteChatRoom(int roomId, int myId) async {
  await DioClient.dio.delete('/chat/delete/$roomId?myId=$myId');
}

Future<void> postInviteUserInGroupChat(
    int roomId, int userId, int msgId) async {
  try {
    await DioClient.dio.post(
      '/chat/invite/user/group',
      data: {
        'userId': userId,
        'roomId': roomId,
        'msgId': msgId,
      },
    );
  } catch (e) {
    throw Exception('Failed to invite user in group chat');
  }
}

Future<int> fetchConnectUserChat(int userId, int myId) async {
  try {
    final response =
        await DioClient.dio.get('/chat/connect/$userId?myId=$myId');
    int dataRoomId = int.parse(response.data.toString());
    return dataRoomId;
  } catch (e) {
    throw Exception('Failed to load unreadCount by chatRoom');
  }
}
