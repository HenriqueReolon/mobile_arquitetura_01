import 'package:flutter/foundation.dart';

/// Mantém, em memória, o conjunto de produtos marcados como favoritos.
///
/// Estende [ChangeNotifier] para que a interface seja atualizada
/// automaticamente (via `ListenableBuilder`) sempre que um favorito é
/// adicionado ou removido — em qualquer tela que observe este manager —
/// sem espalhar chamadas manuais de `setState` entre as telas.
class FavoritesManager extends ChangeNotifier {
  final Set<int> _favoriteIds = {};

  /// IDs dos produtos atualmente favoritados (cópia somente leitura).
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  /// Quantidade de produtos favoritados.
  int get count => _favoriteIds.length;

  /// Indica se o produto está marcado como favorito.
  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  /// Marca o produto como favorito.
  void add(int productId) {
    if (_favoriteIds.add(productId)) {
      notifyListeners();
    }
  }

  /// Remove o produto dos favoritos.
  void remove(int productId) {
    if (_favoriteIds.remove(productId)) {
      notifyListeners();
    }
  }

  /// Alterna o estado de favorito do produto.
  void toggle(int productId) {
    if (!_favoriteIds.add(productId)) {
      _favoriteIds.remove(productId);
    }
    notifyListeners();
  }

  /// Limpa todos os favoritos (ex.: ao efetuar logout).
  void clear() {
    if (_favoriteIds.isEmpty) return;
    _favoriteIds.clear();
    notifyListeners();
  }
}
