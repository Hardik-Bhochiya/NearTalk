import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';
import '../services/api_service.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthProvider extends ChangeNotifier {
  User? _currentUser = MockDataService.currentUser;
  bool _isAuthenticated = true;
  bool _isGuest = false;
  bool _isLoading = false;
  AuthStatus _status = AuthStatus.authenticated;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  AuthStatus get status => _status;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('saved_user');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        _isAuthenticated = true;
        _status = AuthStatus.authenticated;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final user = await ApiService().login(email, password);
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

    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = MockDataService.currentUser.copyWith(email: email);
      _isAuthenticated = true;
      _isGuest = false;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
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

    try {
      final user = await ApiService().register(
        name: name,
        email: email,
        password: password,
        campusOrCity: resolvedCampus,
        majorOrBio: majorOrBio,
      );

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

    _currentUser = User(
      id: MockDataService.generateId(),
      name: name,
      email: email,
      campusOrCity: resolvedCampus,
      majorOrBio: majorOrBio ?? 'DDU Student',
      reputation: 50,
      joinedCommunityIds: ['c1'],
      badges: ['New Member'],
      isCollegeVerified: email.endsWith('.ddu.ac.in') || email.contains('ddu'),
    );
    _isAuthenticated = true;
    _isGuest = false;
    _status = AuthStatus.authenticated;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? campusOrCity,
    String? campus,
    String? majorOrBio,
  }) => register(
        name: name,
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
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        campusOrCity: campusOrCity,
        majorOrBio: majorOrBio,
      );
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
}
