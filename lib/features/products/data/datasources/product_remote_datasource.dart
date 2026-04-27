/// Fuente de datos remota de productos (Supabase REST API).
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/features/products/data/models/product_model.dart';
import 'package:flash_app/features/products/data/models/category_model.dart';

class ProductRemoteDatasource {
  final SupabaseClient _client;

  ProductRemoteDatasource(this._client);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('sort_order');
    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  Future<List<ProductModel>> getProducts({String? categoryId}) async {
    var query = _client.from('products').select().eq('is_active', true);
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final response = await query.order('name');
    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', id)
        .single();
    return ProductModel.fromJson(response);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final response = await _client
        .from('products')
        .select('*, categories(name)')
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateProductStatus(String productId, bool isActive) async {
    await _client
        .from('products')
        .update({'is_active': isActive})
        .eq('id', productId);
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final orders = await _client.from('orders').select('total, status, created_at');
    final products = await _client.from('products').select('id');
    final customers = await _client.from('profiles').select('id');

    final ordersList = List<Map<String, dynamic>>.from(orders);
    final totalRevenue = ordersList
        .where((o) => o['status'] != 'cancelled' && o['status'] != 'expired')
        .fold<double>(0, (sum, o) => sum + (o['total'] as num).toDouble());
    final todayOrders = ordersList.where((o) =>
        DateTime.parse(o['created_at']).toLocal().day == DateTime.now().day);
    final activeOrders = ordersList.where((o) =>
        o['status'] != 'picked_up' &&
        o['status'] != 'cancelled' &&
        o['status'] != 'expired');

    return {
      'totalOrders': ordersList.length,
      'activeOrders': activeOrders.length,
      'todayOrders': todayOrders.length,
      'totalRevenue': totalRevenue,
      'totalProducts': (products as List).length,
      'totalCustomers': (customers as List).length,
    };
  }
}