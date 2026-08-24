import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/mock_data_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _notifications = List.from(MockDataService.initialNotifications);
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
    String? targetId,
    String iconEmoji = '🔔',
  }) {
    final newNotif = NotificationItem(
      id: MockDataService.generateId(),
      title: title,
      message: message,
      timeAgo: 'Just now',
      type: type,
      targetId: targetId,
      isRead: false,
      iconEmoji: iconEmoji,
    );
    _notifications.insert(0, newNotif);
    notifyListeners();
  }
}
