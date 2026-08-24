import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSenderName;

  const ChatBubble({
    super.key,
    required this.message,
    this.showSenderName = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isMine = message.isMine;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    final bubbleColor = isMine
        ? theme.primaryColor
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));

    final textColor = isMine
        ? Colors.white
        : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A));

    final timeColor = isMine
        ? Colors.white70
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMine && showSenderName) ...[
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: textColor,
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
                          fontSize: 10.5,
                          color: timeColor,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all, size: 13, color: Colors.white70),
                      ],
                    ],
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
