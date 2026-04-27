/// Detalle de pedido: QR, progreso, productos y cancelación.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/features/orders/presentation/providers/order_provider.dart';
import 'package:flash_app/features/orders/data/models/order_model.dart';
import 'package:flash_app/features/orders/domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  OrderEntity? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('orders')
          .select('*, order_items(*, products(name, image_url))')
          .eq('id', widget.orderId)
          .single();

      if (mounted) {
        setState(() {
          _order = OrderModel.fromJson(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'confirmed': return 'Confirmado';
      case 'preparing': return 'En preparacion';
      case 'ready': return 'Listo para recoger!';
      case 'picked_up': return 'Entregado';
      case 'cancelled': return 'Cancelado';
      case 'expired': return 'Expirado';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.purple;
      case 'ready': return Colors.green;
      case 'picked_up': return Colors.grey;
      case 'cancelled': return Colors.red;
      case 'expired': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a', 'es');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del pedido')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del pedido')),
        body: const Center(child: Text('Pedido no encontrado')),
      );
    }

    final order = _order!;
    final statusColor = _statusColor(order.status);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Pedido #${order.shortId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrder,
          ),
          if (order.canCancel)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cancel') {
                  _showCancelDialog();
                } else if (value == 'help') {
                  _showHelpDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Cancelar pedido'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Pedir ayuda'),
                    ],
                  ),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelpDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // QR o estado cancelado
            if (!order.isCancelled)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        order.status == 'ready'
                            ? 'Muestra este codigo en la tienda!'
                            : 'Codigo de tu pedido',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: 'FLASH-ORDER:${order.id}',
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        order.status == 'cancelled'
                            ? Icons.cancel
                            : Icons.timer_off,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusLabel(order.status),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.status == 'cancelled'
                            ? 'Este pedido fue cancelado.'
                            : 'Este pedido expiro por falta de confirmacion.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Progreso
            if (!order.isCancelled)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Progreso del pedido',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _DetailedProgress(status: order.status),
                    ],
                  ),
                ),
              ),
            if (!order.isCancelled) const SizedBox(height: 16),

            // Productos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Productos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.productName}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                currencyFormat.format(item.subtotal),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          currencyFormat.format(order.total),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(order.createdAt.toLocal()),
                          style:
                              TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.tag,
                            size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.id,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones
            if (order.canCancel)
              OutlinedButton.icon(
                onPressed: _showCancelDialog,
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text('Cancelar pedido',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            if (!order.isCancelled && order.status != 'picked_up')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: _showHelpDialog,
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Necesito ayuda con este pedido'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            size: 48, color: Colors.orange),
        title: const Text('Cancelar pedido?'),
        content: const Text(
          'Esta accion no se puede deshacer. Si ya realizaste un pago, el reembolso puede tardar de 3 a 5 dias habiles.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await ref
                  .read(orderProvider.notifier)
                  .cancelOrder(widget.orderId);
              if (mounted) {
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(error),
                        backgroundColor: colorScheme.error),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pedido cancelado'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  await _loadOrder();
                }
              }
            },
            child: const Text('Si, cancelar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.support_agent,
            size: 48, color: Theme.of(context).colorScheme.primary),
        title: const Text('Soporte Flash'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Necesitas ayuda con tu pedido?',
                textAlign: TextAlign.center),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Llamanos'),
              subtitle: Text('601-555-FLASH'),
              dense: true,
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Escribenos'),
              subtitle: Text('soporte@flash.com.co'),
              dense: true,
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat en vivo'),
              subtitle: Text('Lun-Sab 8am a 8pm'),
              dense: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _DetailedProgress extends StatelessWidget {
  final String status;
  const _DetailedProgress({required this.status});

  @override
  Widget build(BuildContext context) {
    const steps = [
      {'key': 'pending', 'label': 'Recibido', 'icon': Icons.receipt_long},
      {'key': 'confirmed', 'label': 'Confirmado', 'icon': Icons.check_circle},
      {'key': 'preparing', 'label': 'Preparando', 'icon': Icons.restaurant},
      {'key': 'ready', 'label': 'Listo', 'icon': Icons.store},
      {'key': 'picked_up', 'label': 'Entregado', 'icon': Icons.shopping_bag},
    ];

    final currentIndex = steps.indexWhere((s) => s['key'] == status);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;
        final color =
            isCompleted ? colorScheme.primary : colorScheme.outlineVariant;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    size: 16,
                    color: isCompleted
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 32, color: color),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                step['label'] as String,
                style: TextStyle(
                  fontWeight:
                      isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}