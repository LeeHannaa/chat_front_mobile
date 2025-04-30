import 'package:chat_application/src/format/formatDate.dart';
import 'package:flutter/material.dart';

class NoteDialog extends StatelessWidget {
  final int noteId;
  final int aptId;
  final String aptName;
  final String phoneNumber;
  final String noteText;
  final DateTime regDate;

  const NoteDialog({
    Key? key,
    required this.noteId,
    required this.aptId,
    required this.aptName,
    required this.phoneNumber,
    required this.noteText,
    required this.regDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String trimmed = regDate.toString().substring(0, 19).replaceFirst('T', ' ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('문의 매물: $aptName'),
        const SizedBox(height: 10),
        Text('문의자 연락처: $phoneNumber'),
        const SizedBox(height: 10),
        Text('문의 내용: $noteText'),
        const SizedBox(height: 10),
        Text('문의 날짜: $trimmed'),
      ],
    );
  }
}
