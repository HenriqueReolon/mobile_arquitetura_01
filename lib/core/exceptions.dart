class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException implements Exception {
  final String message;

  InvalidCredentialsException([this.message = 'Usuário ou senha inválidos']);

  @override
  String toString() => message;
}
