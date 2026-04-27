import 'package:flutter_test/flutter_test.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';
import 'package:flash_app/features/products/domain/entities/category.dart';
import 'package:flash_app/features/products/domain/usecases/get_products.dart';
import 'package:flash_app/features/products/domain/repositories/product_repository.dart';

class MockProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts({String? categoryId}) async {
    final products = const [
      Product(
        id: '1', categoryId: 'cat1', storeId: 's1',
        name: 'Arroz', description: 'Arroz blanco',
        price: 18500, imageUrl: '', stock: 50, isActive: true,
      ),
      Product(
        id: '2', categoryId: 'cat2', storeId: 's1',
        name: 'Camiseta', description: 'Camiseta algodón',
        price: 35000, imageUrl: '', stock: 25, isActive: true,
      ),
    ];
    if (categoryId != null) {
      return products.where((p) => p.categoryId == categoryId).toList();
    }
    return products;
  }

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<Product> getProductById(String id) async =>
      throw UnimplementedError();
}

void main() {
  late GetProducts useCase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    useCase = GetProducts(repository);
  });

  test('should return all products when no category filter', () async {
    final result = await useCase();
    expect(result.length, 2);
  });

  test('should filter products by category', () async {
    final result = await useCase(categoryId: 'cat1');
    expect(result.length, 1);
    expect(result[0].name, 'Arroz');
  });
}