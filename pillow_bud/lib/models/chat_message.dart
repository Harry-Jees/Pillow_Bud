class ChatMessage {
  final String id;
  final String text;
  final bool isFromBud;
  final DateTime timestamp;
  final String sessionId;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromBud,
    required this.timestamp,
    required this.sessionId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isFromBud: json['isFromBud'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sessionId: json['sessionId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isFromBud': isFromBud,
        'timestamp': timestamp.toIso8601String(),
        'sessionId': sessionId,
      };
}

class ChatSession {
  final String id;
  final String userName;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastModified;

  ChatSession({
    required this.id,
    required this.userName,
    required this.messages,
    required this.createdAt,
    required this.lastModified,
  });
}
