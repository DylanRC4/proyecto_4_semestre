/// Implementación del carrito con persistencia en SharedPreferences.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash_app/features/cart/domain/entities/cart_item.dart';
import 'package:flash_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';

class CartRepositoryImpl implements CartRepository {
  static const _storageKey = 'flash_cart';

  @override
  Future<List<CartItemEntity>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((item) => _fromJson(item)).toList();
  }

  @override
  Future<void> saveCart(List<CartItemEntity> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(items.map((item) => _toJson(item)).toList());
    await prefs.setString(_storageKey, data);
  }

  @override
  List<CartItemEntity> addItem(List<CartItemEntity> current, Product product) {
    final index = current.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updated = List<CartItemEntity>.from(current);
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      return updated;
    }
    return [...current, CartItemEntity(product: product)];
  }

  @override
  List<CartItemEntity> removeItem(
      List<CartItemEntity> current, String productId) {
    return current.where((item) => item.product.id != productId).toList();
  }

  @override
  List<CartItemEntity> updateQuantity(
      List<CartItemEntity> current, String productId, int quantity) {
    if (quantity <= 0) return removeItem(current, productId);
    final updated = List<CartItemEntity>.from(current);
    final index = updated.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(quantity: quantity);
    }
    return updated;
  }

  Map<String, dynamic> _toJson(CartItemEntity item) => {
        'product': {
          'id': item.product.id,
          'categoryId': item.product.categoryId,
          'storeId': item.product.storeId,
          'name': item.product.name,
          'description': item.product.description,
          'price': item.product.price,
          'imageUrl': item.product.imageUrl,
          'stock': item.product.stock,
          'isActive': item.product.isActive,
        },
        'quantity': item.quantity,
      };

  CartItemEntity _fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    return CartItemEntity(
      product: Product(
        id: p['id'],
        categoryId: p['categoryId'],
        storeId: p['storeId'],
        name: p['name'],
        description: p['description'],
        price: (p['price'] as num).toDouble(),
        imageUrl: p['imageUrl'],
        stock: p['stock'],
        isActive: p['isActive'],
      ),
      quantity: json['quantity'],
    );
  }
}