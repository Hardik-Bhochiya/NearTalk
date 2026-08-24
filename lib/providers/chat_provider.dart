import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatRoom> _rooms = [];
  final Map<String, List<ChatMessage>> _roomMessages = {};
  final Map<String, bool> _typingIndicators = {};

  List<ChatRoom> get rooms => _rooms;

  ChatProvider() {
    _rooms = List.from(MockDataService.initialChatRooms);
    for (var m in MockDataService.initialMessages) {
      if (!_roomMessages.containsKey(m.roomId)) {
        _roomMessages[m.roomId] = [];
      }
      _roomMessages[m.roomId]!.add(m);
    }
  }

  List<ChatMessage> getMessages(String roomId) {
    return _roomMessages[roomId] ?? [];
  }

  bool isTyping(String roomId) => _typingIndicators[roomId] ?? false;

  void markRoomAsRead(String roomId) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1 && _rooms[index].unreadCount > 0) {
      _rooms[index] = _rooms[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void sendMessage({
    required String roomId,
    required String content,
    required User currentUser,
  }) {
    final newMessage = ChatMessage(
      id: MockDataService.generateId(),
      roomId: roomId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderAvatar: currentUser.avatarUrl,
      content: content,
      timestamp: DateTime.now(),
      isMine: true,
    );

    if (!_roomMessages.containsKey(roomId)) {
      _roomMessages[roomId] = [];
    }
    _roomMessages[roomId]!.add(newMessage);

    // Update room last message
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        lastMessage: content,
        lastMessageTime: DateTime.now(),
      );
    }

    notifyListeners();

    // Trigger realistic auto-response simulation for testing
    _simulateIncomingReply(roomId, content);
  }

  void _simulateIncomingReply(String roomId, String userMessage) {
    _typingIndicators[roomId] = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 1400), () {
      _typingIndicators[roomId] = false;

      final room = _rooms.firstWhere((r) => r.id == roomId, orElse: () => _rooms.first);
      String replyText = 'Thanks for reaching out! Let me know if you need anything else on campus.';
      String senderName = room.isGroup ? 'Campus Moderator' : room.title;
      String senderId = 'sim-user-1';

      if (userMessage.toLowerCase().contains('hi') || userMessage.toLowerCase().contains('hello')) {
        replyText = 'Hey there! How is your semester going so far?';
      } else if (userMessage.toLowerCase().contains('where') || userMessage.toLowerCase().contains('location')) {
        replyText = 'It is located right near the South Quad, right across from the dining hall!';
      } else if (userMessage.toLowerCase().contains('time') || userMessage.toLowerCase().contains('when')) {
        replyText = 'Usually around 4:30 PM on weekdays.';
      }

      final autoMsg = ChatMessage(
        id: MockDataService.generateId(),
        roomId: roomId,
        senderId: senderId,
        senderName: senderName,
        content: replyText,
        timestamp: DateTime.now(),
        isMine: false,
      );

      _roomMessages[roomId]?.add(autoMsg);

      final rIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (rIndex != -1) {
        _rooms[rIndex] = _rooms[rIndex].copyWith(
          lastMessage: replyText,
          lastMessageTime: DateTime.now(),
        );
      }

      notifyListeners();
    });
  }

  ChatRoom getOrCreateCommunityRoom(String communityId, String communityName, String iconEmoji) {
    final existing = _rooms.firstWhere(
      (r) => r.communityId == communityId,
      orElse: () {
        final newRoom = ChatRoom(
          id: 'room-$communityId',
          title: '$communityName Chat',
          subtitle: 'Community Channel',
          avatarEmoji: iconEmoji,
          communityId: communityId,
          isGroup: true,
          lastMessage: 'Welcome to $communityName live chat!',
          lastMessageTime: DateTime.now(),
          isOnline: true,
        );
        _rooms.insert(0, newRoom);
        return newRoom;
      },
    );
    return existing;
  }
}
