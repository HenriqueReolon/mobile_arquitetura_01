import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'core/favorites_manager.dart';
import 'core/session_manager.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/pages/login_page.dart';

void main() {
  final apiClient = ApiClient();
  final sessionManager = SessionManager();
  final favoritesManager = FavoritesManager();

  final productDataSource = ProductRemoteDataSource(apiClient: apiClient);
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: productDataSource,
  );

  final authDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authDataSource,
    sessionManager: sessionManager,
  );

  runApp(
    MyApp(
      sessionManager: sessionManager,
      favoritesManager: favoritesManager,
      authRepository: authRepository,
      productRepository: productRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SessionManager sessionManager;
  final FavoritesManager favoritesManager;
  final AuthRepository authRepository;
  final ProductRepository productRepository;

  const MyApp({
    super.key,
    required this.sessionManager,
    required this.favoritesManager,
    required this.authRepository,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividade 4',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(
        authRepository: authRepository,
        productRepository: productRepository,
        sessionManager: sessionManager,
        favoritesManager: favoritesManager,
      ),
    );
  }
}
