import 'package:chat_application/apis/dio_client.dart';
import 'package:chat_application/model/model_note.dart';

Future<bool> postNoteByNonMember(
    int aptId, String phoneNumber, String noteText) async {
  final response = await DioClient.dio.post(
    '/note/send/nonmember',
    data: {'aptId': aptId, 'phoneNumber': phoneNumber, 'noteText': noteText},
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to post the note by nonmember');
  }
}

Future<List<Note>> fetchNoteList(int myId) async {
  try {
    final response = await DioClient.dio.get('/note/list?myId=$myId');
    final List<dynamic> jsonData = response.data;
    final List<Note> notes =
        jsonData.map((json) => Note.fromJson(json)).toList();
    notes.sort((a, b) => b.regDate.compareTo(a.regDate));

    return notes;
  } catch (e) {
    throw Exception('Failed to load note');
  }
}

Future<void> readNote(int userId, int noteId) async {
  try {
    await DioClient.dio.post(
      '/note/read/note?myId=$userId',
      data: noteId,
    );
  } catch (e) {
    throw Exception('Failed to read the note');
  }
}

Future<void> deleteNoteRecord(int noteId, int myId) async {
  await DioClient.dio.delete('/note/delete/$noteId?myId=$myId');
}
