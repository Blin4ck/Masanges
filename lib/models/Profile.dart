class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  final String id;

  final String username;

  final DateTime createdAt;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        username = map['username'] as String,
        createdAt = DateTime.parse(map['created_at'] as String);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Profile{id: $id, username: $username, createdAt: $createdAt}';
  }
}
