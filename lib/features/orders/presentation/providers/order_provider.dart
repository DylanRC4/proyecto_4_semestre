/// Proveedor de pedidos (Riverpod).
/// Gestiona CRUD completo y expiración automática de pedidos pendientes.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/features/cart/domain/entities/cart_item.dart';
import 'package:flash_app/features/orders/domain/entities/order.dart';
import 'package:flash_app/features/orders/data/models/order_model.dart';
import 'package:flash_app/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flash_app/features/orders/data/repositories/order_repository_impl.dart';
import 'package:flash_app/core/network/notification_service.dart';

final _orderDatasourceProvider = Provider(
  (ref) => OrderRemoteDatasource(Supabase.instance.client),
);
final _orderRepoProvider = Provider(
  (ref) => OrderRepositoryImpl(ref.read(_orderDatasourceProvider)),
);

/// Estado de pedidos: loading, lista de pedidos y error opcional.
class OrderState {
  final bool isLoading;
  final List<OrderEntity> orders;
  final String? error;
  const OrderState({this.isLoading = false, this.orders = const [], this.error});
  OrderState copyWith({bool? isLoading, List<OrderEntity>? orders, String? error}) =>
      OrderState(
        isLoading: isLoading ?? this.isLoading,
        orders: orders ?? this.orders,
        error: error,
      );
}

class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() {
    Future.microtask(loadOrders);
    return const OrderState(isLoading: true);
  }

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  OrderRepositoryImpl get _repo => ref.read(_orderRepoProvider);

  Future<void> loadOrders() async {
    final userId = _userId;
    if (userId == null) {
      state = const OrderState(error: 'No hay sesión activa');
      return;
    }
    try {
      state = state.copyWith(isLoading: true, error: null);
      try { await _repo.expireOldOrders(userId); } catch (_) {}
      final raw = await _repo.getOrders(userId);
      state = OrderState(orders: raw.map(OrderModel.fromJson).toList());
    } catch (e) {
      state = OrderState(isLoading: false, error: 'Error al cargar pedidos: $e');
    }
  }

  Future<String?> createOrder(List<CartItemEntity> items) async {
    final userId = _userId;
    if (userId == null) return 'No hay sesión activa';
    try {
      state = state.copyWith(isLoading: true);
      final total = items.fold<double>(0, (s, i) => s + i.subtotal);
      final orderId = await _repo.createOrder(
        userId: userId,
        storeId: items.first.product.storeId,
        total: total,
        items: items.map((i) => {
          'product_id': i.product.id,
          'quantity': i.quantity,
          'unit_price': i.product.price,
        }).toList(),
      );
      NotificationService.orderStatusNotification(orderId, 'pending');
      await loadOrders();
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Error al crear el pedido: $e';
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _repo.updateOrderStatus(orderId, newStatus);
      NotificationService.orderStatusNotification(orderId, newStatus);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: 'Error al actualizar: $e');
    }
  }

  Future<String?> cancelOrder(String orderId) async {
    try {
      final order = state.orders.firstWhere((o) => o.id == orderId);
      if (!order.canCancel) return 'No se puede cancelar un pedido listo o entregado.';
      await _repo.cancelOrder(orderId);
      NotificationService.showNotification(
        title: 'Pedido cancelado',
        body: 'Tu pedido #${order.shortId} ha sido cancelado.',
      );
      await loadOrders();
      return null;
    } catch (e) {
      return 'Error al cancelar: $e';
    }
  }
}

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(OrderNotifier.new);
