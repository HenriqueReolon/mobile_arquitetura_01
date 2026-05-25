import '../domain/entities/user.dart';

class SessionManager {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  void setUser(User user) {
    _currentUser = user;
  }

  void clear() {
    _currentUser = null;
  }
}
