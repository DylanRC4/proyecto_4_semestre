/// Caso de uso: Actualizar estado de un pedido.
import 'package:flash_app/features/orders/domain/repositories/order_repository.dart';

class UpdateOrderStatus {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<void> call(String orderId, String status) async {
    return await repository.updateOrderStatus(orderId, status);
  }
}