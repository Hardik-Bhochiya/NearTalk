import 'reply.dart';

class Question {
  final String id;
  final String title;
  final String content;
  final String communityId;
  final String communityName;
  final String regionId;
  final String regionName;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? authorBadge; // e.g. "Community Helper"
  final bool isAnonymous;
  final String? anonymousPseudonym;
  final List<String> tags;
  final int upvotes;
  final int views;
  final DateTime createdAt;
  final List<Reply> replies;
  final bool isUpvotedByMe;
  final bool isBookmarked;
  final bool isResolved;

  const Question({
    required this.id,
    required this.title,
    required this.content,
    required this.communityId,
    required this.communityName,
    required this.regionId,
    required this.regionName,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.authorBadge,
    this.isAnonymous = false,
    this.anonymousPseudonym,
    this.tags = const [],
    this.upvotes = 0,
    this.views = 1,
    required this.createdAt,
    this.replies = const [],
    this.isUpvotedByMe = false,
    this.isBookmarked = false,
    this.isResolved = false,
  });

  int get replyCount => replies.length;

  Question copyWith({
    String? id,
    String? title,
    String? content,
    String? communityId,
    String? communityName,
    String? regionId,
    String? regionName,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? authorBadge,
    bool? isAnonymous,
    String? anonymousPseudonym,
    List<String>? tags,
    int? upvotes,
    int? views,
    DateTime? createdAt,
    List<Reply>? replies,
    bool? isUpvotedByMe,
    bool? isBookmarked,
    bool? isResolved,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorBadge: authorBadge ?? this.authorBadge,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousPseudonym: anonymousPseudonym ?? this.anonymousPseudonym,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      isUpvotedByMe: isUpvotedByMe ?? this.isUpvotedByMe,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'communityId': communityId,
      'communityName': communityName,
      'regionId': regionId,
      'regionName': regionName,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'authorBadge': authorBadge,
      'isAnonymous': isAnonymous,
      'anonymousPseudonym': anonymousPseudonym,
      'tags': tags,
      'upvotes': upvotes,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies.map((r) => r.toJson()).toList(),
      'isUpvotedByMe': isUpvotedByMe,
      'isBookmarked': isBookmarked,
      'isResolved': isResolved,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      communityId: json['communityId'] as String,
      communityName: json['communityName'] as String? ?? 'General Community',
      regionId: json['regionId'] as String? ?? 'default',
      regionName: json['regionName'] as String? ?? 'Campus',
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String?,
      authorBadge: json['authorBadge'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      anonymousPseudonym: json['anonymousPseudonym'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      upvotes: json['upvotes'] as int? ?? 0,
      views: json['views'] as int? ?? 1,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => Reply.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      isUpvotedByMe: json['isUpvotedByMe'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
    );
  }
}
