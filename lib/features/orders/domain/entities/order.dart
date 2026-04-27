/// Entidades de dominio: Pedido y sus elementos.
class OrderEntity {
  final String id;
  final String userId;
  final String storeId;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.status,
    required this.total,
    required this.createdAt,
    this.items = const [],
  });

  String get shortId => id.length >= 8 ? id.substring(0, 8) : id;

  bool get canCancel => status == 'pending' || status == 'confirmed';

  bool get isCancelled => status == 'cancelled' || status == 'expired';
}

class OrderItemEntity {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double unitPrice;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;
}