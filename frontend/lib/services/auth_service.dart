import '../models/employee.dart';
import 'api_service.dart';

class AuthService {
  static Employee? _currentUser;
  static Employee? get currentUser => _currentUser;

  static bool get isLoggedIn => _currentUser != null;

  static Future<bool> login(String email, String password) async {
    try {
      final user = await ApiService.login(email, password);
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  static void logout() {
    _currentUser = null;
  }
}
