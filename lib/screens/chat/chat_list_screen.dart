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
  String _filter = 'All'; // 'All', 'Friends', 'Communities'
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: Color(0xFF30363D))),
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
                'Live Demo User Switcher',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Switch accounts to test friend requests and friends-only chat live',
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
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
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
                        'Friend Requests',
                        style: TextStyle(
                          fontSize: 18,
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
                          '${incoming.length} incoming',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Accept requests to unlock 1-on-1 direct messaging',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: incoming.isEmpty && outgoing.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline_rounded, size: 48, color: Color(0xFF8B949E)),
                                const SizedBox(height: 12),
                                const Text(
                                  'No Pending Requests',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFF0F6FC)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Search peers by @username to send a friend request.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _showAddFriendDialog(context);
                                  },
                                  icon: const Icon(Icons.person_add_rounded, size: 16),
                                  label: const Text('Add Friend by @username'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF238636),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              if (incoming.isNotEmpty) ...[
                                const Text(
                                  'INCOMING REQUESTS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B949E),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...incoming.map((req) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
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
                                              onPressed: () => auth.respondFriendRequest(req.id, 'declined'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(0xFF8B949E),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              ),
                                              child: const Text('Decline', style: TextStyle(fontSize: 12)),
                                            ),
                                            const SizedBox(width: 4),
                                            ElevatedButton(
                                              onPressed: () {
                                                auth.respondFriendRequest(req.id, 'accepted');
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('You and @${req.senderUsername} are now friends! 🎉'),
                                                    backgroundColor: const Color(0xFF238636),
                                                  ),
                                                );
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

                              if (outgoing.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'SENT REQUESTS (PENDING)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B949E),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...outgoing.map((req) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
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
                                            req.receiverName.isNotEmpty ? req.receiverName[0].toUpperCase() : '?',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                req.receiverName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC), fontSize: 13.5),
                                              ),
                                              Text(
                                                '@${req.receiverUsername}',
                                                style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 11.5, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF21262D),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF30363D)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.hourglass_top_rounded, size: 12, color: Color(0xFFE3B341)),
                                              SizedBox(width: 4),
                                              Text('Requested', style: TextStyle(fontSize: 11, color: Color(0xFFE3B341), fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
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

  void _showAddFriendDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final searchUserCtrl = TextEditingController();
    List<User> searchResults = auth.knownUsers.where((u) => u.id != currentUser.id).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final pendingOutgoing = auth.getPendingOutgoingRequests();
          final pendingIncoming = auth.getPendingIncomingRequests();

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
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
                  'Add Friend by @username',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0F6FC),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Direct messaging is restricted to friends only. Search an @username to send a request.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                ),
                const SizedBox(height: 14),

                // Username Search Input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: TextField(
                    controller: searchUserCtrl,
                    style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 14),
                    onChanged: (val) {
                      setModalState(() {
                        final q = val.trim().toLowerCase().replaceAll('@', '');
                        if (q.isEmpty) {
                          searchResults = auth.knownUsers.where((u) => u.id != currentUser.id).toList();
                        } else {
                          searchResults = auth.knownUsers.where((u) {
                            return u.id != currentUser.id &&
                                (u.username.toLowerCase().contains(q) || u.name.toLowerCase().contains(q));
                          }).toList();

                          if (searchResults.isEmpty && q.length >= 2) {
                            searchResults = [
                              User(
                                id: 'user-$q',
                                username: q,
                                name: '@$q',
                                firstName: q,
                                lastName: '',
                                email: '$q@ddu.ac.in',
                                campusOrCity: 'DDU Student',
                                majorOrBio: 'NearTalk Peer',
                                reputation: 20,
                              ),
                            ];
                          }
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search username e.g. @rahul_ce, @priya_it',
                      hintStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF58A6FF), size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: searchUserCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: Color(0xFF8B949E)),
                              onPressed: () {
                                searchUserCtrl.clear();
                                setModalState(() {
                                  searchResults = auth.knownUsers.where((u) => u.id != currentUser.id).toList();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Campus Peers',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B949E),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.separated(
                    itemCount: searchResults.length,
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF21262D), height: 1),
                    itemBuilder: (context, index) {
                      final peer = searchResults[index];
                      final isFriend = auth.areFriends(peer.username);
                      final isOutgoingPending = pendingOutgoing.any((r) => r.receiverUsername.toLowerCase() == peer.username.toLowerCase());
                      final isIncomingPending = pendingIncoming.any((r) => r.senderUsername.toLowerCase() == peer.username.toLowerCase());

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF21262D),
                          child: Text(
                            peer.name.isNotEmpty ? peer.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              peer.name,
                              style: const TextStyle(color: Color(0xFFF0F6FC), fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              peer.handle,
                              style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 12),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          peer.majorOrBio ?? 'NearTalk Peer',
                          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isFriend
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF21262D),
                                  foregroundColor: const Color(0xFF58A6FF),
                                  side: const BorderSide(color: Color(0xFF30363D)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                                label: const Text('Chat'),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  final chatProvider = context.read<ChatProvider>();
                                  final room = chatProvider.startPersonalChat(peerUser: peer, currentUser: currentUser);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ChatConversationScreen(roomId: room.id)),
                                  );
                                },
                              )
                            : (isOutgoingPending
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF21262D),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF30363D)),
                                    ),
                                    child: const Text('Requested ⏳', style: TextStyle(color: Color(0xFFE3B341), fontSize: 12, fontWeight: FontWeight.bold)),
                                  )
                                : (isIncomingPending
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF238636),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () {
                                          final req = pendingIncoming.firstWhere((r) => r.senderUsername.toLowerCase() == peer.username.toLowerCase());
                                          auth.respondFriendRequest(req.id, 'accepted');
                                          setModalState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Accepted @${peer.username}! 🎉'), backgroundColor: const Color(0xFF238636)),
                                          );
                                        },
                                        child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      )
                                    : ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF238636),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.person_add_rounded, size: 14),
                                        label: const Text('Add Friend'),
                                        onPressed: () async {
                                          await auth.sendFriendRequest(peer.username);
                                          setModalState(() {});
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Friend request sent to @${peer.username}! 🚀'),
                                                backgroundColor: const Color(0xFF238636),
                                              ),
                                            );
                                          }
                                        },
                                      ))),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
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

    // Direct chats are restricted to mutual friends only!
    final rooms = allRooms.where((r) {
      if (r.isGroup) return true; // Community groups stay accessible to members
      // For direct chats, check if other participant is a friend
      if (currentUser == null) return false;
      final otherHandle = r.id.replaceFirst('dm-', '').split('_').firstWhere(
            (u) => u.toLowerCase() != currentUser.username.toLowerCase(),
            orElse: () => '',
          );
      return auth.areFriends(otherHandle);
    }).toList();

    final filteredRooms = rooms.where((r) {
      final matchesFilter = (_filter == 'All') ||
          (_filter == 'Communities' && r.isGroup) ||
          (_filter == 'Friends' && !r.isGroup);

      final matchesSearch = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (r.subtitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Color(0xFF30363D), width: 1)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chats & Messages',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFFF0F6FC)),
            ),
            InkWell(
              onTap: () => _showSwitchAccountDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFF238636), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Logged in as @${currentUser?.username ?? "hardik"} (tap to switch)',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF58A6FF), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Friend Requests Notification Icon with Badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.group_add_rounded, color: Color(0xFF58A6FF)),
                tooltip: 'Friend Requests',
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
                    child: Text(
                      '${pendingIncoming.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF58A6FF)),
            tooltip: 'Add Friend by @username',
            onPressed: () => _showAddFriendDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF8B949E)),
            tooltip: 'Switch Demo User',
            onPressed: () => _showSwitchAccountDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Pending Friend Requests Banner if any
          if (pendingIncoming.isNotEmpty)
            InkWell(
              onTap: () => _showFriendRequestsSheet(context),
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F6FEB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1F6FEB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_add_rounded, color: Color(0xFF58A6FF), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You have ${pendingIncoming.length} new friend request${pendingIncoming.length > 1 ? "s" : ""}!',
                        style: const TextStyle(color: Color(0xFFF0F6FC), fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                    ),
                    const Text('View', style: TextStyle(color: Color(0xFF58A6FF), fontWeight: FontWeight.bold, fontSize: 12)),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF58A6FF), size: 16),
                  ],
                ),
              ),
            ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 13.5),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search chats by name, @username, or message...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8B949E)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF8B949E)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Color(0xFF8B949E)),
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

          // Filter Choice Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Row(
              children: ['All', 'Friends', 'Communities'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : const Color(0xFF8B949E),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1F6FEB),
                    backgroundColor: const Color(0xFF161B22),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
                      ),
                    ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF161B22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.people_alt_rounded, size: 40, color: Color(0xFF58A6FF)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Friends-Only Direct Messaging',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF0F6FC),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'You can only message peers who are in your Friends list.\nSend a friend request by entering their @username!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF8B949E),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF238636),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Color(0x33FFFFFF)),
                              ),
                            ),
                            icon: const Icon(Icons.person_add_rounded, size: 16),
                            label: const Text('Add Friend by @username', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _showAddFriendDialog(context),
                          ),
                        ],
                      ),
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
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF30363D)),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFF21262D),
                                child: Text(
                                  room.avatarEmoji ?? (room.isGroup ? '💬' : '👤'),
                                  style: const TextStyle(fontSize: 20),
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
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 14.5,
                                    color: const Color(0xFFF0F6FC),
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime(room.lastMessageTime),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: room.unreadCount > 0 ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
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
                                      color: const Color(0xFF8B949E),
                                      fontWeight: room.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (room.unreadCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF238636),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${room.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
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
        onPressed: () => _showAddFriendDialog(context),
        backgroundColor: const Color(0xFF238636),
        foregroundColor: Colors.white,
        tooltip: 'Add Friend by @username',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}
