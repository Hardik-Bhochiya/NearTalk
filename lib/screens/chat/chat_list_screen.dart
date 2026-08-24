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
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return DateFormat('hh:mm a').format(dt);
    return DateFormat('MMM d').format(dt);
  }

  void _showNewMessageDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final campusPeers = [
      {'name': 'Rahul Patel', 'role': 'DDU CE 3rd Year • Community Mentor', 'emoji': '👨‍💻'},
      {'name': 'Priya Shah', 'role': 'DDU IT 2nd Year • Sports Rep', 'emoji': '👩‍🔬'},
      {'name': 'Aniket Joshi', 'role': 'DDU Hostel Rep', 'emoji': '🏠'},
      {'name': 'Campus Admin Desk', 'role': 'Official Student Helpdesk', 'emoji': '🎓'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a Conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'DDU Campus Peers',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            ...campusPeers.map((peer) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEDE9FE),
                  child: Text(peer['emoji'] as String, style: const TextStyle(fontSize: 18)),
                ),
                title: Text(
                  peer['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  peer['role'] as String,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF7C3AED), size: 18),
                onTap: () {
                  Navigator.pop(ctx);
                  final chatProvider = context.read<ChatProvider>();
                  final room = chatProvider.getOrCreateCommunityRoom('dm-rahul', peer['name'] as String, '💬');
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChatConversationScreen(roomId: room.id)),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final rooms = chatProvider.rooms;

    final filteredRooms = rooms.where((r) {
      final matchesFilter = (_filter == 'All') ||
          (_filter == 'Communities' && r.isGroup) ||
          (_filter == 'Direct' && !r.isGroup);

      final matchesSearch = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
        elevation: 0,
        title: const Text(
          'Chats & Channels',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Color(0xFF7C3AED)),
            tooltip: 'New Message',
            onPressed: () => _showNewMessageDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151C2C) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search chats, groups, messages...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF7C3AED)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Active Campus Buddies Story Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildOnlineBuddy(
                    name: 'Rahul P.',
                    emoji: '👨‍💻',
                    isOnline: true,
                    onTap: () => _showNewMessageDialog(context),
                  ),
                  const SizedBox(width: 14),
                  _buildOnlineBuddy(
                    name: 'Priya S.',
                    emoji: '👩‍🔬',
                    isOnline: true,
                    onTap: () => _showNewMessageDialog(context),
                  ),
                  const SizedBox(width: 14),
                  _buildOnlineBuddy(
                    name: 'DDU Hostel',
                    emoji: '🏠',
                    isOnline: true,
                    onTap: () => _showNewMessageDialog(context),
                  ),
                  const SizedBox(width: 14),
                  _buildOnlineBuddy(
                    name: 'Aniket J.',
                    emoji: '⚽',
                    isOnline: true,
                    onTap: () => _showNewMessageDialog(context),
                  ),
                  const SizedBox(width: 14),
                  _buildOnlineBuddy(
                    name: 'ACM Lead',
                    emoji: '💻',
                    isOnline: false,
                    onTap: () => _showNewMessageDialog(context),
                  ),
                ],
              ),
            ),
          ),

          // Filter Choice Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['All', 'Communities', 'Direct'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF7C3AED),
                    backgroundColor: isDark ? const Color(0xFF151C2C) : const Color(0xFFF1F5F9),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide.none,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Chat Rooms List
          Expanded(
            child: filteredRooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'No conversations found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: filteredRooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF151C2C) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E384D) : const Color(0xFFF1F5F9),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            chatProvider.markRoomAsRead(room.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatConversationScreen(roomId: room.id),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Stack(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEDE9FE),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  room.avatarEmoji ?? (room.isGroup ? '💬' : '👤'),
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              if (room.isOnline)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
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
                                    fontWeight: room.unreadCount > 0 ? FontWeight.w800 : FontWeight.w700,
                                    fontSize: 14.5,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime(room.lastMessageTime),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: room.unreadCount > 0
                                      ? const Color(0xFF7C3AED)
                                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    room.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
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
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${room.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageDialog(context),
        backgroundColor: const Color(0xFF6D28D9),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }

  Widget _buildOnlineBuddy({
    required String name,
    required String emoji,
    required bool isOnline,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOnline ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  color: const Color(0xFFEDE9FE),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
