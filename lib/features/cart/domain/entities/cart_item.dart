/// Entidad de dominio: Elemento del carrito (producto + cantidad).
import 'package:flash_app/features/products/domain/entities/product.dart';

class CartItemEntity {
  final Product product;
  final int quantity;

  const CartItemEntity({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  CartItemEntity copyWith({Product? product, int? quantity}) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}