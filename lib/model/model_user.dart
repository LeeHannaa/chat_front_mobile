class User {
  User({
    required this.userIdx,
    required this.userId,
  });
  final int userIdx;
  final String userId;

  @override
  String toString() {
    return '$userId (id: $userIdx)';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(userIdx: json['userIdx'] ?? 0, userId: json['userId'] ?? '');
  }
}
