import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

class AppProvider with ChangeNotifier {
  final AuthProvider _authProvider = AuthProvider();
  final UserProvider _userProvider = UserProvider();

  AuthProvider get authProvider => _authProvider;
  UserProvider get userProvider => _userProvider;

  // Initialize providers
  void initialize() {
    _authProvider.addListener(notifyListeners);
    _userProvider.addListener(notifyListeners);
  }

  // Clean up
  @override
  void dispose() {
    _authProvider.dispose();
    _userProvider.dispose();
    super.dispose();
  }

  // Convenience methods to access providers
  bool get isAuthenticated => _authProvider.isAuthenticated;
  String? get token => _authProvider.token;
  String? get userName => _userProvider.name;
  String? get userEmail => _userProvider.email;
  bool get hasUser => _userProvider.hasUser;

  Future<void> login(String email, String password) async {
    await _authProvider.login(email, password);
    if (_authProvider.isAuthenticated) {
      await _userProvider.fetchUserData();
    }
  }

  Future<void> signup(String name, String email, String password) async {
    await _authProvider.signup(name, email, password);
    if (_authProvider.isAuthenticated) {
      _userProvider.setUser(name: name, email: email);
    }
  }

  Future<void> logout() async {
    await _authProvider.logout();
    _userProvider.clearUser();
  }
}
