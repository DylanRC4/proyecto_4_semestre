/// Caso de uso: Obtener producto por ID.
import 'package:flash_app/features/products/domain/entities/product.dart';
import 'package:flash_app/features/products/domain/repositories/product_repository.dart';

class GetProductById {
  final ProductRepository repository;

  GetProductById(this.repository);

  Future<Product> call(String id) async {
    return await repository.getProductById(id);
  }
}