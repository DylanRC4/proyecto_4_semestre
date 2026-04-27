/// Fuente de datos remota de pedidos (Supabase).
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRemoteDatasource {
  final SupabaseClient _client;

  OrderRemoteDatasource(this._client);

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(name, image_url))')
        .eq('user_id', userId)
        .neq('status', 'expired')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<String> createOrder({
    required String userId,
    required String storeId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final orderResponse = await _client.from('orders').insert({
      'user_id': userId,
      'store_id': storeId,
      'status': 'pending',
      'total': total,
    }).select().single();

    final orderId = orderResponse['id'] as String;

    await _client.from('order_items').insert(
      items.map((item) => {
            'order_id': orderId,
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'unit_price': item['unit_price'],
          }).toList(),
    );

    return orderId;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
  }

  Future<void> cancelOrder(String orderId) async {
    await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', orderId);
  }

  Future<void> expireOldOrders(String userId) async {
    final thirtyMinutesAgo =
        DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String();
    await _client
        .from('orders')
        .update({'status': 'expired'})
        .eq('user_id', userId)
        .eq('status', 'pending')
        .lt('created_at', thirtyMinutesAgo);
  }
}