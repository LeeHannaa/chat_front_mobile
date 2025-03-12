class Apt {
  Apt({
    required this.id,
    required this.aptName,
    required this.userId,
    required this.dateTime,
  });
  final int id;
  final String aptName;
  final int userId;
  final DateTime dateTime;

  @override
  String toString() {
    return '$aptName (ID: $id, userId: $userId, Date: ${dateTime.toLocal()})';
  }

  factory Apt.fromJson(Map<String, dynamic> json) {
    return Apt(
        id: json['id'] ?? 0,
        aptName: json['name'] ?? '',
        userId: json['userId'] ?? 0,
        dateTime: DateTime.parse(json['regDate']));
  }
}
