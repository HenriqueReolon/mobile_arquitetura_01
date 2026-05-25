import '../../core/session_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SessionManager sessionManager;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sessionManager,
  });

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await remoteDataSource.login(
      username: username,
      password: password,
    );
    sessionManager.setUser(user);
    return user;
  }
}
