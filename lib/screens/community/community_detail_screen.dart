import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final communityProvider = context.watch<CommunityProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    final chatProvider = context.read<ChatProvider>();

    final community = communityProvider.getCommunityById(widget.communityId);
    if (community == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Community not found')),
      );
    }

    final questions = questionProvider.getQuestionsForCommunity(community.id);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(community.bannerColorHex),
                        Color(community.bannerColorHex).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              community.iconEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              communityProvider.toggleJoinCommunity(community.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: community.isJoined ? Colors.white : Colors.white,
                              foregroundColor: Color(community.bannerColorHex),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: Icon(
                              community.isJoined ? Icons.check : Icons.add,
                              size: 16,
                            ),
                            label: Text(
                              community.isJoined ? 'Joined' : 'Join Community',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${community.regionName} • ${community.memberCount} members',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: isDark ? const Color(0xFF151C2C) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: theme.primaryColor,
                    labelColor: theme.primaryColor,
                    unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    tabs: [
                      Tab(text: 'Q&A (${questions.length})'),
                      const Tab(text: 'About & Rules'),
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
            // Tab 1: Questions
            questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        const Text(
                          'No questions asked in this community yet',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Be the first to ask!'),
                        ),
                      ],
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
                Text(
                  'About this Community',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  community.description,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),

                // Community Live Chat Action Button
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
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.forum_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Open Live Community Chat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Talk in real-time with members of ${community.name}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Community Guidelines',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...community.rules.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
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
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded, size: 18),
        label: const Text('Ask in Community'),
      ),
    );
  }
}
