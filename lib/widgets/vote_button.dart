import 'package:flutter/material.dart';

class VoteButton extends StatelessWidget {
  final int count;
  final bool isVoted;
  final VoidCallback onTap;
  final bool isSmall;

  const VoteButton({
    super.key,
    required this.count,
    required this.isVoted,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isVoted
        ? theme.primaryColor.withValues(alpha: 0.15)
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));

    final contentColor = isVoted
        ? theme.primaryColor
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
          border: Border.all(
            color: isVoted ? theme.primaryColor.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVoted ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
              size: isSmall ? 14 : 16,
              color: contentColor,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                fontWeight: isVoted ? FontWeight.w700 : FontWeight.w600,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
