import 'package:flutter/material.dart';

class ChatAttachmentSheet extends StatelessWidget {
  final Function(String type, String title) onSelected;

  const ChatAttachmentSheet({super.key, required this.onSelected});

  static void show(BuildContext context, Function(String type, String title) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatAttachmentSheet(onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      {'icon': Icons.image_rounded, 'color': const Color(0xFF8B5CF6), 'title': 'Photo / Image', 'type': 'photo'},
      {'icon': Icons.camera_alt_rounded, 'color': const Color(0xFFEC4899), 'title': 'Camera', 'type': 'camera'},
      {'icon': Icons.description_rounded, 'color': const Color(0xFF3B82F6), 'title': 'Document / Notes', 'type': 'document'},
      {'icon': Icons.location_on_rounded, 'color': const Color(0xFF10B981), 'title': 'Campus Location', 'type': 'location'},
      {'icon': Icons.poll_rounded, 'color': const Color(0xFFF59E0B), 'title': 'Campus Poll', 'type': 'poll'},
      {'icon': Icons.mic_rounded, 'color': const Color(0xFF6366F1), 'title': 'Audio Note', 'type': 'audio'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151C2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.05,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(item['type'] as String, item['title'] as String);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
