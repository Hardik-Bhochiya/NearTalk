import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/reply.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

class QuestionProvider extends ChangeNotifier {
  List<Question> _questions = [];
  String _selectedTag = 'All';
  String _searchQuery = '';
  String _sortFilter = 'Recent'; // 'Recent', 'Most Helpful', 'Unanswered'

  List<Question> get questions => _questions;
  String get selectedTag => _selectedTag;
  String get searchQuery => _searchQuery;
  String get sortFilter => _sortFilter;

  static const List<String> _anonymousAnimalAliases = [
    'Anonymous',
    'Anonymous Owl 🦉',
    'Curious Badger 🦡',
    'Silent Koala 🐨',
    'Campus Fox 🦊',
    'Swift Falcon 🦅',
  ];

  QuestionProvider() {
    _questions = List.from(MockDataService.initialQuestions);
  }

  void selectTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void setSortFilter(String filter) {
    _sortFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Question> getQuestionsForCommunity(String communityId) {
    return _questions.where((q) => q.communityId == communityId).toList();
  }

  List<Question> get filteredQuestions {
    var list = _questions.where((q) {
      final matchesTag = _selectedTag == 'All' || q.tags.contains(_selectedTag);
      final matchesSearch = _searchQuery.isEmpty ||
          q.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.communityName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesTag && matchesSearch;
    }).toList();

    if (_sortFilter == 'Most Helpful') {
      list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    } else if (_sortFilter == 'Unanswered') {
      list = list.where((q) => q.replyCount == 0).toList();
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  List<Question> get trendingQuestions {
    final list = List<Question>.from(_questions);
    list.sort((a, b) => (b.upvotes + b.replyCount * 2).compareTo(a.upvotes + a.replyCount * 2));
    return list;
  }

  List<Question> getUserQuestions(String userId) {
    return _questions.where((q) => q.authorId == userId).toList();
  }

  List<Question> get bookmarkedQuestions {
    return _questions.where((q) => q.isBookmarked).toList();
  }

  Question? getQuestionById(String id) {
    try {
      return _questions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  void toggleBookmark(String questionId) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      final q = _questions[index];
      _questions[index] = q.copyWith(isBookmarked: !q.isBookmarked);
      notifyListeners();
    }
  }

  void askQuestion({
    required String title,
    required String content,
    required String communityId,
    required String communityName,
    required String regionId,
    required String regionName,
    required User user,
    required bool isAnonymous,
    required List<String> tags,
  }) {
    final pseudonym = isAnonymous
        ? _anonymousAnimalAliases[Random().nextInt(_anonymousAnimalAliases.length)]
        : null;

    final newQuestion = Question(
      id: MockDataService.generateId(),
      title: title,
      content: content,
      communityId: communityId,
      communityName: communityName,
      regionId: regionId,
      regionName: regionName,
      authorId: user.id,
      authorName: isAnonymous ? 'Anonymous' : user.name,
      authorAvatar: isAnonymous ? null : user.avatarUrl,
      isAnonymous: isAnonymous,
      anonymousPseudonym: pseudonym,
      tags: tags,
      upvotes: 1,
      views: 1,
      createdAt: DateTime.now(),
      replies: [],
      isUpvotedByMe: true,
      isBookmarked: false,
    );

    _questions.insert(0, newQuestion);
    notifyListeners();
  }

  void toggleUpvoteQuestion(String questionId) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      final q = _questions[index];
      final newUpvoted = !q.isUpvotedByMe;
      final newCount = newUpvoted ? q.upvotes + 1 : q.upvotes - 1;
      _questions[index] = q.copyWith(
        isUpvotedByMe: newUpvoted,
        upvotes: newCount < 0 ? 0 : newCount,
      );
      notifyListeners();
    }
  }

  void addReply({
    required String questionId,
    required String content,
    required User user,
    required bool isAnonymous,
  }) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      final q = _questions[index];
      final pseudonym = isAnonymous ? 'Anonymous' : null;

      final newReply = Reply(
        id: MockDataService.generateId(),
        questionId: questionId,
        content: content,
        authorId: user.id,
        authorName: isAnonymous ? 'Anonymous' : user.name,
        authorAvatar: isAnonymous ? null : user.avatarUrl,
        isAnonymous: isAnonymous,
        anonymousPseudonym: pseudonym,
        upvotes: 0,
        createdAt: DateTime.now(),
      );

      final updatedReplies = List<Reply>.from(q.replies)..add(newReply);
      _questions[index] = q.copyWith(replies: updatedReplies);
      notifyListeners();
    }
  }

  void toggleUpvoteReply(String questionId, String replyId) {
    final qIndex = _questions.indexWhere((q) => q.id == questionId);
    if (qIndex != -1) {
      final q = _questions[qIndex];
      final rIndex = q.replies.indexWhere((r) => r.id == replyId);
      if (rIndex != -1) {
        final r = q.replies[rIndex];
        final newUpvoted = !r.isUpvotedByMe;
        final newCount = newUpvoted ? r.upvotes + 1 : r.upvotes - 1;
        final updatedReply = r.copyWith(
          isUpvotedByMe: newUpvoted,
          upvotes: newCount < 0 ? 0 : newCount,
        );
        final updatedReplies = List<Reply>.from(q.replies)..[rIndex] = updatedReply;
        _questions[qIndex] = q.copyWith(replies: updatedReplies);
        notifyListeners();
      }
    }
  }
}
