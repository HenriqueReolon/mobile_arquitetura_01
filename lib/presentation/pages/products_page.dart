import 'package:flutter/material.dart';
import '../../core/favorites_manager.dart';
import '../../core/session_manager.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'login_page.dart';
import 'product_details_page.dart';
import 'product_form_page.dart';
import 'profile_page.dart';

sealed class ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsSuccess extends ProductsState {
  final List<Product> products;

  ProductsSuccess(this.products);
}

class ProductsError extends ProductsState {
  final String message;

  ProductsError(this.message);
}

class ProductsPage extends StatefulWidget {
  final ProductRepository repository;
  final AuthRepository authRepository;
  final SessionManager sessionManager;
  final FavoritesManager favoritesManager;

  const ProductsPage({
    super.key,
    required this.repository,
    required this.authRepository,
    required this.sessionManager,
    required this.favoritesManager,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  ProductsState _state = ProductsLoading();
  User? _currentUser;
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.sessionManager.currentUser;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget.repository.getProducts();
      if (mounted) {
        setState(() {
          _state = ProductsSuccess(products);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = ProductsError(e.toString());
        });
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: Text('Deseja realmente excluir "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      setState(() {
        _state = ProductsLoading();
      });
      await widget.repository.deleteProduct(product.id);
      _loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
        _loadProducts();
      }
    }
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    widget.sessionManager.clear();
    widget.favoritesManager.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          authRepository: widget.authRepository,
          productRepository: widget.repository,
          sessionManager: widget.sessionManager,
          favoritesManager: widget.favoritesManager,
        ),
      ),
      (route) => false,
    );
  }

  String get _displayName {
    final user = _currentUser;
    if (user == null) return 'Visitante';
    final full = user.fullName;
    return full.isNotEmpty ? full : user.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Produtos'),
            Text(
              'Olá, $_displayName',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: widget.favoritesManager,
            builder: (context, _) {
              return IconButton(
                tooltip: _showOnlyFavorites
                    ? 'Mostrar todos os produtos'
                    : 'Mostrar apenas favoritos',
                icon: Badge(
                  isLabelVisible: widget.favoritesManager.count > 0,
                  label: Text('${widget.favoritesManager.count}'),
                  child: Icon(
                    _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
                onPressed: () => setState(
                  () => _showOnlyFavorites = !_showOnlyFavorites,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      authRepository: widget.authRepository,
                    ),
                  ),
                );
              },
              child: Tooltip(
                message: 'Ver perfil',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage: (_currentUser?.image ?? '').isNotEmpty
                      ? NetworkImage(_currentUser!.image)
                      : null,
                  child: (_currentUser?.image ?? '').isEmpty
                      ? const Icon(Icons.person, color: Colors.blue)
                      : null,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: switch (_state) {
        ProductsLoading() => const Center(child: CircularProgressIndicator()),
        ProductsError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ProductsSuccess(:final products) => ListenableBuilder(
            listenable: widget.favoritesManager,
            builder: (context, _) {
              final displayed = _showOnlyFavorites
                  ? products
                      .where((p) => widget.favoritesManager.isFavorite(p.id))
                      .toList()
                  : products;

              if (displayed.isEmpty) {
                return Center(
                  child: Text(
                    _showOnlyFavorites
                        ? 'Nenhum produto favoritado.'
                        : 'Nenhum produto encontrado.',
                  ),
                );
              }

              return ListView.builder(
                itemCount: displayed.length,
                itemBuilder: (context, index) {
                  final product = displayed[index];
                  final isFavorite =
                      widget.favoritesManager.isFavorite(product.id);
                  return ListTile(
                    leading: Image.network(
                      product.image,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    title: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('\$${product.price}'),
                    trailing: Wrap(
                      spacing: -8,
                      children: [
                        IconButton(
                          tooltip: isFavorite
                              ? 'Remover dos favoritos'
                              : 'Adicionar aos favoritos',
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () =>
                              widget.favoritesManager.toggle(product.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductFormPage(
                                  repository: widget.repository,
                                  product: product,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadProducts();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(
                            repository: widget.repository,
                            productId: product.id,
                            favoritesManager: widget.favoritesManager,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductFormPage(
                repository: widget.repository,
              ),
            ),
          );
          if (result == true) {
            _loadProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

