class User {
  User({
    required this.id,
    required this.name,
  });
  final int id;
  final String name;

  @override
  String toString() {
    return '$name (id: $id)';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}
