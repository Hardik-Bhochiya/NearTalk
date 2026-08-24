class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String type; // 'reply', 'helpful', 'community', 'announcement'
  final String? targetId;
  final bool isRead;
  final String iconEmoji;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    this.targetId,
    this.isRead = false,
    this.iconEmoji = '🔔',
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    String? type,
    String? targetId,
    bool? isRead,
    String? iconEmoji,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      isRead: isRead ?? this.isRead,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }
}
