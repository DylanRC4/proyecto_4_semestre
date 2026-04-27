/// Proveedores Riverpod de productos, categorías y filtrado.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flash_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';
import 'package:flash_app/features/products/domain/entities/category.dart';
import 'package:flash_app/features/products/domain/usecases/get_categories.dart';
import 'package:flash_app/features/products/domain/usecases/get_products.dart';
import 'package:flash_app/features/products/domain/usecases/get_product_by_id.dart';

// Datasource & Repository
final _datasourceProvider = Provider((ref) {
  return ProductRemoteDatasource(Supabase.instance.client);
});

final _repositoryProvider = Provider((ref) {
  return ProductRepositoryImpl(ref.read(_datasourceProvider));
});

// Use Cases
final _getCategoriesProvider = Provider((ref) {
  return GetCategories(ref.read(_repositoryProvider));
});

final _getProductsProvider = Provider((ref) {
  return GetProducts(ref.read(_repositoryProvider));
});

final _getProductByIdProvider = Provider((ref) {
  return GetProductById(ref.read(_repositoryProvider));
});

// State Providers
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final getCategories = ref.read(_getCategoriesProvider);
  return await getCategories();
});

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String?>(
  SelectedCategoryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) {
    state = categoryId;
  }
}

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final getProducts = ref.read(_getProductsProvider);
  final categoryId = ref.watch(selectedCategoryProvider);
  return await getProducts(categoryId: categoryId);
});

final productDetailProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final getProductById = ref.read(_getProductByIdProvider);
  return await getProductById(id);
});