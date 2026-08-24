import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showSenderName;
  final Function(String emoji)? onReact;
  final VoidCallback? onReply;

  const ChatBubble({
    super.key,
    required this.message,
    this.showSenderName = true,
    this.onReact,
    this.onReply,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final List<String> _reactions = [];

  void _showReactionMenu() {
    final emojis = ['👍', '❤️', '🔥', '💡', '😂', '🎉'];
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emojis.map((emoji) {
              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    if (!_reactions.contains(emoji)) {
                      _reactions.add(emoji);
                    }
                  });
                  widget.onReact?.call(emoji);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMine = widget.message.isMine;
    final timeStr = DateFormat('hh:mm a').format(widget.message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFFEDE9FE),
              child: Text(
                widget.message.senderName.isNotEmpty ? widget.message.senderName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D28D9),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: _showReactionMenu,
              onDoubleTap: () {
                setState(() {
                  if (!_reactions.contains('❤️')) _reactions.add('❤️');
                });
              },
              child: Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isMine
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMine
                          ? null
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMine ? 18 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 18),
                      ),
                      border: isMine
                          ? null
                          : Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: isMine
                              ? const Color(0x337C3AED)
                              : Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMine && widget.showSenderName) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.message.senderName,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                              if (widget.message.isAnonymous) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('🎭 Anon', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                        ],
                        Text(
                          widget.message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: isMine
                                ? Colors.white
                                : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMine
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ),
                            if (isMine) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.done_all_rounded, size: 14, color: Colors.white),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Floating Reaction Badges
                  if (_reactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 2,
                          children: _reactions.map((r) => Text(r, style: const TextStyle(fontSize: 13))).toList(),
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
