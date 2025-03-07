class ChatRoom {
  ChatRoom({
    required this.id,
    required this.name,
    required this.lastmsg,
    required this.num,
    required this.dateTime,
  });
  final int id;
  final String name;
  final String lastmsg;
  final int num;
  final DateTime dateTime;

  @override
  String toString() {
    return '$name $lastmsg (ID: $id, Num: $num, Date: ${dateTime.toLocal()})';
  }
}
