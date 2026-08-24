import 'package:flutter/material.dart';

class AnonymousBadge extends StatelessWidget {
  final String? alias;
  final bool compact;

  const AnonymousBadge({
    super.key,
    this.alias,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8), // Soft pink rose
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBCFE8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.theater_comedy_rounded,
            size: 14,
            color: Color(0xFFDB2777),
          ),
          const SizedBox(width: 5),
          Text(
            alias ?? 'Anonymous Member',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBE185D),
            ),
          ),
        ],
      ),
    );
  }
}
