/// Pantalla del carrito con controles de cantidad y total.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:intl/intl.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mi carrito'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Vaciar carrito'),
                    content:
                        const Text('Estas seguro de vaciar el carrito?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartNotifier.clear();
                          Navigator.pop(ctx);
                        },
                        child: Text('Vaciar',
                            style: TextStyle(color: colorScheme.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Tu carrito esta vacio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Explorar productos'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorWidget: (c, u, e) => Container(
                                    width: 80,
                                    height: 80,
                                    color:
                                        colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(item.subtotal),
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => cartNotifier.updateQuantity(item.product.id, item.quantity - 1),
                                    iconSize: 22,
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      final error = cartNotifier.updateQuantity(item.product.id, item.quantity + 1);
                                      if (error != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(error), backgroundColor: Colors.orange, duration: const Duration(seconds: 2)),
                                        );
                                      }
                                    },
                                    iconSize: 22,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currencyFormat.format(cartNotifier.total),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/checkout'),
                          icon: const Icon(Icons.flash_on),
                          label: const Text('Ir a pagar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}