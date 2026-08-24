import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'community_detail_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  final bool isTab;
  const CommunitiesScreen({super.key, this.isTab = true});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Campus',
    'Housing',
    'Food & Dining',
    'Tech & Clubs',
    'Sports',
    'Marketplace',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateCommunityDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Campus';
    String selectedEmoji = '🏛️';

    final emojis = ['🏛️', '🎒', '🏠', '🍜', '💻', '⚡', '🏀', '🎨', '🏷️', '📚'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151C2C) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create New Community',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Emoji selector
                    const Text('Choose Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: emojis.map((e) {
                        final isSel = selectedEmoji == e;
                        return InkWell(
                          onTap: () => setModalState(() => selectedEmoji = e),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF4F46E5).withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? const Color(0xFF4F46E5) : Colors.transparent,
                              ),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: nameController,
                      labelText: 'Community Name',
                      hintText: 'e.g. Robotics Club, East Gate Foodies',
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: descController,
                      labelText: 'Description',
                      hintText: 'What is this community for?',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      items: _categories
                          .where((c) => c != 'All')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: 'Create Community',
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          ctx.read<CommunityProvider>().createCommunity(
                            name: nameController.text.trim(),
                            description: descController.text.trim(),
                            category: selectedCategory,
                            iconEmoji: selectedEmoji,
                            bannerColorHex: 0xFF4F46E5,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Community created successfully!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final communities = communityProvider.filteredCommunities;
    final selectedRegion = communityProvider.selectedRegion;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTab ? 'Communities' : 'Explore Communities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Create Community',
            onPressed: _showCreateCommunityDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Region Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => communityProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search communities in ${selectedRegion?.name ?? "region"}...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Categories horizontal list
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = communityProvider.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => communityProvider.selectCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Communities List
          Expanded(
            child: communities.isEmpty
                ? const Center(
                    child: Text('No communities found in this category'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: communities.length,
                    itemBuilder: (context, index) {
                      final community = communities[index];
                      return CommunityCard(
                        community: community,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CommunityDetailScreen(communityId: community.id),
                            ),
                          );
                        },
                        onJoinToggle: () {
                          communityProvider.toggleJoinCommunity(community.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
