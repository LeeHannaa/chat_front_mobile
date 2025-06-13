class Message {
  Message({
    required this.id,
    required this.name,
    required this.writerId,
    this.message,
    required this.roomId,
    required this.cdate,
    this.delete,
    this.unreadCount,
    this.type,
    this.beforeMsgId,
  });
  final int id;
  final String name;
  final int? writerId;
  String? message;
  final int roomId;
  final DateTime cdate;
  bool? delete;
  int? unreadCount;
  String? type;
  int? beforeMsgId;

  @override
  String toString() {
    return '$name $message (ID: $id, UserId: $writerId, Num: $roomId, Date: $cdate)';
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['id'] ?? 0,
        name: json['writerName'] ?? 'Unknown',
        writerId: json['writerId'],
        roomId: json['roomId'] ?? 0,
        message: json['msg'] ?? '',
        cdate: json['cdate'] != null
            ? DateTime.parse(json['cdate'])
            : DateTime.now(),
        delete: json['delete'] ?? false,
        unreadCount: json['unreadCount'] ?? 0,
        type: json['type'] ?? '',
        beforeMsgId: json['beforeMsgId'] ?? 0);
  }

  factory Message.fromJsonSqlite(Map<String, dynamic> json) {
    return Message(
        id: int.parse(json['id'].toString()),
        name: json['name'],
        writerId: json['writerId'],
        roomId: int.parse(json['roomId'].toString()),
        message: json['message'],
        cdate: DateTime.parse(json['cdate']),
        type: json['type'] ?? '');
  }

  Message copyWith({
    int? id,
    String? message,
    int? writerId,
    String? name,
    int? roomId,
    DateTime? cdate,
    bool? delete,
    int? unreadCount,
    String? type,
  }) {
    return Message(
        id: id ?? this.id,
        message: message ?? this.message,
        writerId: writerId ?? this.writerId,
        name: name ?? this.name,
        roomId: roomId ?? this.roomId,
        cdate: cdate ?? this.cdate,
        delete: delete ?? this.delete,
        unreadCount: unreadCount ?? this.unreadCount,
        type: type ?? this.type);
  }

  // 객체 데이터를 데이터베이스에 저장할 수 있는 형태로 변환
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "writerId": writerId,
        "roomId": roomId,
        "message": message,
        "cdate": cdate.toIso8601String(),
        "type": type,
      };
}
