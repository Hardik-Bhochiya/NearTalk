import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/chat_attachment_sheet.dart';

class ChatConversationScreen extends StatefulWidget {
  final String roomId;
  const ChatConversationScreen({super.key, required this.roomId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAnonymousChat = false;
  bool _isTypingText = false;

  final List<String> _quickReplies = [
    'Where is this located? 📍',
    'What are the timings? ⏰',
    'Thanks for the help! 🙌',
    'Is it open right now? 🚪',
    'Can someone share the notes? 📚',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      chatProvider.joinRoom(widget.roomId, auth.currentUser?.name ?? 'User');
      chatProvider.markRoomAsRead(widget.roomId);
    });

    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _isTypingText) {
        setState(() => _isTypingText = hasText);
        if (mounted) {
          final auth = context.read<AuthProvider>();
          final chatProvider = context.read<ChatProvider>();
          if (hasText) {
            chatProvider.startTyping(widget.roomId, auth.currentUser?.name ?? 'User');
          } else {
            chatProvider.stopTyping(widget.roomId, auth.currentUser?.name ?? 'User');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    try {
      final auth = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      chatProvider.stopTyping(widget.roomId, auth.currentUser?.name ?? 'User');
      chatProvider.leaveRoom(widget.roomId, auth.currentUser?.name ?? 'User');
    } catch (_) {}
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? customText]) {
    final text = (customText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(
      roomId: widget.roomId,
      content: text,
      currentUser: user,
      isAnonymous: _isAnonymousChat,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleAttachment(String type, String title) {
    String simulatedContent = '📎 Shared $title';
    if (type == 'photo') simulatedContent = '📷 [Campus Photo shared]';
    if (type == 'location') simulatedContent = '📍 [DDU Main Campus: 22.6841° N, 72.8805° E]';
    if (type == 'document') simulatedContent = '📄 [MidSem_Syllabus_2026.pdf]';
    if (type == 'poll') simulatedContent = '📊 Poll: Who is coming to the campus library today?';
    if (type == 'audio') simulatedContent = '🎙️ Voice note (0:14)';

    _sendMessage(simulatedContent);
  }

  void _showRoomDetailsModal(BuildContext context, dynamic room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: Color(0xFF30363D))),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF21262D),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(room.avatarEmoji ?? '💬', style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 12),
              Text(
                room.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
              ),
              const SizedBox(height: 4),
              Text(
                room.isGroup ? 'Campus Group • Active Discussion' : (room.subtitle ?? 'Personal Chat'),
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF8B949E)),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF58A6FF)),
                title: const Text('Mute Notifications', style: TextStyle(color: Color(0xFFF0F6FC))),
                trailing: Switch(
                  value: false,
                  activeThumbColor: const Color(0xFF238636),
                  onChanged: (v) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF58A6FF)),
                title: const Text('Media, Links & Docs', style: TextStyle(color: Color(0xFFF0F6FC))),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF8B949E)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Color(0xFFF85149)),
                title: const Text('Report Conversation', style: TextStyle(color: Color(0xFFF85149))),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted to campus moderation.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;
    final currentUserId = currentUser?.id ?? 'user-hardik';

    final chatProvider = context.watch<ChatProvider>();
    final room = chatProvider.rooms.firstWhere(
      (r) => r.id == widget.roomId,
      orElse: () => chatProvider.rooms.isNotEmpty
          ? chatProvider.rooms.first
          : chatProvider.getOrCreateCommunityRoom(widget.roomId, 'Chat', '💬'),
    );

    final allMessages = chatProvider.getMessages(widget.roomId, currentUserId: currentUserId);
    // Filter out messages deleted for this user
    final messages = allMessages.where((m) => !m.deletedForUserIds.contains(currentUserId)).toList();
    final isTyping = chatProvider.isTyping(widget.roomId);
    final typingUserName = chatProvider.getTypingUser(widget.roomId);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF0F6FC)),
        shape: const Border(bottom: BorderSide(color: Color(0xFF30363D), width: 1)),
        title: InkWell(
          onTap: () => _showRoomDetailsModal(context, room),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF21262D),
                    child: Text(
                      room.avatarEmoji ?? (room.isGroup ? '💬' : '👤'),
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                  if (room.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF238636),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF161B22),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF0F6FC),
                      ),
                    ),
                    Text(
                      isTyping
                          ? '${typingUserName ?? "Peer"} is typing...'
                          : (room.subtitle ?? (room.isOnline ? 'Online' : 'Offline')),
                      style: TextStyle(
                        fontSize: 11,
                        color: isTyping ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
                        fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                        fontWeight: isTyping ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF8B949E)),
            onPressed: () => _showRoomDetailsModal(context, room),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Anonymous mode warning banner if active
          if (_isAnonymousChat)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFF21262D),
              child: const Row(
                children: [
                  Icon(Icons.masks_rounded, size: 16, color: Color(0xFFF0883E)),
                  SizedBox(width: 8),
                  Text(
                    'Anonymous Mode: Your identity is masked',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFF0883E)),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Live typing indicator bubble
                if (index == messages.length && isTyping) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF30363D)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58A6FF)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${typingUserName ?? "Peer"} is typing...',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF58A6FF), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final msg = messages[index];
                return ChatBubble(
                  message: msg,
                  showSenderName: room.isGroup,
                  currentUserId: currentUserId,
                  onLike: () => chatProvider.toggleLikeMessage(widget.roomId, msg.id, currentUserId),
                  onDislike: () => chatProvider.toggleDislikeMessage(widget.roomId, msg.id, currentUserId),
                  onEdit: (newText) => chatProvider.editMessage(widget.roomId, msg.id, newText),
                  onDelete: (forEveryone) => chatProvider.deleteMessage(widget.roomId, msg.id, forEveryone: forEveryone, userId: currentUserId),
                );
              },
            ),
          ),

          // Quick Replies Chips
          Container(
            height: 38,
            color: const Color(0xFF161B22),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final qr = _quickReplies[index];
                return ActionChip(
                  label: Text(qr, style: const TextStyle(fontSize: 11.5, color: Color(0xFFF0F6FC))),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: const Color(0xFF21262D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF30363D)),
                  ),
                  onPressed: () => _sendMessage(qr),
                );
              },
            ),
          ),

          // Input Bar with Attachment, Voice/Send, and Anon toggle
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment (+) button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF58A6FF), size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ChatAttachmentSheet.show(context, _handleAttachment),
                  ),
                  const SizedBox(width: 6),

                  // Anonymous toggle icon button
                  IconButton(
                    icon: Icon(
                      _isAnonymousChat ? Icons.masks_rounded : Icons.masks_outlined,
                      color: _isAnonymousChat ? const Color(0xFFF0883E) : const Color(0xFF8B949E),
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Toggle Anonymous Mode',
                    onPressed: () {
                      setState(() => _isAnonymousChat = !_isAnonymousChat);
                    },
                  ),
                  const SizedBox(width: 8),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _isAnonymousChat ? 'Message anonymously...' : 'Type a message...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8B949E)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF30363D)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF30363D)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF58A6FF)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0D1117),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send or Mic Voice Button - High Contrast Visible Button
                  InkWell(
                    onTap: () {
                      if (_isTypingText) {
                        _sendMessage();
                      } else {
                        _handleAttachment('audio', 'Voice note');
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636), // High contrast GitHub Green
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x33FFFFFF), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF238636).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isTypingText ? Icons.send_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
