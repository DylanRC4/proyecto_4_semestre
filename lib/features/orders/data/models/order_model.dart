/// Modelo de pedido. Convierte JSON ↔ entidad Order.
import 'package:flash_app/features/orders/domain/entities/order.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.storeId,
    required super.status,
    required super.total,
    required super.createdAt,
    super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['order_items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storeId: json['store_id'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      items: itemsList.map((item) {
        final product = item['products'] as Map<String, dynamic>?;
        return OrderItemEntity(
          productId: item['product_id'] as String? ?? '',
          productName: product?['name'] as String? ?? 'Producto',
          productImage: product?['image_url'] as String? ?? '',
          quantity: (item['quantity'] as num?)?.toInt() ?? 0,
          unitPrice: (item['unit_price'] as num?)?.toDouble() ?? 0,
        );
      }).toList(),
    );
  }
}