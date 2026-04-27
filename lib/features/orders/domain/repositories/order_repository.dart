/// Interfaz abstracta del repositorio de pedidos.
abstract class OrderRepository {
  Future<List<Map<String, dynamic>>> getOrders(String userId);
  Future<String> createOrder({
    required String userId,
    required String storeId,
    required double total,
    required List<Map<String, dynamic>> items,
  });
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> cancelOrder(String orderId);
  Future<void> expireOldOrders(String userId);
}