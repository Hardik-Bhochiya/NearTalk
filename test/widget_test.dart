import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:neartalk/main.dart';
import 'package:neartalk/providers/theme_provider.dart';
import 'package:neartalk/providers/auth_provider.dart';
import 'package:neartalk/providers/community_provider.dart';
import 'package:neartalk/providers/question_provider.dart';
import 'package:neartalk/providers/chat_provider.dart';
import 'package:neartalk/providers/notification_provider.dart';

void main() {
  testWidgets('NearTalk App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
          ChangeNotifierProvider(create: (_) => QuestionProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const NearTalkApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that NearTalk home screen renders with custom sections
    expect(find.text('NearTalk'), findsOneWidget);
    expect(find.text('Welcome to NearTalk!'), findsOneWidget);
    expect(find.text('Your Communities'), findsOneWidget);
    expect(find.text('Recent Discussions'), findsOneWidget);
    expect(find.text('Which canteen is best for lunch?'), findsOneWidget);
  });
}
