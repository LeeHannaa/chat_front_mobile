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
