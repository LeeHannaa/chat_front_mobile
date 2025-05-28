class SendMessage {
  final int? roomId;
  final int? aptId;
  final String? chatName;
  final String msg;
  final int writerId;
  final String writerName;
  final String regDate;

  SendMessage({
    this.roomId,
    this.aptId,
    this.chatName,
    required this.msg,
    required this.writerId,
    required this.writerName,
    required this.regDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'aptId': aptId,
      'chatName': chatName,
      'msg': msg,
      'writerId': writerId,
      'writerName': writerName,
      'regDate': regDate,
    };
  }
}
