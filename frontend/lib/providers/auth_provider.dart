import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Employee? _currentUser;
  bool _isLoading = false;

  Employee? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await AuthService.login(email, password);
    if (result) {
      _currentUser = AuthService.currentUser;
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  void logout() {
    AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
