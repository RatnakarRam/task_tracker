import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String? _name;
  String? _email;

  String? get name => _name;
  String? get email => _email;

  bool get hasUser => _name != null && _email != null;

  void setUser({String? name, String? email}) {
    _name = name;
    _email = email;
    notifyListeners();
  }

  void clearUser() {
    _name = null;
    _email = null;
    notifyListeners();
  }

  // Simulate fetching user data from API
  Future<void> fetchUserData() async {
    // In a real app, this would be an API call
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes
    _name = 'Demo User';
    _email = 'demo@example.com';
    notifyListeners();
  }
}
