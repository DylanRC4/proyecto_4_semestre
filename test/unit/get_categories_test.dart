import 'package:flutter_test/flutter_test.dart';
import 'package:flash_app/features/products/domain/entities/category.dart';
import 'package:flash_app/features/products/domain/repositories/product_repository.dart';
import 'package:flash_app/features/products/domain/usecases/get_categories.dart';

class MockProductRepository implements ProductRepository {
  @override
  Future<List<Category>> getCategories() async {
    return [
      const Category(id: 'c1', name: 'Comida', iconUrl: '', sortOrder: 1),
      const Category(id: 'c2', name: 'Aseo para el hogar', iconUrl: '', sortOrder: 2),
      const Category(id: 'c3', name: 'Ropa Adidas', iconUrl: '', sortOrder: 3),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockProductRepository repository;
  late GetCategories getCategories;

  setUp(() {
    repository = MockProductRepository();
    getCategories = GetCategories(repository);
  });

  test('should return list of categories', () async {
    final result = await getCategories();
    expect(result.length, 3);
    expect(result[0].name, 'Comida');
    expect(result[1].name, 'Aseo para el hogar');
    expect(result[2].name, 'Ropa Adidas');
  });

  test('categories should be ordered by sortOrder', () async {
    final result = await getCategories();
    expect(result[0].sortOrder, 1);
    expect(result[1].sortOrder, 2);
    expect(result[2].sortOrder, 3);
  });
}