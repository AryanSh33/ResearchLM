class SimpleConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  SimpleConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SimpleConversation.fromJson(Map<String, dynamic> json) {
    return SimpleConversation(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] ?? 0),
    );
  }
}
