import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/question_provider.dart';
import '../../widgets/question_card.dart';
import '../../widgets/community_card.dart';
import '../community/community_detail_screen.dart';
import '../question/question_detail_screen.dart';
import '../auth/login_screen.dart';

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

  void _showEditProfileSheet(BuildContext context, dynamic user) {
    final nameCtrl = TextEditingController(text: user.name);
    final campusCtrl = TextEditingController(text: user.campusOrCity);
    final bioCtrl = TextEditingController(text: user.majorOrBio ?? 'DDU Student');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: campusCtrl,
              decoration: InputDecoration(
                labelText: 'Campus / Location',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: bioCtrl,
              decoration: InputDecoration(
                labelText: 'Major / Bio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().updateProfile(
                  name: nameCtrl.text.trim(),
                  campusOrCity: campusCtrl.text.trim(),
                  majorOrBio: bioCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final communityProvider = context.watch<CommunityProvider>();
    final questionProvider = context.watch<QuestionProvider>();

    final user = auth.currentUser;

    if (user == null || auth.isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle_outlined, size: 72, color: Color(0xFF94A3B8)),
                const SizedBox(height: 16),
                const Text(
                  'Exploring as Guest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account or sign in with your college email to post, build reputation, and chat with community members.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
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
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userQuestions = questionProvider.getUserQuestions(user.id);
    final bookmarkedQuestions = questionProvider.bookmarkedQuestions;
    final joinedCommunities = communityProvider.joinedCommunities;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: 'Toggle Dark / Light Theme',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out of NearTalk?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        auth.logout();
                      },
                      child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
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
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: const Color(0xFFEDE9FE),
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6D28D9),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (user.isCollegeVerified)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFC7D2FE)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.verified_rounded, size: 13, color: Color(0xFF4F46E5)),
                                              SizedBox(width: 3),
                                              Text(
                                                'Verified',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF4F46E5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    user.campusOrCity,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  if (user.majorOrBio != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      user.majorOrBio!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Edit Profile Outline Button
                        OutlinedButton.icon(
                          onPressed: () => _showEditProfileSheet(context, user),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Profile & Bio'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6D28D9),
                            side: const BorderSide(color: Color(0xFFC4B5FD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size.fromHeight(36),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Progression Level Bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Level 3: Campus Contributor',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                                  ),
                                  Text(
                                    '240 / 500 XP',
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: const LinearProgressIndicator(
                                  value: 0.48,
                                  backgroundColor: Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Reputation', '${user.reputation} pts', Icons.military_tech_rounded, const Color(0xFFF59E0B)),
                            _buildStatItem('Questions', '${userQuestions.length}', Icons.question_answer_rounded, const Color(0xFF6D28D9)),
                            _buildStatItem('Bookmarks', '${bookmarkedQuestions.length}', Icons.bookmark_rounded, const Color(0xFFEC4899)),
                            _buildStatItem('Communities', '${joinedCommunities.length}', Icons.groups_rounded, const Color(0xFF059669)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Badges Wrap
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xFFF59E0B)),
                      SizedBox(width: 6),
                      Text(
                        'Community Badges',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: user.badges.map((b) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          '⭐ $b',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF6D28D9),
                labelColor: const Color(0xFF6D28D9),
                unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                tabs: [
                  Tab(text: 'My Posts (${userQuestions.length})'),
                  Tab(text: 'Saved (${bookmarkedQuestions.length})'),
                  Tab(text: 'Joined (${joinedCommunities.length})'),
                ],
              ),
              isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: User's Questions
            userQuestions.isEmpty
                ? const Center(child: Text('You haven\'t asked any questions yet'))
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

            // Tab 2: Saved / Bookmarked Questions
            bookmarkedQuestions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 10),
                        Text('No saved bookmarks yet', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Tap the 3-dots on any question to bookmark it for later.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookmarkedQuestions.length,
                    itemBuilder: (context, index) {
                      final q = bookmarkedQuestions[index];
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

            // Tab 3: Joined Communities
            joinedCommunities.isEmpty
                ? const Center(child: Text('You haven\'t joined any communities'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: joinedCommunities.length,
                    itemBuilder: (context, index) {
                      final c = joinedCommunities[index];
                      return CommunityCard(
                        community: c,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CommunityDetailScreen(communityId: c.id),
                            ),
                          );
                        },
                        onJoinToggle: () => communityProvider.toggleJoinCommunity(c.id),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _bgColor;

  _SliverAppBarDelegate(this._tabBar, this._bgColor);

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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
