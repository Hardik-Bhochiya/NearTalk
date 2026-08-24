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
    'Can someone share the PDF notes? 📚',
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _isTypingText) {
        setState(() => _isTypingText = hasText);
      }
    });
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(room.avatarEmoji ?? '💬', style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 12),
              Text(
                room.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                room.isGroup ? 'Campus Group • Active Discussion' : 'Direct Campus Chat',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF7C3AED)),
                title: const Text('Mute Notifications'),
                trailing: Switch(value: false, onChanged: (v) {}),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF7C3AED)),
                title: const Text('Media, Links & Docs'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
                title: const Text('Report Conversation', style: TextStyle(color: Colors.redAccent)),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chatProvider = context.watch<ChatProvider>();
    final room = chatProvider.rooms.firstWhere(
      (r) => r.id == widget.roomId,
      orElse: () => chatProvider.rooms.first,
    );

    final messages = chatProvider.getMessages(widget.roomId);
    final isTyping = chatProvider.isTyping(widget.roomId);
    final typingUserName = chatProvider.getTypingUser(widget.roomId);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF151C2C) : Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        title: InkWell(
          onTap: () => _showRoomDetailsModal(context, room),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFEDE9FE),
                    child: Text(
                      room.avatarEmoji ?? '💬',
                      style: const TextStyle(fontSize: 18),
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
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF151C2C) : Colors.white,
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
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      isTyping
                          ? '${typingUserName ?? "Peer"} is typing...'
                          : (room.subtitle ?? (room.isOnline ? 'Online' : 'Offline')),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isTyping ? const Color(0xFF7C3AED) : const Color(0xFF64748B),
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
            icon: const Icon(Icons.info_outline_rounded),
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
              color: const Color(0xFFFCE7F3),
              child: const Row(
                children: [
                  Icon(Icons.masks_rounded, size: 16, color: Color(0xFFDB2777)),
                  SizedBox(width: 8),
                  Text(
                    'Anonymous Chat Active: Your name is masked as Anonymous Peer',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFBE185D)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${typingUserName ?? "Peer"} is typing...',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF7C3AED), fontWeight: FontWeight.w500),
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
                );
              },
            ),
          ),

          // Quick Replies Chips
          Container(
            height: 38,
            color: isDark ? const Color(0xFF151C2C) : Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final qr = _quickReplies[index];
                return ActionChip(
                  label: Text(qr, style: const TextStyle(fontSize: 11.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide.none,
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
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151C2C) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment (+) button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF7C3AED), size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ChatAttachmentSheet.show(context, _handleAttachment),
                  ),
                  const SizedBox(width: 6),

                  // Anonymous toggle icon button
                  IconButton(
                    icon: Icon(
                      _isAnonymousChat ? Icons.masks_rounded : Icons.masks_outlined,
                      color: _isAnonymousChat ? const Color(0xFFDB2777) : const Color(0xFF94A3B8),
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
                      decoration: InputDecoration(
                        hintText: _isAnonymousChat ? 'Message anonymously...' : 'Type a message...',
                        hintStyle: const TextStyle(fontSize: 13.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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

                  // Send or Mic Voice Button
                  InkWell(
                    onTap: () {
                      if (_isTypingText) {
                        _sendMessage();
                      } else {
                        _handleAttachment('audio', 'Voice note');
                      }
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
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
