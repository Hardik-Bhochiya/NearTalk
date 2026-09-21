import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neartalk/main.dart';
import 'package:neartalk/providers/theme_provider.dart';
import 'package:neartalk/providers/auth_provider.dart';
import 'package:neartalk/providers/community_provider.dart';
import 'package:neartalk/providers/question_provider.dart';
import 'package:neartalk/providers/chat_provider.dart';
import 'package:neartalk/providers/notification_provider.dart';
import 'package:neartalk/services/socket_service.dart';
import 'package:neartalk/services/local_store_service.dart';
import 'package:neartalk/services/api_service.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    SocketService.disabledForTests = true;
    await LocalStoreService().init();
    await ApiService().init();
  });

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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that NearTalk home screen renders with personalized name and location sections
    expect(find.text('NearTalk'), findsOneWidget);
    expect(find.text('Welcome, Hardik Bhochiya'), findsOneWidget);
    expect(find.text('@hardik_07'), findsOneWidget);
    expect(find.text('Friend Requests'), findsOneWidget);
    expect(find.text('Suggested Communities'), findsOneWidget);
    expect(find.text('My Groups'), findsOneWidget);
  });
}
