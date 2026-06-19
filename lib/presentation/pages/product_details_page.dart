import 'package:flutter/material.dart';
import '../../core/favorites_manager.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

sealed class ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsSuccess extends ProductDetailsState {
  final Product product;
  ProductDetailsSuccess(this.product);
}

class ProductDetailsError extends ProductDetailsState {
  final String message;
  ProductDetailsError(this.message);
}

class ProductDetailsPage extends StatefulWidget {
  final ProductRepository repository;
  final int productId;
  final FavoritesManager favoritesManager;

  const ProductDetailsPage({
    super.key,
    required this.repository,
    required this.productId,
    required this.favoritesManager,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductDetailsState _state = ProductDetailsLoading();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await widget.repository.getProduct(widget.productId);
      if (mounted) {
        setState(() {
          _state = ProductDetailsSuccess(product);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = ProductDetailsError(e.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          ListenableBuilder(
            listenable: widget.favoritesManager,
            builder: (context, _) {
              final isFavorite =
                  widget.favoritesManager.isFavorite(widget.productId);
              return IconButton(
                tooltip: isFavorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () =>
                    widget.favoritesManager.toggle(widget.productId),
              );
            },
          ),
        ],
      ),
      body: switch (_state) {
        ProductDetailsLoading() => const Center(child: CircularProgressIndicator()),
        ProductDetailsError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ProductDetailsSuccess(:final product) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    product.image,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(product.category),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
      },
    );
  }
}
