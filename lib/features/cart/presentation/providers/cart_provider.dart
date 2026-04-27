/// Proveedor del carrito de compras.
/// Estado inmutable — nunca muta directamente, siempre crea copias nuevas.
/// Persiste automáticamente en SharedPreferences.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_app/features/cart/domain/entities/cart_item.dart';
import 'package:flash_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';

final _cartRepoProvider = Provider((ref) => CartRepositoryImpl());

class CartNotifier extends Notifier<List<CartItemEntity>> {
  CartRepositoryImpl get _repo => ref.read(_cartRepoProvider);

  @override
  List<CartItemEntity> build() {
    _loadFromStorage();
    return [];
  }

  Future<void> _loadFromStorage() async {
    state = await _repo.loadCart();
  }

  void _save() => _repo.saveCart(state);

  /// Retorna null si se agregó, o un mensaje de error si no hay stock suficiente.
  String? addItem(Product product) {
    final enCarrito = state.where((i) => i.product.id == product.id).fold(0, (s, i) => s + i.quantity);
    if (enCarrito >= product.stock) return 'Solo hay ${product.stock} unidades disponibles';
    state = _repo.addItem(state, product);
    _save();
    return null;
  }

  /// Retorna null si se actualizó, o un mensaje de error si excede el stock.
  String? updateQuantity(String productId, int quantity) {
    final item = state.where((i) => i.product.id == productId).firstOrNull;
    if (item != null && quantity > item.product.stock) {
      return 'Solo hay ${item.product.stock} unidades disponibles';
    }
    state = _repo.updateQuantity(state, productId, quantity);
    _save();
    return null;
  }

  void removeItem(String productId) {
    state = _repo.removeItem(state, productId);
    _save();
  }

  void clear() {
    state = [];
    _save();
  }

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItemEntity>>(CartNotifier.new);
