class Message {
  Message({
    required this.id,
    required this.name,
    required this.writerId,
    this.message,
    required this.roomId,
    required this.createTime,
    this.isDelete,
    this.unreadCount,
  });
  final String id;
  final String name;
  final int writerId;
  String? message;
  final int roomId;
  final DateTime createTime;
  bool? isDelete;
  int? unreadCount;

  @override
  String toString() {
    return '$name $message (ID: $id, UserId: $writerId, Num: $roomId, Date: $createTime)';
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      name: json['writerName'] ?? 'Unknown',
      writerId: json['writerId'] ?? 0,
      roomId: json['roomId'] ?? 0,
      message: json['msg'] ?? '',
      createTime: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      isDelete: json['delete'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
    );
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

  Message copyWith({
    String? id,
    String? message,
    int? writerId,
    String? name,
    int? roomId,
    DateTime? createTime,
    bool? isDelete,
    int? unreadCount,
  }) {
    return Message(
      id: id ?? this.id,
      message: message ?? this.message,
      writerId: writerId ?? this.writerId,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      createTime: createTime ?? this.createTime,
      isDelete: isDelete ?? this.isDelete,
      unreadCount: unreadCount ?? this.unreadCount,
    );
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
