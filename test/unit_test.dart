import 'package:flutter_test/flutter_test.dart';
import 'package:neartalk/providers/community_provider.dart';
import 'package:neartalk/providers/question_provider.dart';
import 'package:neartalk/providers/chat_provider.dart';
import 'package:neartalk/providers/notification_provider.dart';
import 'package:neartalk/services/mock_data_service.dart';

void main() {
  group('NearTalk Providers & Business Logic Tests', () {
    test('CommunityProvider toggles join status', () {
      final provider = CommunityProvider();
      final initialJoined = provider.joinedCommunities.length;

      // Toggle c4 (which starts as not joined)
      provider.toggleJoinCommunity('c4');
      expect(provider.joinedCommunities.length, initialJoined + 1);

      // Toggle again to leave
      provider.toggleJoinCommunity('c4');
      expect(provider.joinedCommunities.length, initialJoined);
    });

    test('QuestionProvider adds anonymous question, upvotes and bookmarks', () {
      final qProvider = QuestionProvider();
      final initialCount = qProvider.questions.length;

      qProvider.askQuestion(
        title: 'Where is the student recreation center in DDU?',
        content: 'Need to know where the indoor badminton courts are.',
        communityId: 'c3',
        communityName: 'DDU Sports',
        regionId: 'region-ddu',
        regionName: 'DDU, Nadiad, Gujarat',
        user: MockDataService.currentUser,
        isAnonymous: true,
        tags: ['Sports', 'DDU'],
      );

      expect(qProvider.questions.length, initialCount + 1);
      final newQ = qProvider.questions.first;
      expect(newQ.isAnonymous, isTrue);
      expect(newQ.upvotes, 1);

      // Toggle upvote
      qProvider.toggleUpvoteQuestion(newQ.id);
      expect(qProvider.getQuestionById(newQ.id)!.upvotes, 0);

      // Toggle bookmark
      qProvider.toggleBookmark(newQ.id);
      expect(qProvider.getQuestionById(newQ.id)!.isBookmarked, isTrue);
    });

    test('ChatProvider sends messages to rooms', () {
      final chatProvider = ChatProvider();
      const roomId = 'room-c1';
      final initialMsgs = chatProvider.getMessages(roomId).length;

      chatProvider.sendMessage(
        roomId: roomId,
        content: 'Hello DDU community!',
        currentUser: MockDataService.currentUser,
      );

      expect(chatProvider.getMessages(roomId).length, initialMsgs + 1);
      expect(chatProvider.getMessages(roomId).last.content, 'Hello DDU community!');
    });

    test('NotificationProvider marks notifications as read', () {
      final notifProvider = NotificationProvider();
      expect(notifProvider.unreadCount, greaterThan(0));

      notifProvider.markAllAsRead();
      expect(notifProvider.unreadCount, 0);
    });
  });
}
