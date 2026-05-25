import 'dart:convert';
import '../../core/api_client.dart';
import '../../core/exceptions.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.client.post(
        Uri.parse('https://dummyjson.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        throw InvalidCredentialsException();
      } else {
        throw ServerException(
          'Erro ao realizar login. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is InvalidCredentialsException) rethrow;
      if (e is ServerException) rethrow;
      throw ServerException('Falha de comunicação com a API');
    }
  }
}
