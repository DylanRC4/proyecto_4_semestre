/// Pantalla de historial de pedidos del cliente.
/// Muestra lista con estado, progreso y total de cada pedido.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_app/features/orders/presentation/providers/order_provider.dart';
import 'package:flash_app/features/orders/domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderProvider);
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: const Text('Mis pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(orderProvider.notifier).loadOrders(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: () => ref.read(orderProvider.notifier).loadOrders())
              : state.orders.isEmpty
                  ? _EmptyView(onExplore: () => context.go('/home'))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.orders.length,
                        itemBuilder: (ctx, i) => _OrderCard(
                          order: state.orders[i],
                          fmt: fmt,
                          onTap: () => context.push('/order/${state.orders[i].id}'),
                        ),
                      ),
                    ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyView({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          const Text('No tienes pedidos', style: TextStyle(fontSize: 16)),
          TextButton(onPressed: onExplore, child: const Text('Explorar productos')),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final NumberFormat fmt;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.fmt, required this.onTap});

  Color _color(String s) => switch (s) {
        'pending' => Colors.orange,
        'confirmed' => Colors.blue,
        'preparing' => Colors.purple,
        'ready' => Colors.green,
        'picked_up' => Colors.grey,
        _ => Colors.red,
      };

  String _label(String s) => switch (s) {
        'pending' => 'Pendiente',
        'confirmed' => 'Confirmado',
        'preparing' => 'Preparando',
        'ready' => 'Listo',
        'picked_up' => 'Entregado',
        'cancelled' => 'Cancelado',
        _ => 'Expirado',
      };

  double _progress(String s) => switch (s) {
        'pending' => 0.2,
        'confirmed' => 0.4,
        'preparing' => 0.6,
        'ready' => 0.8,
        'picked_up' => 1.0,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _color(order.status);
    final date = DateFormat('dd MMM, hh:mm a', 'es').format(order.createdAt.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${order.shortId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(_label(order.status), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(date, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              if (!order.isCancelled) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _progress(order.status),
                  backgroundColor: cs.surfaceContainerHighest,
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${order.items.length} productos', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                  Text(fmt.format(order.total), style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
