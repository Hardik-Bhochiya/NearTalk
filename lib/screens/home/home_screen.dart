import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/community.dart';
import '../../models/question.dart';
import '../../models/user.dart';
import '../../models/friend_request.dart';
import '../../models/region.dart';
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
  final _searchController = TextEditingController();
  final _quickQuestionController = TextEditingController();
  String _universalSearchQuery = '';
  bool _isAnonymousFeedMode = false; // false = Main, true = Anonymous

  @override
  void dispose() {
    _searchController.dispose();
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

    final communities = communityProvider.communities;
    if (communities.isEmpty) return;
    final community = communityProvider.joinedCommunities.isNotEmpty
        ? communityProvider.joinedCommunities.first
        : communities.first;

    final isAnon = _isAnonymousFeedMode;

    questionProvider.askQuestion(
      title: text,
      content: '',
      communityId: community.id,
      communityName: community.name,
      regionId: community.regionId,
      regionName: community.regionName,
      user: user,
      isAnonymous: isAnon,
      tags: [community.regionName, isAnon ? 'Anonymous' : 'General'],
    );

    auth.addPoints(5);
    _quickQuestionController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAnon
              ? 'Anonymous question posted to ${community.name}! (+5 pts) 🎭'
              : 'Question posted to ${community.name}! (+5 pts) ⭐',
        ),
        backgroundColor: const Color(0xFF238636),
      ),
    );
  }

  void _handleSendFriendRequest(String username) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.sendFriendRequest(username);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to @$username! 🤝'),
          backgroundColor: const Color(0xFF238636),
        ),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send friend request to @$username.'),
          backgroundColor: const Color(0xFFF85149),
        ),
      );
    }
  }

  void _handleAcceptFriendRequest(FriendRequest req) async {
    final auth = context.read<AuthProvider>();
    await auth.respondFriendRequest(req.id, 'accepted');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted friend request from ${req.senderName} (@${req.senderUsername})! 🎉'),
        backgroundColor: const Color(0xFF238636),
      ),
    );
    setState(() {});
  }

  void _handleRejectFriendRequest(FriendRequest req) async {
    final auth = context.read<AuthProvider>();
    await auth.respondFriendRequest(req.id, 'rejected');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined request from ${req.senderName}.'),
        backgroundColor: const Color(0xFF30363D),
      ),
    );
    setState(() {});
  }

  void _navigateToCityCommunities(Region region) {
    context.read<CommunityProvider>().selectRegion(region);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CommunitiesScreen(isTab: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final communityProvider = context.watch<CommunityProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final user = auth.currentUser;
    final joinedCommunities = communityProvider.joinedCommunities;
    final allCommunities = communityProvider.communities;
    final regions = communityProvider.regions;
    final pendingIncomingRequests = auth.getPendingIncomingRequests();

    // Universal search filtering
    final query = _universalSearchQuery.trim().toLowerCase().replaceAll('@', '');
    List<User> matchedUsers = [];
    List<Community> matchedCommunities = [];

    if (query.isNotEmpty) {
      matchedUsers = auth.knownUsers.where((u) {
        if (user != null && u.id == user.id) return false;
        return u.username.toLowerCase().contains(query) ||
            u.name.toLowerCase().contains(query) ||
            u.campusOrCity.toLowerCase().contains(query);
      }).toList();

      matchedCommunities = allCommunities.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.category.toLowerCase().contains(query) ||
            c.regionName.toLowerCase().contains(query) ||
            c.description.toLowerCase().contains(query);
      }).toList();
    }

    final questions = _isAnonymousFeedMode
        ? questionProvider.anonymousQuestions
        : questionProvider.mainQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Text('💬', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NearTalk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF0F6FC),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  user != null ? '📍 ${user.campusOrCity}' : 'Location-Based Communities',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B949E),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 24),
                color: const Color(0xFFF0F6FC),
                onPressed: () => NotificationsSheet.show(context),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF58A6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifProvider.unreadCount}',
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Personalized User Welcome Card
            _buildWelcomeCard(user),
            const SizedBox(height: 16),

            // 2. Universal Search Bar
            _buildUniversalSearchBar(),
            const SizedBox(height: 16),

            // Search Results Section (if active search query)
            if (_universalSearchQuery.isNotEmpty) ...[
              _buildSearchResultsSection(matchedUsers, matchedCommunities, auth),
              const SizedBox(height: 20),
            ],

            // 3. Friend Requests Card (Always visible on Home dashboard)
            _buildFriendRequestsCard(pendingIncomingRequests),
            const SizedBox(height: 20),

            // 4. Suggested Communities by Location (Mumbai, Ahmedabad, Dwarka, Nadiad)
            _buildLocationCommunitiesSection(regions),
            const SizedBox(height: 20),

            // 5. My Groups Header & Carousel
            _buildMyGroupsSection(joinedCommunities),
            const SizedBox(height: 22),

            // 6. Ask Question Box (High visibility GitHub green)
            _buildAskQuestionBox(user),
            const SizedBox(height: 20),

            // 7. Campus Discussions (Main vs Anonymous)
            _buildDiscussionsSection(questions),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 1. Welcome Card ---
  Widget _buildWelcomeCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF58A6FF), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(user?.avatarUrl ?? '🎓', style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Welcome, ${user?.name ?? 'Hardik Bhochiya'}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF0F6FC),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Text(
                        user?.handle ?? '@hardik_07',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF58A6FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '📍 ${user?.campusOrCity ?? 'Nadiad'}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Universal Search Bar ---
  Widget _buildUniversalSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _universalSearchQuery.isNotEmpty ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF58A6FF)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 13.5),
              decoration: const InputDecoration(
                hintText: 'Search users, communities... 🔍',
                hintStyle: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _universalSearchQuery = val;
                });
              },
            ),
          ),
          if (_universalSearchQuery.isNotEmpty)
            InkWell(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _universalSearchQuery = '';
                });
              },
              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF8B949E)),
            ),
        ],
      ),
    );
  }

  // --- Search Results Section ---
  Widget _buildSearchResultsSection(
    List<User> matchedUsers,
    List<Community> matchedCommunities,
    AuthProvider auth,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Results for "$_universalSearchQuery"',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0F6FC),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                    _universalSearchQuery = '';
                  });
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(fontSize: 12, color: Color(0xFF58A6FF), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Matching Users
          if (matchedUsers.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.person_search_rounded, size: 16, color: Color(0xFF58A6FF)),
                SizedBox(width: 6),
                Text(
                  'People / Users',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...matchedUsers.map((targetUser) => _buildUserSearchResultCard(targetUser, auth)),
            const SizedBox(height: 12),
          ],

          // Matching Communities
          if (matchedCommunities.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.groups_rounded, size: 16, color: Color(0xFF58A6FF)),
                SizedBox(width: 6),
                Text(
                  'Communities',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...matchedCommunities.map((c) => _buildCommunitySearchResultCard(c)),
          ],

          if (matchedUsers.isEmpty && matchedCommunities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No users or communities found for this query.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF8B949E)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // User Profile Card in Search Result
  Widget _buildUserSearchResultCard(User targetUser, AuthProvider auth) {
    final isFriend = auth.areFriends(targetUser.username);
    final outgoing = auth.getPendingOutgoingRequests();
    final hasSentRequest = outgoing.any(
      (r) => r.receiverUsername.toLowerCase() == targetUser.username.toLowerCase(),
    );
    final incoming = auth.getPendingIncomingRequests();
    final incomingReq = incoming.cast<FriendRequest?>().firstWhere(
          (r) => r?.senderUsername.toLowerCase() == targetUser.username.toLowerCase(),
          orElse: () => null,
        );

    // Approximate stats for display
    final communityCount = targetUser.joinedCommunityIds.length;
    final friendCount = targetUser.username == 'rahul123' ? 2 : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF161B22),
            child: Text(targetUser.avatarUrl ?? '👤', style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  targetUser.name,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      targetUser.handle,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF58A6FF), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• 📍 ${targetUser.campusOrCity}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$friendCount friends • $communityCount communities',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF8B949E)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isFriend)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF238636).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF238636)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 14, color: Color(0xFF3FB950)),
                  SizedBox(width: 4),
                  Text(
                    'Friends ✓',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                  ),
                ],
              ),
            )
          else if (incomingReq != null)
            ElevatedButton(
              onPressed: () => _handleAcceptFriendRequest(incomingReq),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Accept', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            )
          else if (hasSentRequest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Text(
                'Request Sent',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _handleSendFriendRequest(targetUser.username),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 14),
              label: const Text('Add Friend', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58A6FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  // Community Card in Search Result
  Widget _buildCommunitySearchResultCard(Community c) {
    final communityProvider = context.read<CommunityProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(c.bannerColorHex),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(c.iconEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${c.regionName} • ${c.memberCount} members',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              communityProvider.toggleJoinCommunity(c.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: c.isJoined ? const Color(0xFF21262D) : const Color(0xFF238636),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: c.isJoined ? const Color(0xFF30363D) : Colors.transparent),
              ),
            ),
            child: Text(
              c.isJoined ? 'Joined ✓' : 'Join',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: c.isJoined ? const Color(0xFF3FB950) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Friend Requests Card (Dashboard) ---
  Widget _buildFriendRequestsCard(List<FriendRequest> requests) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: requests.isNotEmpty ? const Color(0xFF58A6FF).withValues(alpha: 0.5) : const Color(0xFF30363D),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, size: 18, color: Color(0xFF58A6FF)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Friend Requests',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0F6FC),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: requests.isNotEmpty ? const Color(0xFF238636) : const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Text(
                  '${requests.length} pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: requests.isNotEmpty ? Colors.white : const Color(0xFF8B949E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (requests.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF21262D)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 16, color: Color(0xFF8B949E)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No pending requests. Use search to find classmates by @username!',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
                    ),
                  ),
                ],
              ),
            )
          else
            ...requests.map((req) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF161B22),
                      child: Text(req.senderAvatar ?? '👤', style: const TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.senderName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF0F6FC),
                            ),
                          ),
                          Text(
                            '@${req.senderUsername}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF58A6FF)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () => _handleAcceptFriendRequest(req),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Accept', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () => _handleRejectFriendRequest(req),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF85149),
                        side: const BorderSide(color: Color(0xFF30363D)),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- 4. Suggested Communities by Location (Mumbai, Ahmedabad, Dwarka, Nadiad) ---
  Widget _buildLocationCommunitiesSection(List<Region> regions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.place_rounded, size: 18, color: Color(0xFF58A6FF)),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Suggested Communities by Location',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF0F6FC),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Explore general city locations (Dwarka, Mumbai, Ahmedabad, Nadiad)',
          style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
        ),
        const SizedBox(height: 12),

        // Grid of 4 Locations
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemCount: regions.length,
          itemBuilder: (context, index) {
            final reg = regions[index];
            return InkWell(
              onTap: () => _navigateToCityCommunities(reg),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Row(
                  children: [
                    Text(reg.iconEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            reg.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF0F6FC),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${reg.activeCommunitiesCount} Groups',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF58A6FF), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF8B949E)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- 5. My Groups Header & Carousel ---
  Widget _buildMyGroupsSection(List<Community> joinedCommunities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text(
                    'My Groups',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF0F6FC),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21262D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF30363D)),
                    ),
                    child: Text(
                      '${joinedCommunities.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                    ),
                  ),
                ],
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
                      color: Color(0xFF58A6FF),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF58A6FF)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        joinedCommunities.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🌐', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Join city communities above to participate in discussions!',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 128,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: joinedCommunities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final c = joinedCommunities[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => CommunityDetailScreen(communityId: c.id)),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 145,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF30363D)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color(c.bannerColorHex),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(c.iconEmoji, style: const TextStyle(fontSize: 16)),
                                ),
                                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF3FB950)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  c.regionName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF8B949E)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // --- 6. Ask Question Box ---
  Widget _buildAskQuestionBox(User? user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ask Your Community',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Ask queries to people in your city or college...',
            style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
          ),
          const SizedBox(height: 12),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quickQuestionController,
                    style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Type your question here...',
                      hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF8B949E)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onSubmitted: (_) => _submitQuickQuestion(),
                  ),
                ),
                InkWell(
                  onTap: _submitQuickQuestion,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF238636),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Mode row & Ask Button
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Main (Public)
                InkWell(
                  onTap: () => setState(() => _isAnonymousFeedMode = false),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: !_isAnonymousFeedMode ? const Color(0xFF21262D) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: !_isAnonymousFeedMode ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 13,
                          color: !_isAnonymousFeedMode ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Public',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !_isAnonymousFeedMode ? const Color(0xFFF0F6FC) : const Color(0xFF8B949E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Anonymous
                InkWell(
                  onTap: () => setState(() => _isAnonymousFeedMode = true),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isAnonymousFeedMode ? const Color(0xFF21262D) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isAnonymousFeedMode ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.masks_rounded,
                          size: 13,
                          color: _isAnonymousFeedMode ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Anonymous',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _isAnonymousFeedMode ? const Color(0xFFF0F6FC) : const Color(0xFF8B949E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
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
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('+ Detailed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Discussions Section ---
  Widget _buildDiscussionsSection(List<Question> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Discussions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF0F6FC),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const AskQuestionScreen(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF58A6FF)),
                  SizedBox(width: 4),
                  Text(
                    'New Post',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58A6FF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (questions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              children: [
                Text(_isAnonymousFeedMode ? '🎭' : '💬', style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  _isAnonymousFeedMode ? 'No anonymous posts yet' : 'No discussions posted yet',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Be the first to post a query for your location community!',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                ),
              ],
            ),
          )
        else
          ...questions.map((q) => _buildDiscussionCard(q)),
      ],
    );
  }

  Widget _buildDiscussionCard(Question q) {
    final questionProvider = context.read<QuestionProvider>();
    final isAnon = q.isAnonymous;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
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
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF21262D),
                  child: Text(isAnon ? '🎭' : (q.authorName.isNotEmpty ? q.authorName[0] : '👤'),
                      style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnon ? 'Anonymous Peer' : q.authorName,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                      ),
                      Text(
                        q.communityName,
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF58A6FF)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF8B949E)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => PostOptionsSheet.show(context, q),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              q.title,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFFF0F6FC)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF8B949E)),
                const SizedBox(width: 4),
                Text(
                  '${q.replyCount} replies',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                ),
                const SizedBox(width: 14),
                InkWell(
                  onTap: () => questionProvider.toggleUpvoteQuestion(q.id),
                  child: Row(
                    children: [
                      Icon(
                        q.isUpvotedByMe ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                        size: 14,
                        color: q.isUpvotedByMe ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${q.upvotes} helpful',
                        style: TextStyle(
                          fontSize: 11,
                          color: q.isUpvotedByMe ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
                          fontWeight: q.isUpvotedByMe ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
