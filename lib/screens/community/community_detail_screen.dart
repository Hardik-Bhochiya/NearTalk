import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/question_card.dart';
import '../question/question_detail_screen.dart';
import '../question/ask_question_screen.dart';
import '../chat/chat_conversation_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String communityId;
  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    final chatProvider = context.read<ChatProvider>();
    final auth = context.watch<AuthProvider>();

    final community = communityProvider.getCommunityById(widget.communityId);
    if (community == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(backgroundColor: const Color(0xFF0D1117)),
        body: const Center(
          child: Text('Community not found', style: TextStyle(color: Color(0xFF8B949E))),
        ),
      );
    }

    final questions = questionProvider.getQuestionsForCommunity(community.id);
    final knownUsers = auth.knownUsers;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF161B22),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(community.bannerColorHex),
                        const Color(0xFF161B22),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF30363D)),
                            ),
                            child: Text(
                              community.iconEmoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              communityProvider.toggleJoinCommunity(community.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: community.isJoined ? const Color(0xFF21262D) : const Color(0xFF238636),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: community.isJoined ? const Color(0xFF30363D) : Colors.transparent,
                                ),
                              ),
                            ),
                            icon: Icon(
                              community.isJoined ? Icons.check_circle_rounded : Icons.add_rounded,
                              size: 16,
                              color: community.isJoined ? const Color(0xFF3FB950) : Colors.white,
                            ),
                            label: Text(
                              community.isJoined ? 'Joined ✓' : 'Join Community',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: community.isJoined ? const Color(0xFF3FB950) : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF0F6FC),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📍 ${community.regionName} • ${community.locationSpot} • ${community.memberCount} members',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF8B949E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: const Color(0xFF161B22),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF58A6FF),
                    labelColor: const Color(0xFF58A6FF),
                    unselectedLabelColor: const Color(0xFF8B949E),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(text: 'Q&A (${questions.length})'),
                      const Tab(text: 'About & Rules'),
                      Tab(text: 'Members (${knownUsers.length})'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Questions / Q&A
            questions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💬', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 12),
                          const Text(
                            'No questions asked in this community yet',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC), fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AskQuestionScreen(preselectedCommunityId: community.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Be the first to ask!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF238636),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return QuestionCard(
                        question: q,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuestionDetailScreen(questionId: q.id),
                            ),
                          );
                        },
                        onUpvote: () {
                          questionProvider.toggleUpvoteQuestion(q.id);
                        },
                      );
                    },
                  ),

            // Tab 2: About & Rules
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'About this Community',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                ),
                const SizedBox(height: 6),
                Text(
                  community.description.isNotEmpty
                      ? community.description
                      : 'A dedicated group for students and professionals in ${community.regionName} to discuss, collaborate, and share local updates.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8B949E), height: 1.4),
                ),
                const SizedBox(height: 16),

                // Location Details Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city_rounded, color: Color(0xFF58A6FF), size: 22),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            community.regionName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC), fontSize: 13),
                          ),
                          Text(
                            'Spot: ${community.locationSpot}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Live Community Chat Action
                InkWell(
                  onTap: () {
                    final room = chatProvider.getOrCreateCommunityRoom(
                      community.id,
                      community.name,
                      community.iconEmoji,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(roomId: room.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF238636).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF238636)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.forum_rounded, color: Color(0xFF3FB950), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Open Live Community Chat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3FB950),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Talk in real-time with members of this group',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF8B949E)),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF3FB950)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Community Rules Section
                const Text(
                  'Community Rules',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF0F6FC)),
                ),
                const SizedBox(height: 10),
                ...community.rules.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF30363D)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF58A6FF)),
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF58A6FF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFFF0F6FC), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),

            // Tab 3: Members List (@rahul123, @hardik_07, etc.)
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: knownUsers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final member = knownUsers[index];
                final isCreator = member.id == community.creatorId || (index == 0);
                final isFriend = auth.areFriends(member.username);
                final isSelf = auth.currentUser?.id == member.id;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF21262D),
                        child: Text(member.avatarUrl ?? '👤', style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF0F6FC),
                                  ),
                                ),
                                if (isCreator) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3B341).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE3B341)),
                                    ),
                                    child: const Text(
                                      'Admin',
                                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFE3B341)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  member.handle,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF58A6FF)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '• 📍 ${member.campusOrCity}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelf)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF30363D)),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(fontSize: 11, color: Color(0xFF8B949E), fontWeight: FontWeight.bold),
                          ),
                        )
                      else if (isFriend)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF238636).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF238636)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, size: 12, color: Color(0xFF3FB950)),
                              SizedBox(width: 3),
                              Text(
                                'Friends',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () async {
                            final sent = await auth.sendFriendRequest(member.username);
                            if (context.mounted && sent) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Friend request sent to @${member.username}!'),
                                  backgroundColor: const Color(0xFF238636),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF58A6FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Add Friend', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => AskQuestionScreen(preselectedCommunityId: community.id),
            ),
          );
        },
        backgroundColor: const Color(0xFF238636),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded, size: 18),
        label: const Text('Ask in Community', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
