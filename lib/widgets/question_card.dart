import 'package:flutter/material.dart';
import '../models/question.dart';
import 'author_tile.dart';
import 'tag_chip.dart';
import 'vote_button.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;
  final VoidCallback onUpvote;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onTap,
    required this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthorTile(
                authorName: question.authorName,
                avatarUrl: question.authorAvatar,
                isAnonymous: question.isAnonymous,
                anonymousPseudonym: question.anonymousPseudonym,
                createdAt: question.createdAt,
                communityBadge: question.communityName,
              ),
              const SizedBox(height: 12),
              Text(
                question.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
              if (question.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  question.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
              ],
              if (question.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: question.tags.map((tag) => TagChip(label: tag)).toList(),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.7),
              const SizedBox(height: 8),
              Row(
                children: [
                  VoteButton(
                    count: question.upvotes,
                    isVoted: question.isUpvotedByMe,
                    onTap: onUpvote,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 15,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${question.replyCount} answers',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (question.isResolved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'Answered',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
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
      ),
    );
  }
}
