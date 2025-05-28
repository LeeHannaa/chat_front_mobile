class ChatRoomInfo {
  final int roomId;
  final String name;

  ChatRoomInfo({
    required this.roomId,
    required this.name,
  });

  factory ChatRoomInfo.fromJson(Map<String, dynamic> json) {
    return ChatRoomInfo(
      roomId: json['roomId'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'name': name,
    };
  }
}
