/// Caso de uso: Crear pedido nuevo.
import 'package:flash_app/features/orders/domain/repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<String> call({
    required String userId,
    required String storeId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    return await repository.createOrder(
      userId: userId,
      storeId: storeId,
      total: total,
      items: items,
    );
  }
}