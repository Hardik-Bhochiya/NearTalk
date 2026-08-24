class Region {
  final String id;
  final String name;
  final String category; // 'Campus', 'City', 'Locality'
  final String description;
  final int activeCommunitiesCount;
  final int activeMembersCount;
  final String iconEmoji;

  const Region({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.activeCommunitiesCount,
    required this.activeMembersCount,
    required this.iconEmoji,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'activeCommunitiesCount': activeCommunitiesCount,
      'activeMembersCount': activeMembersCount,
      'iconEmoji': iconEmoji,
    };
  }

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Campus',
      description: json['description'] as String? ?? '',
      activeCommunitiesCount: json['activeCommunitiesCount'] as int? ?? 0,
      activeMembersCount: json['activeMembersCount'] as int? ?? 0,
      iconEmoji: json['iconEmoji'] as String? ?? '📍',
    );
  }
}
