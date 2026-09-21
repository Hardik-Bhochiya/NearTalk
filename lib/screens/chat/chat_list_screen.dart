import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/user.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final String _activeFilter = 'All'; // 'All', 'Friends', 'Communities'

  // Instagram DM Notes Statuses for campus simulation
  final List<Map<String, String>> _campusNotes = [
    {'name': 'You', 'handle': 'hardik_07', 'note': 'Sharing note... 💭', 'avatar': '🎓', 'isUser': 'true'},
    {'name': 'Rahul', 'handle': 'rahul_ce', 'note': 'In Library 📚', 'avatar': '💻', 'isUser': 'false'},
    {'name': 'Priya', 'handle': 'priya_it', 'note': 'Canteen tea ☕', 'avatar': '🎨', 'isUser': 'false'},
    {'name': 'Aman', 'handle': 'aman_ddu', 'note': 'Coding Hackathon ⚡', 'avatar': '🚀', 'isUser': 'false'},
    {'name': 'Sneha', 'handle': 'sneha_ec', 'note': 'Lab exams tmrw 📝', 'avatar': '🌟', 'isUser': 'false'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('MMM d').format(dt);
  }

  void _showSwitchAccountDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUsername = auth.currentUser?.username ?? '';

    final demoUsers = [
      {'name': 'Hardik Bhochiya', 'username': 'hardik', 'role': 'Host / Presenter'},
      {'name': 'Rahul Patel', 'username': 'rahul_ce', 'role': 'Demo Friend / Peer'},
      {'name': 'Priya Shah', 'username': 'priya_it', 'role': 'Campus Peer'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1.5)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF30363D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Switch Account',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Switch between demo student accounts to test live messaging',
                style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
              ),
              const SizedBox(height: 16),
              ...demoUsers.map((u) {
                final isCurrent = u['username'] == currentUsername;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF21262D),
                    child: Text(
                      u['name']![0],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(u['name']!, style: const TextStyle(color: Color(0xFFF0F6FC), fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 6),
                      Text('@${u['username']}', style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 12)),
                    ],
                  ),
                  subtitle: Text(u['role']!, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11.5)),
                  trailing: isCurrent
                      ? const Chip(
                          label: Text('Active', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: Color(0xFF238636),
                          padding: EdgeInsets.zero,
                          side: BorderSide.none,
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF21262D),
                            foregroundColor: const Color(0xFF58A6FF),
                            side: const BorderSide(color: Color(0xFF30363D)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await auth.login(u['username']!, 'password123');
                          },
                          child: const Text('Switch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showFriendRequestsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final incoming = auth.getPendingIncomingRequests();
            final outgoing = auth.getPendingOutgoingRequests();

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1.5)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF30363D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Message Requests',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF0F6FC),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21262D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF30363D)),
                        ),
                        child: Text(
                          '${incoming.length} new',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Accept connection requests to start direct messaging',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: incoming.isEmpty && outgoing.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mark_chat_read_outlined, size: 48, color: Color(0xFF8B949E)),
                                SizedBox(height: 12),
                                Text(
                                  'No pending message requests',
                                  style: TextStyle(color: Color(0xFFF0F6FC), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              ...incoming.map((req) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D1117),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF30363D)),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFF21262D),
                                        child: Text(
                                          req.senderName.isNotEmpty ? req.senderName[0].toUpperCase() : '?',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              req.senderName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC), fontSize: 13.5),
                                            ),
                                            Text(
                                              '@${req.senderUsername}',
                                              style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 11.5, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              auth.respondFriendRequest(req.id, 'declined');
                                            },
                                            child: const Text('Decline', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              auth.respondFriendRequest(req.id, 'accepted');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF238636),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final friends = auth.getFriends();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1.5)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF30363D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'New Message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a friend to start direct messaging',
              style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: friends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_rounded, size: 40, color: Color(0xFF8B949E)),
                          const SizedBox(height: 12),
                          const Text(
                            'No Connected Friends Yet',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Search for students in Explore or Home to connect!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF8B949E), fontSize: 12.5),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: friends.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFF21262D)),
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF21262D),
                            child: Text(friend.avatarUrl ?? '🎓', style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(
                            friend.name,
                            style: const TextStyle(color: Color(0xFFF0F6FC), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            friend.handle,
                            style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF58A6FF), size: 20),
                          onTap: () {
                            Navigator.pop(ctx);
                            final chatProvider = context.read<ChatProvider>();
                            final room = chatProvider.startPersonalChat(peerUser: friend, currentUser: currentUser);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ChatConversationScreen(roomId: room.id)),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;
    final chatProvider = context.watch<ChatProvider>();
    final allRooms = chatProvider.rooms;
    final pendingIncoming = auth.getPendingIncomingRequests();

    // Restrict direct messages to mutual friends, keep community groups accessible
    final rooms = allRooms.where((r) {
      if (r.isGroup) return true;
      if (currentUser == null) return false;
      final otherHandle = r.id.replaceFirst('dm-', '').split('_').firstWhere(
            (u) => u.toLowerCase() != currentUser.username.toLowerCase(),
            orElse: () => '',
          );
      return auth.areFriends(otherHandle);
    }).toList();

    final filteredRooms = rooms.where((r) {
      final matchesFilter = (_activeFilter == 'All') ||
          (_activeFilter == 'Communities' && r.isGroup) ||
          (_activeFilter == 'Friends' && !r.isGroup);

      final matchesSearch = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: InkWell(
          onTap: () => _showSwitchAccountDialog(context),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentUser?.handle ?? '@hardik_07',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFFF0F6FC),
                  letterSpacing: -0.4,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFFF0F6FC)),
            ],
          ),
        ),
        actions: [
          // Requests / Friend Requests Icon with Badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.group_add_outlined, size: 23),
                color: const Color(0xFFF0F6FC),
                tooltip: 'Requests',
                onPressed: () => _showFriendRequestsSheet(context),
              ),
              if (pendingIncoming.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF85149),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    alignment: Alignment.center,
                    child: Text(
                      '${pendingIncoming.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          // Compose / New Chat Icon
          IconButton(
            icon: const Icon(Icons.edit_square, size: 20),
            color: const Color(0xFFF0F6FC),
            tooltip: 'New Message',
            onPressed: () => _showNewChatDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Instagram Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 18, color: Color(0xFF8B949E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 13.5),
                      decoration: const InputDecoration(
                        hintText: 'Search chats...',
                        hintStyle: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.cancel_rounded, size: 16, color: Color(0xFF8B949E)),
                    ),
                ],
              ),
            ),
          ),

          // 2. Instagram DM Notes Carousel
          _buildNotesCarousel(currentUser),

          // 3. Section Header: "Messages" + Filter Pills
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0F6FC),
                  ),
                ),
                if (pendingIncoming.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showFriendRequestsSheet(context),
                    child: Text(
                      '${pendingIncoming.length} Requests',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF58A6FF),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Chat Messages List
          Expanded(
            child: filteredRooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Color(0xFF8B949E)),
                        const SizedBox(height: 12),
                        const Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap the compose icon in the top right to start a chat!',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF8B949E)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      final isGroup = room.isGroup;
                      final unread = room.unreadCount > 0;

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatConversationScreen(roomId: room.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              // Avatar with Online Status
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFF21262D),
                                    child: Text(
                                      room.avatarEmoji ?? (isGroup ? '👥' : '🎓'),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF238636),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF0D1117), width: 2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Chat Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                                        color: const Color(0xFFF0F6FC),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            room.lastMessage.isNotEmpty ? room.lastMessage : 'Tap to chat',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                                              color: unread ? const Color(0xFFF0F6FC) : const Color(0xFF8B949E),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '• ${_formatTime(room.lastMessageTime)}',
                                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Trailing: Unread Blue Indicator or Camera
                              if (unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF58A6FF),
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(Icons.camera_alt_outlined, size: 20, color: Color(0xFF8B949E)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Instagram DM Notes Bar ---
  Widget _buildNotesCarousel(User? user) {
    return Container(
      height: 106,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _campusNotes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = _campusNotes[index];
          final isMe = item['isUser'] == 'true';

          return SizedBox(
            width: 72,
            child: Column(
              children: [
                // Thought Note Bubble above Avatar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Text(
                    item['note']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Color(0xFFF0F6FC), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),

                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF161B22),
                      child: Text(
                        isMe ? (user?.avatarUrl ?? '🎓') : item['avatar']!,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    if (isMe)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF58A6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 12, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 3),

                // Name
                Text(
                  item['name']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
