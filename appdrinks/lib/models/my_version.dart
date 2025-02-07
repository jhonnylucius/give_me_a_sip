class MyVersion {
  final String id;
  final String drinkId;
  final String userId;
  final String text;
  final DateTime createdAt;

  MyVersion({
    required this.id,
    required this.drinkId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drinkId': drinkId,
      'userId': userId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MyVersion.fromMap(Map<String, dynamic> map) {
    return MyVersion(
      id: map['id'],
      drinkId: map['drinkId'],
      userId: map['userId'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
