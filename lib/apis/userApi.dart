import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final apiAddress = dotenv.get('API_ANDROID_ADDRESS');
Future<Map<String, dynamic>> fetchUserInfo(int myId) async {
  try {
    final url = Uri.parse('$apiAddress/user/info?myId=$myId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Network response was not ok');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    log('유저 정보 : $data');
    return data;
  } catch (error) {
    log('API 요청 실패: $error');
    rethrow;
  }
}

Future<void> sendFcmToken(int myId, String fcmToken) async {
  final url = Uri.parse('$apiAddress/user/token');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': myId, 'fcmToken': fcmToken}),
  );

  if (response.statusCode == 200) {
    print("FCM 토큰 등록 성공");
  } else {
    print("FCM 토큰 등록 실패: ${response.body}");
  }
}
