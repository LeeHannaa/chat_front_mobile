class Note {
  Note({
    required this.noteId,
    required this.aptId,
    required this.aptName,
    required this.phoneNumber,
    required this.noteText,
    required this.regDate,
    required this.isRead,
  });
  final int noteId;
  final int aptId;
  final String aptName;
  final String phoneNumber;
  final String noteText;
  final DateTime regDate;
  final bool isRead;

  @override
  String toString() {
    return '$noteId (aptId: $aptId, aptName: $aptName, phoneNumber: $phoneNumber, noteText: $noteText, regDate: ${regDate.toLocal()})';
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
        noteId: json['noteId'] ?? 0,
        aptId: json['aptId'] ?? 0,
        aptName: json['aptName'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        noteText: json['noteText'] ?? '',
        regDate: DateTime.parse(json['regDate']),
        isRead: json['isRead'] ?? false);
  }

  Note copyWith({
    bool? isRead,
  }) {
    return Note(
        noteId: noteId,
        aptId: aptId,
        aptName: aptName,
        phoneNumber: phoneNumber,
        noteText: noteText,
        regDate: regDate,
        isRead: isRead ?? this.isRead);
  }
}
