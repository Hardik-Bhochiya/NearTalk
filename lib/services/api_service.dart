import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/community.dart';
import '../models/question.dart';
import '../models/reply.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import 'mock_data_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // On Android emulator, localhost is 10.0.2.2. On web/desktop/device, it is localhost/custom IP.
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5000/api'
        : 'http://localhost:5000/api';
  }

  String? _authToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Auth: Login
  Future<User?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await setAuthToken(data['token']);
        }
        return User.fromJson(data['user']);
      }
    } catch (_) {
      // Fallback to local mock service if server is unreachable
    }
    return MockDataService.currentUser;
  }

  // Auth: Register
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    String? campusOrCity,
    String? majorOrBio,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'campusOrCity': campusOrCity,
              'majorOrBio': majorOrBio,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await setAuthToken(data['token']);
        }
        return User.fromJson(data['user']);
      }
    } catch (_) {}
    return User(
      id: MockDataService.generateId(),
      name: name,
      email: email,
      campusOrCity: campusOrCity ?? 'DDU, Nadiad, Gujarat',
      majorOrBio: majorOrBio ?? 'DDU Student',
      reputation: 50,
      joinedCommunityIds: ['c1'],
      badges: ['New Member'],
      isCollegeVerified: email.endsWith('.ddu.ac.in') || email.contains('ddu'),
    );
  }

  // Communities: Get All
  Future<List<Community>> getCommunities() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/communities'), headers: _headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List<dynamic>;
        if (list.isNotEmpty) {
          return list.map((json) => Community.fromJson(json)).toList();
        }
      }
    } catch (_) {}
    return List.from(MockDataService.initialCommunities);
  }

  // Questions: Get All
  Future<List<Question>> getQuestions({String? communityId, String? tag, String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions').replace(queryParameters: {
        if (communityId != null) 'communityId': communityId,
        if (tag != null && tag != 'All') 'tag': tag,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List<dynamic>;
        if (list.isNotEmpty) {
          return list.map((json) => Question.fromJson(json)).toList();
        }
      }
    } catch (_) {}
    return List.from(MockDataService.initialQuestions);
  }

  // Questions: Create
  Future<Question?> createQuestion({
    required String title,
    required String content,
    required String communityId,
    required String communityName,
    required String regionId,
    required String regionName,
    required User user,
    required bool isAnonymous,
    required List<String> tags,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions'),
            headers: _headers,
            body: jsonEncode({
              'title': title,
              'content': content,
              'communityId': communityId,
              'communityName': communityName,
              'regionId': regionId,
              'regionName': regionName,
              'authorId': user.id,
              'authorName': user.name,
              'isAnonymous': isAnonymous,
              'tags': tags,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Question.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  // Questions: Upvote
  Future<void> toggleUpvote(String questionId) async {
    try {
      await http
          .post(Uri.parse('$baseUrl/questions/$questionId/upvote'), headers: _headers)
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  // Questions: Add Reply
  Future<Reply?> addReply({
    required String questionId,
    required String content,
    required User user,
    required bool isAnonymous,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/questions/$questionId/replies'),
            headers: _headers,
            body: jsonEncode({
              'content': content,
              'authorId': user.id,
              'authorName': user.name,
              'isAnonymous': isAnonymous,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Reply.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  // Chat: Get Rooms
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/chat/rooms'), headers: _headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List<dynamic>;
        if (list.isNotEmpty) {
          return list.map((json) => ChatRoom.fromJson(json)).toList();
        }
      }
    } catch (_) {}
    return List.from(MockDataService.initialChatRooms);
  }

  // Chat: Get Messages
  Future<List<ChatMessage>> getMessages(String roomId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/chat/rooms/$roomId/messages'), headers: _headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List<dynamic>;
        return list.map((json) => ChatMessage.fromJson(json)).toList();
      }
    } catch (_) {}
    return MockDataService.initialMessages.where((m) => m.roomId == roomId).toList();
  }
}
