import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/chat_message.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  static bool disabledForTests = false;

  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<ChatMessage> get onMessageReceived => _messageController.stream;
  Stream<Map<String, dynamic>> get onTypingStatus => _typingController.stream;
  bool get isConnected => _isConnected;

  String get socketUrl {
    if (kIsWeb) return 'http://localhost:5000/chat';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5000/chat'
        : 'http://localhost:5000/chat';
  }

  void connect() {
    if (disabledForTests || (_socket != null && _isConnected)) return;

    try {
      _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(3)
            .build(),
      );

      _socket?.connect();

      _socket?.onConnect((_) {
        _isConnected = true;
        debugPrint('[SocketService] Connected to NearTalk WebSocket server');
      });

      _socket?.onDisconnect((_) {
        _isConnected = false;
        debugPrint('[SocketService] Disconnected from WebSocket server');
      });

      _socket?.on('receive_message', (data) {
        if (data != null && data is Map<String, dynamic>) {
          final msg = ChatMessage.fromJson(data);
          _messageController.add(msg);
        }
      });

      _socket?.on('user_typing', (data) {
        if (data != null && data is Map<String, dynamic>) {
          _typingController.add(data);
        }
      });
    } catch (e) {
      debugPrint('[SocketService] Socket error: $e');
    }
  }

  void joinRoom(String roomId, String userName) {
    if (disabledForTests) return;
    _socket?.emit('join_room', {'roomId': roomId, 'userName': userName});
  }

  void leaveRoom(String roomId, String userName) {
    if (disabledForTests) return;
    _socket?.emit('leave_room', {'roomId': roomId, 'userName': userName});
  }

  void sendMessage({
    required String roomId,
    required String content,
    required String senderId,
    required String senderName,
    required bool isAnonymous,
  }) {
    if (disabledForTests) return;
    _socket?.emit('send_message', {
      'roomId': roomId,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'isAnonymous': isAnonymous,
    });
  }

  void startTyping(String roomId, String userName) {
    if (disabledForTests) return;
    _socket?.emit('typing_start', {'roomId': roomId, 'userName': userName});
  }

  void stopTyping(String roomId, String userName) {
    if (disabledForTests) return;
    _socket?.emit('typing_stop', {'roomId': roomId, 'userName': userName});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
