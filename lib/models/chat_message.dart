// chat_message.dart
// Simple message model for the Nox AI coach chat interface.

class ChatMessage {
  final String text;
  final bool fromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.fromUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'text': text,
        'fromUser': fromUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        fromUser: json['fromUser'],
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      );
}
