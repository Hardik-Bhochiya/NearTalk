import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating }

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool _isGuest = false;

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated || _isGuest;
  bool get isGuest => _isGuest;

  AuthProvider() {
    // Start with pre-authenticated mock user for smooth preview, but allow full login/logout flows
    _currentUser = MockDataService.currentUser;
    _status = AuthStatus.authenticated;
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _currentUser = User(
      id: MockDataService.currentUser.id,
      name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      email: email,
      campusOrCity: 'Silicon Valley Campus',
      majorOrBio: 'Computer Science | NearTalk Pioneer',
      reputation: 120,
      joinedCommunityIds: ['c1', 'c2', 'c4'],
      badges: ['Verified Student', 'Active Contributor'],
      isCollegeVerified: email.endsWith('.edu'),
    );

    _isGuest = false;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String campus,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _currentUser = User(
      id: MockDataService.generateId(),
      name: name,
      email: email,
      campusOrCity: campus,
      majorOrBio: 'New to NearTalk',
      reputation: 50,
      joinedCommunityIds: ['c1'],
      badges: ['Newcomer'],
      isCollegeVerified: email.endsWith('.edu'),
    );

    _isGuest = false;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  void continueAsGuest() {
    _currentUser = const User(
      id: 'guest-user',
      name: 'Guest Explorer',
      email: 'guest@neartalk.local',
      campusOrCity: 'Silicon Valley Campus',
      majorOrBio: 'Exploring local communities',
      reputation: 10,
      joinedCommunityIds: [],
      badges: ['Guest'],
      isCollegeVerified: false,
    );
    _isGuest = true;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void updateProfile({String? name, String? bio, String? campus}) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      majorOrBio: bio,
      campusOrCity: campus,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isGuest = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
