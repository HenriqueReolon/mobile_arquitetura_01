import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductsPage extends StatelessWidget {
  final ProductRepository repository;

  const ProductsPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: FutureBuilder<List<Product>>(
        future: repository.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product.image, width: 50, height: 50),
                title: Text(product.title),
                subtitle: Text('\$${product.price}'),
              );
            },
          );
        },
      ),
    );
  }
}
