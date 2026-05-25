import '../entities/user.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});
  Future<UserProfile> getCurrentUser();
}
