import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/user_preferences_constants.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  AuthProvider() {
    _loadFromSharedPreferences();
  }

  Future<void> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _isAuthenticated = prefs.getBool(UserPreferencesConstants.isAuthenticatedKey) ?? false;
    _token = prefs.getString(UserPreferencesConstants.tokenKey);

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, assume login is always successful
    _isAuthenticated = true;
    _token = 'sample_token_${DateTime.now().millisecondsSinceEpoch}';

    // In a real app, name would come from the server response
    // For demo purposes, we'll use email as name
    String userName = email.split('@')[0]; // Extract username from email

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(UserPreferencesConstants.isAuthenticatedKey, _isAuthenticated);
    await prefs.setString(UserPreferencesConstants.tokenKey, _token!);
    await prefs.setString(UserPreferencesConstants.userNameKey, userName);
    await prefs.setString(UserPreferencesConstants.userEmailKey, email);

    notifyListeners();
  }

  Future<void> signup(String name, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, assume signup is always successful
    _isAuthenticated = true;
    _token = 'sample_token_${DateTime.now().millisecondsSinceEpoch}';

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(UserPreferencesConstants.isAuthenticatedKey, _isAuthenticated);
    await prefs.setString(UserPreferencesConstants.tokenKey, _token!);
    await prefs.setString(UserPreferencesConstants.userIdKey, DateTime.now().millisecondsSinceEpoch.toString());
    await prefs.setString(UserPreferencesConstants.userNameKey, name);
    await prefs.setString(UserPreferencesConstants.userEmailKey, email);

    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;

    // Clear from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(UserPreferencesConstants.isAuthenticatedKey, false);
    await prefs.remove(UserPreferencesConstants.tokenKey);
    await prefs.remove(UserPreferencesConstants.userIdKey);
    await prefs.remove(UserPreferencesConstants.userNameKey);
    await prefs.remove(UserPreferencesConstants.userEmailKey);
    await prefs.remove(UserPreferencesConstants.userProfilePictureKey);

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();

    _isAuthenticated = prefs.getBool(UserPreferencesConstants.isAuthenticatedKey) ?? false;
    _token = prefs.getString(UserPreferencesConstants.tokenKey);

    notifyListeners();
  }
}
