enum MessageType { text, image, system }

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime timestamp;
  final bool isMine;
  final bool isAnonymous;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    required this.isMine,
    this.isAnonymous = false,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isMine': isMine,
      'isAnonymous': isAnonymous,
      'type': type.name,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final sId = json['senderId'] as String;
    return ChatMessage(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      senderId: sId,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String?,
      content: json['content'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isMine: currentUserId != null ? (sId == currentUserId) : (json['isMine'] as bool? ?? false),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}
