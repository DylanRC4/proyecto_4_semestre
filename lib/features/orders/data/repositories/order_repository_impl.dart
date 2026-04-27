/// Implementación del repositorio de pedidos.
import 'package:flash_app/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flash_app/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource remoteDatasource;

  OrderRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    return await remoteDatasource.getOrders(userId);
  }

  @override
  Future<String> createOrder({
    required String userId,
    required String storeId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    return await remoteDatasource.createOrder(
      userId: userId,
      storeId: storeId,
      total: total,
      items: items,
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    return await remoteDatasource.updateOrderStatus(orderId, status);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    return await remoteDatasource.cancelOrder(orderId);
  }

  @override
  Future<void> expireOldOrders(String userId) async {
    return await remoteDatasource.expireOldOrders(userId);
  }
}