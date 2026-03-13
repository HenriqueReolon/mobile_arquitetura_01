import 'dart:convert';
import '../../core/api_client.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSource({required this.apiClient});

  Future<List<ProductModel>> fetchProducts() async {
    final response = await apiClient.client.get(Uri.parse('https://fakestoreapi.com/products'));
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }
}
