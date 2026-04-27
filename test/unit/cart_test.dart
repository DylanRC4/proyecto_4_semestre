import 'package:flutter_test/flutter_test.dart';
import 'package:flash_app/features/cart/domain/entities/cart_item.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';

void main() {
  const testProduct = Product(
    id: 'p1',
    categoryId: 'c1',
    storeId: 's1',
    name: 'Test Product',
    description: 'A test product',
    price: 10000,
    imageUrl: '',
    stock: 10,
    isActive: true,
  );

  test('CartItemEntity subtotal should be price * quantity', () {
    const item = CartItemEntity(product: testProduct, quantity: 3);
    expect(item.subtotal, 30000);
  });

  test('CartItemEntity copyWith should create new instance', () {
    const item = CartItemEntity(product: testProduct, quantity: 2);
    final updated = item.copyWith(quantity: 5);
    expect(updated.quantity, 5);
    expect(item.quantity, 2);
    expect(updated.product.id, testProduct.id);
  });

  test('CartItemEntity default quantity should be 1', () {
    const item = CartItemEntity(product: testProduct);
    expect(item.quantity, 1);
    expect(item.subtotal, 10000);
  });
}