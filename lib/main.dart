import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/pages/products_page.dart';

void main() {
  final apiClient = ApiClient();
  final remoteDataSource = ProductRemoteDataSource(apiClient: apiClient);
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ProductRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividade 4',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductsPage(repository: repository),
    );
  }
}
