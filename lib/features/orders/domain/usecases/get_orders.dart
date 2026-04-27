/// Caso de uso: Obtener pedidos del usuario.
import 'package:flash_app/features/orders/domain/repositories/order_repository.dart';

class GetOrders {
  final OrderRepository repository;

  GetOrders(this.repository);

  Future<List<Map<String, dynamic>>> call(String userId) async {
    return await repository.getOrders(userId);
  }
}