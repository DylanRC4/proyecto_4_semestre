/// Lista de pedidos para el trabajador (ordenados por antigüedad).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class WorkerOrdersScreen extends StatefulWidget {
  const WorkerOrdersScreen({super.key});

  @override
  State<WorkerOrdersScreen> createState() => _WorkerOrdersScreenState();
}

class _WorkerOrdersScreenState extends State<WorkerOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('orders')
          .select()
          .order('created_at', ascending: true);

      final allOrders = List<Map<String, dynamic>>.from(response);
      final activeStatuses = ['pending', 'confirmed', 'preparing', 'ready'];
      final filtered = allOrders
          .where((o) => activeStatuses.contains(o['status'] ?? ''))
          .toList();

      // Cargar nombre del cliente
      for (var order in filtered) {
        try {
          final profile = await client
              .from('profiles')
              .select('full_name')
              .eq('id', order['user_id'])
              .single();
          order['customer_name'] = profile['full_name'] ?? 'Cliente';
        } catch (_) {
          order['customer_name'] = 'Cliente';
        }

        // Contar items
        try {
          final items = await client
              .from('order_items')
              .select('quantity')
              .eq('order_id', order['id']);
          final itemsList = List<Map<String, dynamic>>.from(items);
          order['item_count'] = itemsList.fold<int>(
              0, (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0));
        } catch (_) {
          order['item_count'] = 0;
        }
      }

      if (mounted) {
        setState(() {
          _orders = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'ready':
        return 'Listo';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.store;
      default:
        return Icons.info_outline;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final timeFormat = DateFormat('hh:mm a', 'es');
    final buttonStyle =
        ElevatedButton.styleFrom(minimumSize: const Size(0, 40));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on_rounded, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Flash Trabajador',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Error: $_error',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: buttonStyle,
                        ),
                      ],
                    ),
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 80,
                              color: colorScheme.outlineVariant),
                          const SizedBox(height: 16),
                          const Text('No hay pedidos pendientes',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('¡Buen trabajo!',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadOrders,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Actualizar'),
                            style: buttonStyle,
                          ),
                        ],
                      ),
                    )
                  : _buildContent(
                      colorScheme, currencyFormat, timeFormat),
    );
  }

  Widget _buildContent(ColorScheme colorScheme,
      NumberFormat currencyFormat, DateFormat timeFormat) {
    final pending =
        _orders.where((o) => o['status'] == 'pending').length;
    final confirmed =
        _orders.where((o) => o['status'] == 'confirmed').length;
    final preparing =
        _orders.where((o) => o['status'] == 'preparing').length;
    final ready =
        _orders.where((o) => o['status'] == 'ready').length;

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('$pending', 'Nuevos', Colors.orange),
                  _stat('$confirmed', 'Confirmados', Colors.blue),
                  _stat('$preparing', 'Preparando', Colors.purple),
                  _stat('$ready', 'Listos', Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Toca un pedido para ver detalle y gestionar',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._orders.map((order) {
            final status = (order['status'] ?? '') as String;
            final total =
                (order['total'] as num?)?.toDouble() ?? 0;
            final orderId = (order['id'] ?? '') as String;
            final customerName =
                (order['customer_name'] ?? 'Cliente') as String;
            final statusColor = _statusColor(status);
            final shortId = orderId.length >= 8
                ? orderId.substring(0, 8)
                : orderId;
            final createdAt =
                DateTime.parse(order['created_at']).toLocal();
            final timeAgo = _timeAgo(createdAt);
            final itemCount =
                (order['item_count'] as num?)?.toInt() ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await context.push('/worker/order/$orderId');
                  _loadOrders();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icono de estado
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_statusIcon(status),
                            color: statusColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      // Info del pedido
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 14,
                                    color: colorScheme.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    customerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '#$shortId · ${timeFormat.format(createdAt)} · $timeAgo',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$itemCount productos · ${currencyFormat.format(total)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge de estado
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(Icons.chevron_right,
                              color:
                                  colorScheme.onSurfaceVariant,
                              size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _stat(String count, String label, Color color) {
    return Column(
      children: [
        Text(count,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer)),
      ],
    );
  }
}