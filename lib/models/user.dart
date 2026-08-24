class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String campusOrCity;
  final String? majorOrBio;
  final int reputation;
  final List<String> joinedCommunityIds;
  final List<String> badges;
  final bool isCollegeVerified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.campusOrCity,
    this.majorOrBio,
    this.reputation = 50,
    this.joinedCommunityIds = const [],
    this.badges = const ['Newcomer'],
    this.isCollegeVerified = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? campusOrCity,
    String? majorOrBio,
    int? reputation,
    List<String>? joinedCommunityIds,
    List<String>? badges,
    bool? isCollegeVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      campusOrCity: campusOrCity ?? this.campusOrCity,
      majorOrBio: majorOrBio ?? this.majorOrBio,
      reputation: reputation ?? this.reputation,
      joinedCommunityIds: joinedCommunityIds ?? this.joinedCommunityIds,
      badges: badges ?? this.badges,
      isCollegeVerified: isCollegeVerified ?? this.isCollegeVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'campusOrCity': campusOrCity,
      'majorOrBio': majorOrBio,
      'reputation': reputation,
      'joinedCommunityIds': joinedCommunityIds,
      'badges': badges,
      'isCollegeVerified': isCollegeVerified,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      campusOrCity: json['campusOrCity'] as String? ?? 'General Campus',
      majorOrBio: json['majorOrBio'] as String?,
      reputation: json['reputation'] as int? ?? 50,
      joinedCommunityIds: List<String>.from(json['joinedCommunityIds'] ?? []),
      badges: List<String>.from(json['badges'] ?? ['Newcomer']),
      isCollegeVerified: json['isCollegeVerified'] as bool? ?? false,
    );
  }
}
