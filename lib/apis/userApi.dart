import 'package:chat_application/apis/dio_client.dart';

Future<Map<String, dynamic>> fetchUserInfo(int myId) async {
  try {
    final response = await DioClient.dio.get('/user/info?myId=$myId');
    final data = response.data as Map<String, dynamic>;
    return data;
  } catch (e) {
    throw Exception('Failed to load user info');
  }
}

Future<void> sendFcmToken(int myId, String appCode) async {
  try {
    await DioClient.dio.post(
      '/fcmtoken/save',
      data: {'userIdx': myId, 'appCode': appCode},
    );
  } catch (e) {
    throw Exception('Failed to save the fcm token');
  }
}
