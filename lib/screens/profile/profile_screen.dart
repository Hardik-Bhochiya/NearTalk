import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/community.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/question_card.dart';
import '../community/community_detail_screen.dart';
import '../question/question_detail_screen.dart';
import '../auth/login_screen.dart';
import '../chat/chat_conversation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditProfileSheet(BuildContext context, User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final campusCtrl = TextEditingController(text: user.campusOrCity);
    final bioCtrl = TextEditingController(text: user.majorOrBio ?? 'Tech & Community Builder');
    String selectedAvatar = user.avatarUrl ?? '🎓';
    final availableAvatars = ['🎓', '💻', '⚽', '🚀', '⚡', '🦁', '🦉', '🎨', '🔥', '🌟', '📚', '🌊'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF30363D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
              ),
              const SizedBox(height: 14),

              // Avatar Picker
              const Text(
                'Choose Profile Picture',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF8B949E)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableAvatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final av = availableAvatars[index];
                    final isSel = selectedAvatar == av;
                    return InkWell(
                      onTap: () => setSheetState(() => selectedAvatar = av),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF21262D) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(av, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Color(0xFFF0F6FC)),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: Color(0xFF8B949E)),
                  filled: true,
                  fillColor: const Color(0xFF0D1117),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: campusCtrl,
                style: const TextStyle(color: Color(0xFFF0F6FC)),
                decoration: InputDecoration(
                  labelText: 'Location / City',
                  labelStyle: const TextStyle(color: Color(0xFF8B949E)),
                  filled: true,
                  fillColor: const Color(0xFF0D1117),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioCtrl,
                style: const TextStyle(color: Color(0xFFF0F6FC)),
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: const TextStyle(color: Color(0xFF8B949E)),
                  filled: true,
                  fillColor: const Color(0xFF0D1117),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().updateProfile(
                    name: nameCtrl.text.trim(),
                    campusOrCity: campusCtrl.text.trim(),
                    majorOrBio: bioCtrl.text.trim(),
                    avatarUrl: selectedAvatar,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Color(0xFF238636),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF30363D))),
        title: const Text('Log Out', style: TextStyle(color: Color(0xFFF0F6FC), fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of NearTalk?', style: TextStyle(color: Color(0xFF8B949E))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B949E))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF85149), foregroundColor: Colors.white),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final communityProvider = context.watch<CommunityProvider>();
    final questionProvider = context.watch<QuestionProvider>();

    final user = auth.currentUser;

    if (user == null || auth.isGuest) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1117),
          elevation: 0,
          title: const Text('Profile', style: TextStyle(color: Color(0xFFF0F6FC), fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle_outlined, size: 72, color: Color(0xFF8B949E)),
                const SizedBox(height: 16),
                const Text(
                  'Exploring as Guest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in with your @username to connect with friends, join communities, and chat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF8B949E)),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Sign In / Register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userQuestions = questionProvider.getUserQuestions(user.id);
    final joinedCommunities = communityProvider.joinedCommunities;
    final friends = auth.getFriends();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: Text(
          user.handle,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFF0F6FC)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFF85149)),
            tooltip: 'Log Out',
            onPressed: () => _confirmLogout(context, auth),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instagram Profile Header Row (Avatar + Stats)
                  Row(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          InkWell(
                            onTap: () => _showEditProfileSheet(context, user),
                            borderRadius: BorderRadius.circular(44),
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: const Color(0xFF21262D),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF58A6FF), width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(user.avatarUrl ?? '🎓', style: const TextStyle(fontSize: 36)),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF58A6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Instagram Stats Row: Friends | Communities | Posts
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('Friends', '${friends.length}', () => _tabController.animateTo(1)),
                            _buildStatColumn('Communities', '${joinedCommunities.length}', () => _tabController.animateTo(0)),
                            _buildStatColumn('Posts', '${userQuestions.length}', () => _tabController.animateTo(2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Display Name & Location
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF0F6FC),
                    ),
                  ),
                  if (user.majorOrBio != null && user.majorOrBio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.majorOrBio!,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFFF0F6FC), height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Action Buttons: [ Edit Profile ] and [ Log Out ]
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showEditProfileSheet(context, user),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF0F6FC),
                            backgroundColor: const Color(0xFF21262D),
                            side: const BorderSide(color: Color(0xFF30363D)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => _confirmLogout(context, auth),
                        icon: const Icon(Icons.logout_rounded, size: 15, color: Color(0xFFF85149)),
                        label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF85149))),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF21262D),
                          side: const BorderSide(color: Color(0xFF30363D)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProfileTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF58A6FF),
                labelColor: const Color(0xFF58A6FF),
                unselectedLabelColor: const Color(0xFF8B949E),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.groups_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text('Communities (${joinedCommunities.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text('Friends (${friends.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.question_answer_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text('Posts (${userQuestions.length})'),
                      ],
                    ),
                  ),
                ],
              ),
              const Color(0xFF0D1117),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: My Communities List (💻 Mumbai Developers, 📚 DDU Students, etc.)
            joinedCommunities.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No joined communities yet', style: TextStyle(color: Color(0xFF8B949E))),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: joinedCommunities.length,
                    itemBuilder: (context, index) {
                      final c = joinedCommunities[index];
                      return _buildCommunityItem(c);
                    },
                  ),

            // Tab 2: Friends List with 1-Tap [ Chat ] Buttons
            friends.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 40, color: Color(0xFF8B949E)),
                          const SizedBox(height: 12),
                          const Text(
                            'No Friends Added Yet',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Search users by @username on the Home screen to connect!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF8B949E)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: friends.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return _buildFriendItem(friend, auth);
                    },
                  ),

            // Tab 3: User Questions / Posts
            userQuestions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('You haven\'t posted any questions yet', style: TextStyle(color: Color(0xFF8B949E))),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: userQuestions.length,
                    itemBuilder: (context, index) {
                      final q = userQuestions[index];
                      return QuestionCard(
                        question: q,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuestionDetailScreen(questionId: q.id),
                            ),
                          );
                        },
                        onUpvote: () => questionProvider.toggleUpvoteQuestion(q.id),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityItem(Community c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CommunityDetailScreen(communityId: c.id),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(c.bannerColorHex),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(c.iconEmoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF0F6FC),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${c.regionName} • ${c.memberCount} members',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF8B949E)),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(User friend, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF21262D),
            child: Text(friend.avatarUrl ?? '👤', style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0F6FC),
                  ),
                ),
                Text(
                  friend.handle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF58A6FF)),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.chat_bubble_rounded, size: 14),
            label: const Text('Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () {
              final chatProvider = context.read<ChatProvider>();
              final room = chatProvider.startPersonalChat(
                peerUser: friend,
                currentUser: auth.currentUser!,
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatConversationScreen(roomId: room.id)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, VoidCallback? onTap) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: content,
        ),
      );
    }
    return content;
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _bgColor;

  _ProfileTabBarDelegate(this._tabBar, this._bgColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _bgColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) => false;
}
