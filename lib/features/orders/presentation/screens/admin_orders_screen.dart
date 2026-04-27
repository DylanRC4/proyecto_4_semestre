/// Panel admin: dashboard, gestión de productos y clientes.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flash_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flash_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:intl/intl.dart';

final _productDatasource = Provider(
  (ref) => ProductRemoteDatasource(Supabase.instance.client),
);

final _profileDatasource = Provider(
  (ref) => ProfileRemoteDatasource(Supabase.instance.client),
);

final adminProductsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final datasource = ref.read(_productDatasource);
  return await datasource.getAllProducts();
});

final adminCustomersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final datasource = ref.read(_profileDatasource);
  return await datasource.getAllProfiles();
});

final adminStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final datasource = ref.read(_productDatasource);
  return await datasource.getAdminStats();
});

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on_rounded, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Flash Admin',
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
            onPressed: () {
              ref.invalidate(adminStatsProvider);
              ref.invalidate(adminProductsProvider);
              ref.invalidate(adminCustomersProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.inventory_2), text: 'Productos'),
            Tab(icon: Icon(Icons.people), text: 'Clientes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DashboardTab(),
          _ProductsTab(),
          _CustomersTab(),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen general',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.today,
                    label: 'Pedidos hoy',
                    value: '${stats['todayOrders']}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending_actions,
                    label: 'Pedidos activos',
                    value: '${stats['activeOrders']}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money,
                    label: 'Ingresos totales',
                    value: currencyFormat.format(stats['totalRevenue']),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_bag,
                    label: 'Total pedidos',
                    value: '${stats['totalOrders']}',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2,
                    label: 'Productos',
                    value: '${stats['totalProducts']}',
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    label: 'Clientes',
                    value: '${stats['totalCustomers']}',
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $e', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(adminStatsProvider),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return productsAsync.when(
      data: (products) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isActive = product['is_active'] as bool;
          final stock = product['stock'] as int;
          final category = product['categories']?['name'] ?? 'Sin categoria';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
              title: Text(product['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '$category · Stock: $stock · ${currencyFormat.format(product['price'])}',
                style: TextStyle(
                    fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              trailing: Switch(
                value: isActive,
                activeColor: colorScheme.primary,
                onChanged: (value) async {
                  final datasource = ref.read(_productDatasource);
                  await datasource.updateProductStatus(
                      product['id'] as String, value);
                  ref.invalidate(adminProductsProvider);
                },
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _CustomersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(adminCustomersProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return customersAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return const Center(child: Text('No hay clientes registrados'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            final name = customer['full_name'] ?? 'Sin nombre';
            final phone = customer['phone'] ?? 'Sin telefono';
            final createdAt = DateTime.parse(customer['created_at']);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Tel: $phone · Desde: ${dateFormat.format(createdAt.toLocal())}',
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}