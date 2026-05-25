import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});
}
