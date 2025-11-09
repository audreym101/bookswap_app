class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}