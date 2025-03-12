class ChatRoom {
  ChatRoom({
    required this.id,
    required this.name, // 매물 이름 = 채팅방 이름
    required this.lastmsg,
    required this.counselId,
    required this.consultId,
    required this.num,
    required this.dateTime,
  });
  final int id;
  final String name;
  final String lastmsg;
  final int counselId; // 매물 문의자
  final int consultId; // 매물 소유자
  final int num;
  final DateTime dateTime;

  @override
  String toString() {
    return '$name $lastmsg (ID: $id, consultId : $consultId, counselId: $counselId, Num: $num, Date: ${dateTime.toLocal()})';
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
        id: json['id'],
        name: json['name'],
        lastmsg: json['lastMsg'] ?? '',
        counselId: json['counselId'],
        consultId: json['consultId'],
        num: json['memberNum'],
        dateTime: DateTime.parse(json['regDate']));
  }
}
