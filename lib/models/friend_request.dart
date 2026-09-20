class FriendRequest {
  final String id;
  final String senderId;
  final String senderUsername;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverUsername;
  final String receiverName;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverUsername,
    required this.receiverName,
    this.status = 'pending',
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  FriendRequest copyWith({
    String? id,
    String? senderId,
    String? senderUsername,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? receiverUsername,
    String? receiverName,
    String? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverUsername: receiverUsername ?? this.receiverUsername,
      receiverName: receiverName ?? this.receiverName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'receiverUsername': receiverUsername,
      'receiverName': receiverName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderUsername: json['senderUsername'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderAvatar: json['senderAvatar'] as String?,
      receiverId: json['receiverId'] as String? ?? '',
      receiverUsername: json['receiverUsername'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
