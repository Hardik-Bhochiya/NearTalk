import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _filter = 'All'; // 'All', 'Communities', 'Direct'

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return DateFormat('hh:mm a').format(dt);
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final rooms = chatProvider.rooms;

    final filteredRooms = rooms.where((r) {
      if (_filter == 'Communities') return r.isGroup;
      if (_filter == 'Direct') return !r.isGroup;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            tooltip: 'New Message',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select a member from community to start direct chat')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Communities', 'Direct'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Chat Rooms List
          Expanded(
            child: filteredRooms.isEmpty
                ? const Center(child: Text('No active conversations'))
                : ListView.separated(
                    itemCount: filteredRooms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return ListTile(
                        onTap: () {
                          chatProvider.markRoomAsRead(room.id);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatConversationScreen(roomId: room.id),
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: room.isGroup
                                    ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                room.avatarEmoji ?? (room.isGroup ? '💬' : '👤'),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            if (room.isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF151C2C) : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                room.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(room.lastMessageTime),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: room.unreadCount > 0
                                    ? theme.primaryColor
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                room.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontWeight: room.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (room.unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${room.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
