import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/community.dart';
import '../../models/question.dart';
import '../../widgets/region_selector_sheet.dart';
import '../../widgets/notifications_sheet.dart';
import '../../widgets/post_options_sheet.dart';
import '../community/communities_screen.dart';
import '../community/community_detail_screen.dart';
import '../question/ask_question_screen.dart';
import '../question/question_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _quickQuestionController = TextEditingController();
  bool _isAnonymousPost = false;
  String _selectedFilter = 'Trending';

  @override
  void dispose() {
    _quickQuestionController.dispose();
    super.dispose();
  }

  void _submitQuickQuestion() {
    final text = _quickQuestionController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final communityProvider = context.read<CommunityProvider>();
    final questionProvider = context.read<QuestionProvider>();

    final community = communityProvider.communities.first;

    questionProvider.askQuestion(
      title: text,
      content: '',
      communityId: community.id,
      communityName: community.name,
      regionId: community.regionId,
      regionName: community.regionName,
      user: user,
      isAnonymous: _isAnonymousPost,
      tags: ['DDU', 'General'],
    );

    _quickQuestionController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAnonymousPost
              ? 'Anonymous question posted to ${community.name}! 🎭'
              : 'Question posted to ${community.name}!',
        ),
        backgroundColor: const Color(0xFF6D28D9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final auth = context.watch<AuthProvider>();
    final communityProvider = context.watch<CommunityProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final selectedRegion = communityProvider.selectedRegion;
    final communities = communityProvider.communities;
    var questions = questionProvider.filteredQuestions;

    if (_selectedFilter == 'Trending') {
      questions = questionProvider.trendingQuestions;
    } else if (_selectedFilter == 'Unanswered') {
      questions = questions.where((q) => q.replyCount == 0).toList();
    }

    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NearTalk',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: () => RegionSelectorSheet.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      selectedRegion?.name ?? 'DDU, Nadiad, Gujarat',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF7C3AED)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 26),
                color: isDark ? Colors.white70 : const Color(0xFF1E1B4B),
                onPressed: () => NotificationsSheet.show(context),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifProvider.unreadCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEDE9FE),
              child: const Icon(Icons.person, color: Color(0xFF7C3AED), size: 22),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner with illustration
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Welcome to NearTalk!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('👋', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ask people who know your place.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.public, size: 42, color: Color(0xFFC4B5FD)),
                      Positioned(
                        top: 8,
                        right: 14,
                        child: Icon(Icons.location_on, size: 20, color: Color(0xFF7C3AED)),
                      ),
                      Positioned(
                        top: 6,
                        left: 8,
                        child: Icon(Icons.help_outline, size: 12, color: Color(0xFF8B5CF6)),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 6,
                        child: Icon(Icons.chat_bubble, size: 12, color: Color(0xFF6D28D9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // "What do you want to know?" Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1B4B), const Color(0xFF151C2C)]
                      : [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF312E81) : const Color(0xFFDDD6FE),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What do you want to know?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ask your community anything...',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Input box with Purple Arrow
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quickQuestionController,
                            decoration: InputDecoration(
                              hintText: 'Type your question here...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (_) => _submitQuickQuestion(),
                          ),
                        ),
                        InkWell(
                          onTap: _submitQuickQuestion,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Post as scrollable row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          'Post as',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Hardik (Public)
                        InkWell(
                          onTap: () => setState(() => _isAnonymousPost = false),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: !_isAnonymousPost ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: !_isAnonymousPost
                                    ? const Color(0xFF7C3AED)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 14,
                                  color: !_isAnonymousPost ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user?.name ?? "Hardik"} (Public)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: !_isAnonymousPost ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Anonymous
                        InkWell(
                          onTap: () => setState(() => _isAnonymousPost = true),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isAnonymousPost ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isAnonymousPost
                                    ? const Color(0xFF7C3AED)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.masks_rounded,
                                  size: 14,
                                  color: _isAnonymousPost ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Anonymous',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: _isAnonymousPost ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // + Ask a Question Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (_) => const AskQuestionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D28D9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            '+ Ask a Question',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // "Your Communities" Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your Communities',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CommunitiesScreen(isTab: false)),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF7C3AED)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Smooth Scroll Communities Carousel
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: communities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 145,
                    child: _buildCommunityCard(context, communities[index], isDark),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // "Recent Discussions" Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Discussions',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CommunitiesScreen(isTab: false)),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF7C3AED)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Feed Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Trending', 'Latest', 'Unanswered'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        filter == 'Trending' ? '🔥 Trending' : filter == 'Latest' ? '🆕 Latest' : '❓ Unanswered',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                      selectedColor: const Color(0xFF7C3AED),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide.none,
                      onSelected: (val) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),

            // Discussion Cards List
            ...questions.map((q) => _buildDiscussionCard(context, q, isDark)),
            const SizedBox(height: 14),

            // "Explore more communities in your region" Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore more communities in your region',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Discover colleges, localities and interest based groups.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CommunitiesScreen(isTab: false)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, Community community, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CommunityDetailScreen(communityId: community.id)),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF2E384D) : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(community.bannerColorHex),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(community.iconEmoji, style: const TextStyle(fontSize: 16)),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    if (val == 'view') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CommunityDetailScreen(communityId: community.id)),
                      );
                    } else if (val == 'toggle') {
                      context.read<CommunityProvider>().toggleJoinCommunity(community.id);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: const [
                          Icon(Icons.open_in_new, size: 16),
                          SizedBox(width: 8),
                          Text('Open Community'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(community.isJoined ? Icons.exit_to_app : Icons.add, size: 16),
                          const SizedBox(width: 8),
                          Text(community.isJoined ? 'Leave Community' : 'Join Community'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              community.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              community.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '${community.memberCount >= 1000 ? "${(community.memberCount / 1000).toStringAsFixed(1)}K" : community.memberCount} members',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(BuildContext context, Question q, bool isDark) {
    final questionProvider = context.read<QuestionProvider>();
    final isAnon = q.isAnonymous;
    final isSports = q.communityName.contains('Sports');
    final pillBg = isSports ? const Color(0xFFFFEDD5) : const Color(0xFFEDE9FE);
    final pillText = isSports ? const Color(0xFFEA580C) : const Color(0xFF6D28D9);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151C2C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E384D) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => QuestionDetailScreen(questionId: q.id)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                if (isAnon)
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFF1F5F9),
                    child: Icon(Icons.masks_rounded, size: 18, color: Color(0xFF64748B)),
                  )
                else
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFEDE9FE),
                        child: Text(
                          q.authorName[0],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9)),
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                      ),
                    ],
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              q.authorName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '• 2h',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      if (q.authorBadge != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '⭐ ${q.authorBadge}',
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Community pill tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    q.communityName,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: pillText),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => PostOptionsSheet.show(context, q),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              q.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '${q.replyCount > 0 ? q.replyCount : 12} replies',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                InkWell(
                  onTap: () => questionProvider.toggleUpvoteQuestion(q.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Icon(
                        q.isUpvotedByMe ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                        size: 14,
                        color: q.isUpvotedByMe ? const Color(0xFF6D28D9) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${q.upvotes > 0 ? q.upvotes : 8} helpful',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: q.isUpvotedByMe ? const Color(0xFF6D28D9) : const Color(0xFF64748B),
                          fontWeight: q.isUpvotedByMe ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (q.isBookmarked)
                  const Icon(Icons.bookmark_rounded, size: 16, color: Color(0xFF7C3AED)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
