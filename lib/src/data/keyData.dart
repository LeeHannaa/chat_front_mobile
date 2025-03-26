import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<void> saveMyId(int myId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('myId', myId);
    log("myId 저장 완료!");
  }

  static Future<int> getMyId() async {
    final prefs = await SharedPreferences.getInstance();
    int? myId = prefs.getInt('myId') ?? 0;
    log("myId 가져오기 : $myId");
    return myId; // 저장된 값이 없으면 null 반환
  }

  static Future<void> saveMyName(String myName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('myName', myName);
    log("myName 저장 완료!");
  }

  static Future<String> getMyName() async {
    final prefs = await SharedPreferences.getInstance();
    String? myName = prefs.getString('myName') ?? "";
    log("myName 가져오기 : $myName");
    return myName;
  }
}
