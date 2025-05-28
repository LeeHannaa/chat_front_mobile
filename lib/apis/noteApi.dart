import 'package:chat_application/apis/dio_client.dart';

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
