class Message {
  Message({
    required this.id,
    required this.name,
    required this.writerId,
    required this.message,
    required this.roomId,
    required this.createTime,
  });
  final int id;
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
        name: json['name'],
        writerId: json['writerId'],
        roomId: json['roomId'],
        message: json['msg'],
        createTime: DateTime.parse(json['createdDate']));
  }
}
