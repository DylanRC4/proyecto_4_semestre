import 'package:flutter_test/flutter_test.dart';
import 'package:flash_app/features/cart/domain/entities/cart_item.dart';
import 'package:flash_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';

void main() {
  const product1 = Product(
    id: 'p1', categoryId: 'c1', storeId: 's1',
    name: 'Arroz', description: 'Arroz blanco',
    price: 18500, imageUrl: '', stock: 50, isActive: true,
  );

  const product2 = Product(
    id: 'p2', categoryId: 'c1', storeId: 's1',
    name: 'Aceite', description: 'Aceite vegetal',
    price: 8500, imageUrl: '', stock: 40, isActive: true,
  );

  late CartRepositoryImpl repository;

  setUp(() {
    repository = CartRepositoryImpl();
  });

  group('addItem', () {
    test('should add new product to empty cart', () {
      final result = repository.addItem([], product1);
      expect(result.length, 1);
      expect(result[0].product.id, 'p1');
      expect(result[0].quantity, 1);
    });

    test('should increment quantity if product already in cart', () {
      final cart = [const CartItemEntity(product: product1, quantity: 1)];
      final result = repository.addItem(cart, product1);
      expect(result.length, 1);
      expect(result[0].quantity, 2);
    });

    test('should add different product as new item', () {
      final cart = [const CartItemEntity(product: product1, quantity: 1)];
      final result = repository.addItem(cart, product2);
      expect(result.length, 2);
    });
  });

  group('removeItem', () {
    test('should remove product from cart', () {
      final cart = [
        const CartItemEntity(product: product1, quantity: 2),
        const CartItemEntity(product: product2, quantity: 1),
      ];
      final result = repository.removeItem(cart, 'p1');
      expect(result.length, 1);
      expect(result[0].product.id, 'p2');
    });

    test('should return empty list if removing last item', () {
      final cart = [const CartItemEntity(product: product1, quantity: 1)];
      final result = repository.removeItem(cart, 'p1');
      expect(result.isEmpty, true);
    });
  });

  group('updateQuantity', () {
    test('should update quantity of existing item', () {
      final cart = [const CartItemEntity(product: product1, quantity: 1)];
      final result = repository.updateQuantity(cart, 'p1', 5);
      expect(result[0].quantity, 5);
    });

    test('should remove item if quantity is 0', () {
      final cart = [const CartItemEntity(product: product1, quantity: 1)];
      final result = repository.updateQuantity(cart, 'p1', 0);
      expect(result.isEmpty, true);
    });

    test('should remove item if quantity is negative', () {
      final cart = [const CartItemEntity(product: product1, quantity: 1)];
      final result = repository.updateQuantity(cart, 'p1', -1);
      expect(result.isEmpty, true);
    });
  });
}