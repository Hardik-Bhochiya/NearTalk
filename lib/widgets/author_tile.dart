import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'anonymous_badge.dart';

class AuthorTile extends StatelessWidget {
  final String authorName;
  final String? avatarUrl;
  final bool isAnonymous;
  final String? anonymousPseudonym;
  final DateTime createdAt;
  final String? communityBadge;

  const AuthorTile({
    super.key,
    required this.authorName,
    this.avatarUrl,
    this.isAnonymous = false,
    this.anonymousPseudonym,
    required this.createdAt,
    this.communityBadge,
  });

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isAnonymous) {
      return Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFFCE7F3),
            child: Icon(Icons.masks_rounded, size: 18, color: Color(0xFFDB2777)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnonymousBadge(alias: anonymousPseudonym, compact: true),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (communityBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                communityBadge!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
          child: Text(
            authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authorName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTimestamp(createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (communityBadge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              communityBadge!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
