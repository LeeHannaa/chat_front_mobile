class Message {
  Message({
    required this.id,
    required this.name,
    required this.userId,
    required this.message,
    required this.roomId,
    required this.createTime,
  });
  final int id;
  final String name;
  final int userId;
  final String message;
  final int roomId;
  final String createTime;

  @override
  String toString() {
    return '$name $message (ID: $id, UserId: $userId, Num: $roomId, Date: $createTime)';
  }
}
