/// Interfaz abstracta del repositorio del carrito.
import 'package:flash_app/features/cart/domain/entities/cart_item.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> loadCart();
  Future<void> saveCart(List<CartItemEntity> items);
  List<CartItemEntity> addItem(List<CartItemEntity> current, Product product);
  List<CartItemEntity> removeItem(List<CartItemEntity> current, String productId);
  List<CartItemEntity> updateQuantity(
      List<CartItemEntity> current, String productId, int quantity);
}