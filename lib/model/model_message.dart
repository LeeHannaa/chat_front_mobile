class Message {
  Message({
    required this.id,
    required this.name,
    required this.writerId,
    required this.message,
    required this.roomId,
    required this.createTime,
  });
  final String id;
  final String name;
  final int writerId;
  final String message;
  final int roomId;
  final DateTime createTime;

  @override
  String toString() {
    return '$name $message (ID: $id, UserId: $writerId, Num: $roomId, Date: $createTime)';
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['id'],
        name: json['writerName'],
        writerId: json['writerId'],
        roomId: json['roomId'],
        message: json['msg'],
        createTime: DateTime.parse(json['createdDate']));
  }

  factory Message.fromJsonSqlite(Map<String, dynamic> json) {
    return Message(
        id: json['id'],
        name: json['name'],
        writerId: json['writerId'],
        roomId: json['roomId'],
        message: json['message'],
        createTime: DateTime.parse(json['createTime']));
  }

  // 객체 데이터를 데이터베이스에 저장할 수 있는 형태로 변환
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "writerId": writerId,
        "roomId": roomId,
        "message": message,
        "createTime": createTime.toIso8601String(),
      };
}
