class ChatMessage {
  final String text;
  final String role;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.imageUrl,
  });

  bool get isUserMessage => role == "user";
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
