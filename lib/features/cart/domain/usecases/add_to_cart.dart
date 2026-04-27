/// Caso de uso: Agregar producto al carrito.
import 'package:flash_app/features/cart/domain/entities/cart_item.dart';
import 'package:flash_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';

class AddToCart {
  final CartRepository repository;

  AddToCart(this.repository);

  List<CartItemEntity> call(List<CartItemEntity> current, Product product) {
    return repository.addItem(current, product);
  }
}