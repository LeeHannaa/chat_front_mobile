class Apt {
  Apt({
    required this.idx,
    required this.aptName,
    required this.userId,
  });
  final int idx;
  final String aptName;
  final int userId;

  @override
  String toString() {
    return '$aptName (ID: $idx, userId: $userId)';
  }

  factory Apt.fromJson(Map<String, dynamic> json) {
    return Apt(
        idx: json['idx'] ?? 0,
        aptName: json['aptName'] ?? '',
        userId: json['userId'] ?? 0);
  }
}
