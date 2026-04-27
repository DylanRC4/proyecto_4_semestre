/// Detalle de pedido para trabajador con acciones de gestión.
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/core/network/notification_service.dart';
import 'package:intl/intl.dart';

class WorkerOrderDetailScreen extends StatefulWidget {
  final String orderId;
  const WorkerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<WorkerOrderDetailScreen> createState() =>
      _WorkerOrderDetailScreenState();
}

class _WorkerOrderDetailScreenState
    extends State<WorkerOrderDetailScreen> {
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  String _customerName = 'Cliente';
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
      final orderResponse = await client
          .from('orders')
          .select()
          .eq('id', widget.orderId)
          .single();

      final itemsResponse = await client
          .from('order_items')
          .select('quantity, unit_price, products(name)')
          .eq('order_id', widget.orderId);

      String name = 'Cliente';
      try {
        final profile = await client
            .from('profiles')
            .select('full_name')
            .eq('id', orderResponse['user_id'])
            .single();
        name = profile['full_name'] ?? 'Cliente';
      } catch (_) {}

      if (mounted) {
        setState(() {
          _order = orderResponse;
          _items = List<Map<String, dynamic>>.from(itemsResponse);
          _customerName = name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', widget.orderId);
      NotificationService.orderStatusNotification(
          widget.orderId, newStatus);
      await _loadOrder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Pedido actualizado a: ${_statusLabel(newStatus)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Si fue entregado o cancelado, volver a la lista
      if (newStatus == 'picked_up' || newStatus == 'cancelled') {
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            size: 48, color: Colors.orange),
        title: const Text('¿Cancelar pedido?'),
        content: const Text(
          'El cliente será notificado de la cancelación.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateStatus('cancelled');
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'confirmed': return 'Confirmado';
      case 'preparing': return 'En preparación';
      case 'ready': return 'Listo para recoger';
      case 'picked_up': return 'Entregado';
      case 'cancelled': return 'Cancelado';
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
      default: return Colors.grey;
    }
  }

  String? _nextStatus(String current) {
    const flow = ['pending', 'confirmed', 'preparing', 'ready', 'picked_up'];
    final index = flow.indexOf(current);
    if (index < 0 || index >= flow.length - 1) return null;
    return flow[index + 1];
  }

  String _nextActionLabel(String current) {
    switch (current) {
      case 'pending': return 'Confirmar pedido';
      case 'confirmed': return 'Empezar a preparar';
      case 'preparing': return 'Marcar como listo';
      case 'ready': return 'Entregar al cliente';
      default: return '';
    }
  }

  IconData _nextActionIcon(String current) {
    switch (current) {
      case 'pending': return Icons.check_circle;
      case 'confirmed': return Icons.restaurant;
      case 'preparing': return Icons.store;
      case 'ready': return Icons.shopping_bag;
      default: return Icons.arrow_forward;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a', 'es');
    ElevatedButton.styleFrom(minimumSize: const Size(0, 48));

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

    final status = (_order!['status'] ?? '') as String;
    final total = (_order!['total'] as num?)?.toDouble() ?? 0;
    final createdAt = DateTime.parse(_order!['created_at']).toLocal();
    final statusColor = _statusColor(status);
    final nextStatus = _nextStatus(status);
    final shortId = widget.orderId.length >= 8
        ? widget.orderId.substring(0, 8)
        : widget.orderId;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Pedido #$shortId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info del cliente
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            _customerName.isNotEmpty
                                ? _customerName[0].toUpperCase()
                                : 'C',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(_customerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                'Pedido #$shortId',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          dateFormat.format(createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progreso
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progreso',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 16),
                    _WorkerProgress(status: status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Productos a alistar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Productos a alistar',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('${_items.length} items',
                            style: TextStyle(
                                color:
                                    colorScheme.onSurfaceVariant,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._items.map((item) {
                      final qty =
                          (item['quantity'] as num?)?.toInt() ?? 0;
                      final unitPrice =
                          (item['unit_price'] as num?)?.toDouble() ??
                              0;
                      final productData = item['products'];
                      String productName = 'Producto';
                      if (productData is Map) {
                        productName =
                            (productData['name'] ?? 'Producto')
                                as String;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text('$qty',
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 14,
                                        color: colorScheme
                                            .onPrimaryContainer)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(productName,
                                  style: const TextStyle(
                                      fontSize: 14)),
                            ),
                            Text(
                              currencyFormat
                                  .format(qty * unitPrice),
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(
                          currencyFormat.format(total),
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
            const SizedBox(height: 24),

            // Botón principal de acción
            if (nextStatus != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(nextStatus),
                  icon: Icon(_nextActionIcon(status)),
                  label: Text(
                    _nextActionLabel(status),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Botón cancelar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _cancelOrder,
                icon: const Icon(Icons.cancel_outlined,
                    color: Colors.red),
                label: const Text('Cancelar pedido',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Botón ayuda
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showHelpDialog(),
                icon: const Icon(Icons.help_outline),
                label: const Text('Reportar problema'),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.support_agent,
            size: 48,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('Reportar problema'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Tienes un problema con este pedido?',
                textAlign: TextAlign.center),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.inventory_2),
              title: Text('Producto no disponible'),
              dense: true,
            ),
            ListTile(
              leading: Icon(Icons.error),
              title: Text('Error en el pedido'),
              dense: true,
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Contactar supervisor'),
              subtitle: Text('601-555-FLASH'),
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

class _WorkerProgress extends StatelessWidget {
  final String status;
  const _WorkerProgress({required this.status});

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
        final isCurrent = index == currentIndex;
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
                    border: isCurrent
                        ? Border.all(
                            color: colorScheme.primary, width: 2)
                        : null,
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
                  Container(width: 2, height: 24, color: color),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                step['label'] as String,
                style: TextStyle(
                  fontWeight: isCurrent
                      ? FontWeight.bold
                      : isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                  color: isCompleted
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontSize: isCurrent ? 15 : 14,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}