/// Caso de uso: Obtener categorías.
import 'package:flash_app/features/products/domain/entities/category.dart';
import 'package:flash_app/features/products/domain/repositories/product_repository.dart';

class GetCategories {
  final ProductRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}