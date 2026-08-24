import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';

class RegionSelectorSheet extends StatelessWidget {
  const RegionSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const RegionSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final communityProvider = context.watch<CommunityProvider>();
    final regions = communityProvider.regions;
    final selectedRegion = communityProvider.selectedRegion;

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151C2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFF4F46E5), size: 22),
              const SizedBox(width: 8),
              Text(
                'Select Your Region / Campus',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Explore questions, local discussions, and peer groups in your area.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...regions.map((region) {
            final isSelected = selectedRegion?.id == region.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor.withValues(alpha: 0.08)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColor
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                onTap: () {
                  communityProvider.selectRegion(region);
                  Navigator.pop(context);
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withValues(alpha: 0.15)
                        : (isDark ? const Color(0xFF151C2C) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(region.iconEmoji, style: const TextStyle(fontSize: 22)),
                ),
                title: Text(
                  region.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                    color: isSelected ? theme.primaryColor : null,
                  ),
                ),
                subtitle: Text(
                  '${region.category} • ${region.activeCommunitiesCount} communities • ${region.activeMembersCount} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: theme.primaryColor)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
