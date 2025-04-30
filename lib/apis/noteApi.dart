import 'dart:convert';
import 'dart:developer';
import 'package:chat_application/model/model_note.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final apiAddress = dotenv.get('API_ANDROID_ADDRESS');

Future<bool> postNoteByNonMember(
    int aptId, String phoneNumber, String noteText) async {
  final response = await http.post(
    Uri.parse('$apiAddress/note/send/nonmember'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(
        {'aptId': aptId, 'phoneNumber': phoneNumber, 'noteText': noteText}),
  );

  if (response.statusCode == 200) {
    log(response.body);
    return true;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load unreadCount by chatRoom');
  }
}

Future<List<Note>> fetchNoteList(int myId) async {
  final response =
      await http.get(Uri.parse('$apiAddress/note/list?myId=$myId'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    final List<Note> notes =
        jsonData.map((json) => Note.fromJson(json)).toList();
    notes.sort((a, b) => b.regDate.compareTo(a.regDate));

    log(response.body);
    return notes;
  } else {
    log('Failed to load data: ${response.statusCode}');
    throw Exception('Failed to load note');
  }
}

Future<void> readNote(int userId, int noteId) async {
  final response = await http.post(
    Uri.parse('$apiAddress/note/read/note?myId=$userId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: noteId.toString(),
  );

  if (response.statusCode == 200) {
    log(response.body);
  } else {
    log('Failed to delete data: ${response.statusCode}');
    throw Exception('Failed to load unreadCount by note');
  }
}

Future<void> deleteNoteRecord(int noteId, int myId) async {
  log("$noteId 쪽지 삭제하기");
  final response = await http
      .delete(Uri.parse('$apiAddress/note/delete/$noteId?myId=$myId'));
  if (response.statusCode == 200) {
    log(response.body);
  } else {
    throw Exception('Failed to delete chatRoom');
  }
}
