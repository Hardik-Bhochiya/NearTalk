import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';

class ChatConversationScreen extends StatefulWidget {
  final String roomId;
  const ChatConversationScreen({super.key, required this.roomId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _quickReplies = [
    'Where is this located? 📍',
    'What time is it? ⏰',
    'Thanks for the help! 🙌',
    'Is it open right now? 🚪',
  ];

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chatProvider = context.watch<ChatProvider>();
    final room = chatProvider.rooms.firstWhere(
      (r) => r.id == widget.roomId,
      orElse: () => chatProvider.rooms.first,
    );

    final messages = chatProvider.getMessages(widget.roomId);
    final isTyping = chatProvider.isTyping(widget.roomId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
              child: Text(
                room.avatarEmoji ?? '💬',
                style: const TextStyle(fontSize: 18),
              ),
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
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isTyping ? 'typing...' : (room.subtitle ?? (room.isOnline ? 'Online' : 'Offline')),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isTyping ? theme.primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat details: ${room.title}')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 1.8),
                              ),
                              SizedBox(width: 8),
                              Text('Typing...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                );
              },
            ),
          ),

          // Quick Replies Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final qr = _quickReplies[index];
                return ActionChip(
                  label: Text(qr, style: const TextStyle(fontSize: 11.5)),
                  padding: EdgeInsets.zero,
                  onPressed: () => _sendMessage(qr),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151C2C) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message ${room.title}...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _sendMessage(),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
