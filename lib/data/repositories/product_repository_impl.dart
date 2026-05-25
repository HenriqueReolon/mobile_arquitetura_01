import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  List<Product>? _cachedProducts;
  final List<Product> _localProducts = [];
  final Set<int> _localProductIds = {};

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    try {
      final products = await remoteDataSource.fetchProducts();
      _cachedProducts = [...products, ..._localProducts];
      return _cachedProducts!;
    } catch (e) {
      if (_cachedProducts != null && _cachedProducts!.isNotEmpty) {
        return _cachedProducts!;
      }
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    if (_localProductIds.contains(id)) {
      return _localProducts.firstWhere((p) => p.id == id);
    }
    if (_cachedProducts != null) {
      try {
        return _cachedProducts!.firstWhere((p) => p.id == id);
      } catch (_) {}
    }
    return await remoteDataSource.fetchProduct(id);
  }

  @override
  Future<Product> addProduct(Product product) async {
    final productModel = _toModel(product);
    final result = await remoteDataSource.addProduct(productModel);
    _localProductIds.add(result.id);
    _localProducts.add(result);
    _cachedProducts?.add(result);
    return result;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final productModel = _toModel(product);

    if (_localProductIds.contains(product.id)) {
      _replaceInList(_localProducts, productModel);
      _replaceInCache(productModel);
      return productModel;
    }

    final result = await remoteDataSource.updateProduct(productModel);
    _replaceInCache(result);
    return result;
  }

  @override
  Future<void> deleteProduct(int id) async {
    if (_localProductIds.contains(id)) {
      _localProductIds.remove(id);
      _localProducts.removeWhere((p) => p.id == id);
    } else {
      await remoteDataSource.deleteProduct(id);
    }
    _cachedProducts?.removeWhere((p) => p.id == id);
  }

  ProductModel _toModel(Product product) => ProductModel(
        id: product.id,
        title: product.title,
        price: product.price,
        description: product.description,
        category: product.category,
        image: product.image,
      );

  void _replaceInList(List<Product> list, Product product) {
    final index = list.indexWhere((p) => p.id == product.id);
    if (index != -1) list[index] = product;
  }

  void _replaceInCache(Product product) {
    final cache = _cachedProducts;
    if (cache != null) _replaceInList(cache, product);
  }
}
