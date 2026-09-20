import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/friend_request.dart';
import '../services/mock_data_service.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/local_store_service.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthProvider extends ChangeNotifier {
  User? _currentUser = MockDataService.currentUser;
  bool _isAuthenticated = true;
  bool _isGuest = false;
  bool _isLoading = false;
  AuthStatus _status = AuthStatus.authenticated;
  StreamSubscription? _frReceivedSub;
  StreamSubscription? _frAcceptedSub;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  AuthStatus get status => _status;

  AuthProvider() {
    _initAuth();
    _listenToFriendSocketEvents();
  }

  void _listenToFriendSocketEvents() {
    _frReceivedSub = SocketService().onFriendRequestReceived.listen((data) {
      try {
        final req = FriendRequest.fromJson(data);
        LocalStoreService().addFriendRequest(req);
        notifyListeners();
      } catch (_) {}
    });

    _frAcceptedSub = SocketService().onFriendRequestAccepted.listen((data) {
      try {
        final requestId = data['requestId'] as String?;
        if (requestId != null) {
          LocalStoreService().respondFriendRequest(requestId, 'accepted');
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  Future<void> _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('saved_user');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        _isAuthenticated = true;
        _status = AuthStatus.authenticated;
        SocketService().joinUser(_currentUser!.id, _currentUser!.username);
        notifyListeners();
      } else if (_currentUser != null) {
        SocketService().joinUser(_currentUser!.id, _currentUser!.username);
      }
    } catch (_) {}
  }

  final List<User> _knownUsers = [
    MockDataService.currentUser,
    const User(
      id: 'user-rahul',
      username: 'rahul123',
      name: 'Rahul Patel',
      firstName: 'Rahul',
      lastName: 'Patel',
      email: 'rahul@gmail.com',
      campusOrCity: 'Mumbai',
      majorOrBio: 'Mumbai Developers • Full Stack Engineer',
      reputation: 160,
    ),
    const User(
      id: 'user-priya',
      username: 'priya_it',
      name: 'Priya Shah',
      firstName: 'Priya',
      lastName: 'Shah',
      email: 'priya@gmail.com',
      campusOrCity: 'Ahmedabad',
      majorOrBio: 'Ahmedabad Students • Tech Enthusiast',
      reputation: 180,
    ),
    const User(
      id: 'user-devshah',
      username: 'devshah',
      name: 'Dev Shah',
      firstName: 'Dev',
      lastName: 'Shah',
      email: 'dev@gmail.com',
      campusOrCity: 'Dwarka',
      majorOrBio: 'Dwarka Developers • Mobile App Builder',
      reputation: 140,
    ),
  ];

  List<User> get knownUsers => List.unmodifiable(_knownUsers);

  bool isUsernameAvailable(String username) {
    final sanitized = username.trim().toLowerCase().replaceAll('@', '');
    if (sanitized.length < 3) return false;
    return !_knownUsers.any((u) => u.username.toLowerCase() == sanitized);
  }

  User? findUserByUsername(String query) {
    final clean = query.trim().toLowerCase().replaceAll('@', '');
    try {
      return _knownUsers.firstWhere((u) => u.username.toLowerCase() == clean);
    } catch (_) {
      return null;
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    _status = AuthStatus.authenticating;
    notifyListeners();

    final input = usernameOrEmail.trim().toLowerCase().replaceAll('@', '');

    try {
      final user = await ApiService().login(usernameOrEmail, password);
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        _isGuest = false;
        _status = AuthStatus.authenticated;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_user', jsonEncode(user.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Match against known users by username or email
    final matched = _knownUsers.firstWhere(
      (u) => u.username.toLowerCase() == input || u.email.toLowerCase() == input,
      orElse: () => MockDataService.currentUser.copyWith(
        username: input.contains('@') ? input.split('@').first : input,
        name: input.contains('@') ? input.split('@').first : input,
        email: input.contains('@') ? input : '$input@ddu.ac.in',
      ),
    );

    _currentUser = matched;
    _isAuthenticated = true;
    _isGuest = false;
    _status = AuthStatus.authenticated;
    _isLoading = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_user', jsonEncode(_currentUser!.toJson()));
    SocketService().joinUser(_currentUser!.id, _currentUser!.username);

    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String username,
    String? firstName,
    String? lastName,
    required String email,
    required String password,
    String? campusOrCity,
    String? campus,
    String? majorOrBio,
  }) async {
    _isLoading = true;
    _status = AuthStatus.authenticating;
    notifyListeners();

    final resolvedCampus = campusOrCity ?? campus ?? 'DDU, Nadiad, Gujarat';
    final cleanUsername = username.trim().toLowerCase().replaceAll('@', '');

    final resolvedFirstName = firstName ?? (name.trim().split(' ').isNotEmpty ? name.trim().split(' ').first : 'Hardik');
    final resolvedLastName = lastName ?? (name.trim().split(' ').length > 1 ? name.trim().split(' ').sublist(1).join(' ') : 'Bhochiya');

    try {
      final user = await ApiService().register(
        name: name,
        email: email,
        password: password,
        campusOrCity: resolvedCampus,
        majorOrBio: majorOrBio,
      );

      if (user != null) {
        _currentUser = user.copyWith(
          username: cleanUsername,
          firstName: resolvedFirstName,
          lastName: resolvedLastName,
        );
        _isAuthenticated = true;
        _isGuest = false;
        _status = AuthStatus.authenticated;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_user', jsonEncode(_currentUser!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    final newUser = User(
      id: MockDataService.generateId(),
      username: cleanUsername.isEmpty ? 'hardik' : cleanUsername,
      name: name.trim().isEmpty ? '$resolvedFirstName $resolvedLastName' : name.trim(),
      firstName: resolvedFirstName,
      lastName: resolvedLastName,
      email: email,
      campusOrCity: resolvedCampus,
      majorOrBio: majorOrBio ?? 'DDU Student',
      reputation: 50,
      joinedCommunityIds: [],
      badges: [],
      isCollegeVerified: email.endsWith('.ddu.ac.in') || email.contains('ddu'),
    );

    _currentUser = newUser;
    _knownUsers.add(newUser);
    _isAuthenticated = true;
    _isGuest = false;
    _status = AuthStatus.authenticated;
    _isLoading = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_user', jsonEncode(newUser.toJson()));
    SocketService().joinUser(newUser.id, newUser.username);

    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String username,
    String? firstName,
    String? lastName,
    required String email,
    required String password,
    String? campusOrCity,
    String? campus,
    String? majorOrBio,
  }) => register(
        name: name,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        campusOrCity: campusOrCity,
        campus: campus,
        majorOrBio: majorOrBio,
      );

  Future<void> updateProfile({
    required String name,
    required String campusOrCity,
    required String majorOrBio,
    String? avatarUrl,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        campusOrCity: campusOrCity,
        majorOrBio: majorOrBio,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_user', jsonEncode(_currentUser!.toJson()));
      notifyListeners();
    }
  }

  Future<void> addPoints(int pts) async {
    if (_currentUser != null) {
      final newRep = _currentUser!.reputation + pts;
      _currentUser = _currentUser!.copyWith(reputation: newRep);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_user', jsonEncode(_currentUser!.toJson()));
      notifyListeners();
    }
  }

  void continueAsGuest() {
    _currentUser = null;
    _isAuthenticated = true;
    _isGuest = true;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _isGuest = false;
    _status = AuthStatus.unauthenticated;
    await ApiService().clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
    notifyListeners();
  }

  // --- Friends & Friend Requests ---

  List<User> getFriends() {
    if (_currentUser == null) return [];
    final friendUsernames = LocalStoreService().getFriendUsernames(_currentUser!.username);
    return _knownUsers.where((u) {
      return friendUsernames.any((fu) => fu.toLowerCase() == u.username.toLowerCase());
    }).toList();
  }

  bool areFriends(String username) {
    if (_currentUser == null) return false;
    return LocalStoreService().areFriends(_currentUser!.username, username);
  }

  List<FriendRequest> getPendingIncomingRequests() {
    if (_currentUser == null) return [];
    return LocalStoreService().getPendingIncomingRequests(_currentUser!.username);
  }

  List<FriendRequest> getPendingOutgoingRequests() {
    if (_currentUser == null) return [];
    return LocalStoreService().getPendingOutgoingRequests(_currentUser!.username);
  }

  Future<bool> sendFriendRequest(String targetUsername) async {
    if (_currentUser == null) return false;
    final targetUser = findUserByUsername(targetUsername);
    if (targetUser == null) return false;

    final req = FriendRequest(
      id: MockDataService.generateId(),
      senderId: _currentUser!.id,
      senderUsername: _currentUser!.username,
      senderName: _currentUser!.name,
      senderAvatar: _currentUser!.avatarUrl,
      receiverId: targetUser.id,
      receiverUsername: targetUser.username,
      receiverName: targetUser.name,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    LocalStoreService().addFriendRequest(req);
    SocketService().sendFriendRequest(req.toJson());
    notifyListeners();
    return true;
  }

  Future<void> respondFriendRequest(String requestId, String status) async {
    if (_currentUser == null) return;
    final reqs = LocalStoreService().getFriendRequests(_currentUser!.username);
    final req = reqs.firstWhere((r) => r.id == requestId, orElse: () => FriendRequest(
      id: requestId,
      senderId: '',
      senderUsername: '',
      senderName: '',
      receiverId: _currentUser!.id,
      receiverUsername: _currentUser!.username,
      receiverName: _currentUser!.name,
      createdAt: DateTime.now(),
    ));

    LocalStoreService().respondFriendRequest(requestId, status);
    SocketService().respondFriendRequest(
      requestId: requestId,
      status: status,
      senderUsername: req.senderUsername,
      receiverUsername: req.receiverUsername,
    );
    notifyListeners();
  }

  Future<void> removeFriend(String targetUsername) async {
    if (_currentUser == null) return;
    LocalStoreService().removeFriend(_currentUser!.username, targetUsername);
    notifyListeners();
  }

  @override
  void dispose() {
    _frReceivedSub?.cancel();
    _frAcceptedSub?.cancel();
    super.dispose();
  }
}
