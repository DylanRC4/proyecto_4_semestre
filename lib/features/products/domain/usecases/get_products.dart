/// Caso de uso: Obtener productos (con filtro opcional por categoría).
import 'package:flash_app/features/products/domain/entities/product.dart';
import 'package:flash_app/features/products/domain/repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call({String? categoryId}) async {
    return await repository.getProducts(categoryId: categoryId);
  }
}