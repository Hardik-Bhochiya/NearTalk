import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatRoom> _rooms = [];
  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, String?> _typingUser = {};
  StreamSubscription<ChatMessage>? _messageSub;
  StreamSubscription<Map<String, dynamic>>? _typingSub;

  List<ChatRoom> get rooms => _rooms;
  String? getTypingUser(String roomId) => _typingUser[roomId];
  bool isTyping(String roomId) => _typingUser[roomId] != null;

  ChatProvider() {
    _rooms = List.from(MockDataService.initialChatRooms);
    _initChat();
  }

  void _initChat() {
    SocketService().connect();

    _messageSub = SocketService().onMessageReceived.listen((msg) {
      if (!_messages.containsKey(msg.roomId)) {
        _messages[msg.roomId] = [];
      }
      _messages[msg.roomId]!.add(msg);

      final index = _rooms.indexWhere((r) => r.id == msg.roomId);
      if (index != -1) {
        _rooms[index] = _rooms[index].copyWith(
          lastMessage: msg.content,
          lastMessageTime: msg.timestamp,
        );
      }
      notifyListeners();
    });

    _typingSub = SocketService().onTypingStatus.listen((data) {
      final roomId = data['roomId'] as String?;
      final userName = data['userName'] as String?;
      final isTypingStatus = data['isTyping'] as bool? ?? false;

      if (roomId != null) {
        _typingUser[roomId] = isTypingStatus ? userName : null;
        notifyListeners();
      }
    });

    _loadRoomsFromApi();
  }

  Future<void> _loadRoomsFromApi() async {
    try {
      final remoteRooms = await ApiService().getChatRooms();
      if (remoteRooms.isNotEmpty) {
        _rooms = remoteRooms;
        notifyListeners();
      }
    } catch (_) {}
  }

  ChatRoom getOrCreateCommunityRoom(String communityId, String communityName, String iconEmoji) {
    final existing = _rooms.firstWhere(
      (r) => r.communityId == communityId,
      orElse: () {
        final newRoom = ChatRoom(
          id: 'room-$communityId',
          title: '$communityName Chat',
          subtitle: 'Community discussion',
          avatarEmoji: iconEmoji,
          communityId: communityId,
          isGroup: true,
          lastMessage: 'Welcome to $communityName live chat!',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          isOnline: true,
          participantIds: ['user-hardik'],
        );
        _rooms.insert(0, newRoom);
        return newRoom;
      },
    );
    return existing;
  }

  void markRoomAsRead(String roomId) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1 && _rooms[index].unreadCount > 0) {
      _rooms[index] = _rooms[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  List<ChatMessage> getMessages(String roomId) {
    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = List.from(
        MockDataService.initialMessages.where((m) => m.roomId == roomId),
      );
      ApiService().getMessages(roomId).then((msgs) {
        if (msgs.isNotEmpty) {
          _messages[roomId] = msgs;
          notifyListeners();
        }
      });
    }
    return _messages[roomId] ?? [];
  }

  void joinRoom(String roomId, String userName) {
    SocketService().joinRoom(roomId, userName);
  }

  void leaveRoom(String roomId, String userName) {
    SocketService().leaveRoom(roomId, userName);
  }

  void startTyping(String roomId, String userName) {
    SocketService().startTyping(roomId, userName);
  }

  void stopTyping(String roomId, String userName) {
    SocketService().stopTyping(roomId, userName);
  }

  void sendMessage({
    required String roomId,
    required String content,
    required User currentUser,
    bool isAnonymous = false,
  }) {
    final newMsg = ChatMessage(
      id: MockDataService.generateId(),
      roomId: roomId,
      senderId: currentUser.id,
      senderName: isAnonymous ? 'Anonymous' : currentUser.name,
      senderAvatar: isAnonymous ? null : currentUser.avatarUrl,
      content: content,
      timestamp: DateTime.now(),
      isMine: true,
      isAnonymous: isAnonymous,
    );

    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = [];
    }
    _messages[roomId]!.add(newMsg);

    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        lastMessage: content,
        lastMessageTime: DateTime.now(),
      );
    }
    notifyListeners();

    SocketService().sendMessage(
      roomId: roomId,
      content: content,
      senderId: currentUser.id,
      senderName: isAnonymous ? 'Anonymous' : currentUser.name,
      isAnonymous: isAnonymous,
    );
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _typingSub?.cancel();
    super.dispose();
  }
}
