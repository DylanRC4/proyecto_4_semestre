/// Implementación del repositorio de productos.
import 'package:flash_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';
import 'package:flash_app/features/products/domain/entities/category.dart';
import 'package:flash_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;

  ProductRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Category>> getCategories() async {
    return await remoteDatasource.getCategories();
  }

  @override
  Future<List<Product>> getProducts({String? categoryId}) async {
    return await remoteDatasource.getProducts(categoryId: categoryId);
  }

  @override
  Future<Product> getProductById(String id) async {
    return await remoteDatasource.getProductById(id);
  }
}