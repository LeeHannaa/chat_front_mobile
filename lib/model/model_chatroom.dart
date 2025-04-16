class ChatRoom {
  ChatRoom({
    required this.id,
    required this.name, // 매물 이름 = 채팅방 이름
    required this.lastmsg,
    // required this.counselId,
    // required this.consultId,
    required this.num,
    required this.dateTime,
    required this.updateLastMsgTime,
    this.unreadCount,
  });
  final int id;
  final String name;
  final String lastmsg;
  // final int counselId; // 매물 문의자
  // final int consultId; // 매물 소유자
  final int num;
  final DateTime dateTime;
  final DateTime updateLastMsgTime;
  final int? unreadCount;

  @override
  String toString() {
    // return '$name $lastmsg (ID: $id, consultId : $consultId, counselId: $counselId, Num: $num, Date: ${dateTime.toLocal()})';
    return '$name $lastmsg (ID: $id, Num: $num, Date: ${dateTime.toLocal()})';
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['roomId'],
      name: json['name'],
      lastmsg: json['lastMsg'] ?? '',
      num: json['memberNum'],
      dateTime: DateTime.parse(json['regDate']),
      updateLastMsgTime: DateTime.parse(json['updateLastMsgTime']),
      unreadCount: json['unreadCount'],
    );
  }

  factory ChatRoom.fromJsonSqlite(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      lastmsg: json['lastmsg'] ?? '',
      num: json['num'],
      dateTime: DateTime.parse(json['dateTime']),
      updateLastMsgTime: DateTime.parse(json['updateLastMsgTime']),
    );
  }

  // 객체 데이터를 데이터베이스에 저장할 수 있는 형태로 변환
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "lastmsg": lastmsg,
        "num": num,
        "dateTime": dateTime.toIso8601String(),
        "updateLastMsgTime": updateLastMsgTime.toIso8601String(),
      };

  ChatRoom copyWith({
    String? lastmsg,
    DateTime? updateLastMsgTime,
    int? unreadCount,
  }) {
    return ChatRoom(
        id: id,
        name: name,
        lastmsg: lastmsg ?? this.lastmsg,
        num: num,
        dateTime: dateTime,
        updateLastMsgTime: updateLastMsgTime ?? this.updateLastMsgTime,
        unreadCount: unreadCount ?? this.unreadCount);
  }
}
