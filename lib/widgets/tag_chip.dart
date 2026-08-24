import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isSelected
        ? theme.primaryColor
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 0.8,
          ),
        ),
        child: Text(
          '#$label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
