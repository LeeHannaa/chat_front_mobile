import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchUserInfo(int myId) async {
  try {
    final url = Uri.parse('http://localhost:8080/user/info?myId=$myId');

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
