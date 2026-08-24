class Reply {
  final String id;
  final String questionId;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final bool isAnonymous;
  final String? anonymousPseudonym; // e.g. "Anonymous Owl", "Local Senior"
  final int upvotes;
  final DateTime createdAt;
  final bool isAccepted;
  final bool isUpvotedByMe;

  const Reply({
    required this.id,
    required this.questionId,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.isAnonymous = false,
    this.anonymousPseudonym,
    this.upvotes = 0,
    required this.createdAt,
    this.isAccepted = false,
    this.isUpvotedByMe = false,
  });

  Reply copyWith({
    String? id,
    String? questionId,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    bool? isAnonymous,
    String? anonymousPseudonym,
    int? upvotes,
    DateTime? createdAt,
    bool? isAccepted,
    bool? isUpvotedByMe,
  }) {
    return Reply(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousPseudonym: anonymousPseudonym ?? this.anonymousPseudonym,
      upvotes: upvotes ?? this.upvotes,
      createdAt: createdAt ?? this.createdAt,
      isAccepted: isAccepted ?? this.isAccepted,
      isUpvotedByMe: isUpvotedByMe ?? this.isUpvotedByMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'isAnonymous': isAnonymous,
      'anonymousPseudonym': anonymousPseudonym,
      'upvotes': upvotes,
      'createdAt': createdAt.toIso8601String(),
      'isAccepted': isAccepted,
      'isUpvotedByMe': isUpvotedByMe,
    };
  }

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      anonymousPseudonym: json['anonymousPseudonym'] as String?,
      upvotes: json['upvotes'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isAccepted: json['isAccepted'] as bool? ?? false,
      isUpvotedByMe: json['isUpvotedByMe'] as bool? ?? false,
    );
  }
}
