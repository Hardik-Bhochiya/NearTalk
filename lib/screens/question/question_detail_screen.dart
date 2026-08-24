import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/question_provider.dart';
import '../../widgets/author_tile.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/vote_button.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _replyController = TextEditingController();
  bool _isAnonymousReply = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final questionProvider = context.read<QuestionProvider>();
    questionProvider.addReply(
      questionId: widget.questionId,
      content: text,
      user: user,
      isAnonymous: _isAnonymousReply,
    );

    _replyController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAnonymousReply ? 'Answer posted anonymously 🎭' : 'Answer submitted!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final questionProvider = context.watch<QuestionProvider>();
    final question = questionProvider.getQuestionById(widget.questionId);

    if (question == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Question not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(question.communityName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question link copied to clipboard')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Question Details & Answers List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Author Header
                AuthorTile(
                  authorName: question.authorName,
                  avatarUrl: question.authorAvatar,
                  isAnonymous: question.isAnonymous,
                  anonymousPseudonym: question.anonymousPseudonym,
                  createdAt: question.createdAt,
                  communityBadge: question.communityName,
                ),
                const SizedBox(height: 14),

                // Question Title
                Text(
                  question.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                // Question Body
                if (question.content.isNotEmpty) ...[
                  Text(
                    question.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Tags
                if (question.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: question.tags.map((t) => TagChip(label: t)).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action / Upvote Row
                Row(
                  children: [
                    VoteButton(
                      count: question.upvotes,
                      isVoted: question.isUpvotedByMe,
                      onTap: () => questionProvider.toggleUpvoteQuestion(question.id),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${question.views} views',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    if (question.isResolved)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                            SizedBox(width: 4),
                            Text(
                              'Resolved',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 14),

                // Answers Section Header
                Row(
                  children: [
                    Text(
                      'Answers & Discussion',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${question.replies.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Replies List
                if (question.replies.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.forum_outlined, size: 36, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 8),
                        Text(
                          'No answers yet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Be the first to help your peer with an answer below!',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                else
                  ...question.replies.map((reply) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF151C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: reply.isAccepted
                              ? const Color(0xFF10B981)
                              : (isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0)),
                          width: reply.isAccepted ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AuthorTile(
                                  authorName: reply.authorName,
                                  avatarUrl: reply.authorAvatar,
                                  isAnonymous: reply.isAnonymous,
                                  anonymousPseudonym: reply.anonymousPseudonym,
                                  createdAt: reply.createdAt,
                                ),
                              ),
                              if (reply.isAccepted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_rounded, size: 13, color: Color(0xFF059669)),
                                      SizedBox(width: 3),
                                      Text(
                                        'Top Answer',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            reply.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              height: 1.45,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              VoteButton(
                                count: reply.upvotes,
                                isVoted: reply.isUpvotedByMe,
                                isSmall: true,
                                onTap: () => questionProvider.toggleUpvoteReply(question.id, reply.id),
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

          // Bottom Reply Input Field
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151C2C) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() => _isAnonymousReply = !_isAnonymousReply);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isAnonymousReply
                              ? const Color(0xFFFCE7F3)
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isAnonymousReply ? const Color(0xFFF472B6) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.masks_rounded,
                              size: 15,
                              color: _isAnonymousReply ? const Color(0xFFDB2777) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isAnonymousReply ? 'Posting as Anonymous' : 'Post Anonymously',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _isAnonymousReply ? const Color(0xFFBE185D) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Write a helpful answer or tip...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sendReply,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
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
}
