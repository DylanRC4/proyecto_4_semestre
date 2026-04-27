/// Interfaz abstracta del repositorio de productos.
import 'package:flash_app/features/products/domain/entities/product.dart';
import 'package:flash_app/features/products/domain/entities/category.dart';

abstract class ProductRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts({String? categoryId});
  Future<Product> getProductById(String id);
}