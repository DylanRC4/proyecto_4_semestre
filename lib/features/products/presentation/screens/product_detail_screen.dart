/// Detalle de producto con precio en COP y USD (API externa).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flash_app/features/products/presentation/providers/product_provider.dart';
import 'package:flash_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flash_app/core/network/exchange_rate_provider.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final exchangeRate = ref.watch(copToUsdProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final usdFormat =
        NumberFormat.currency(locale: 'en_US', symbol: 'USD ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detalle'),
      ),
      body: productAsync.when(
        data: (product) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: colorScheme.surfaceContainerHighest,
                    highlightColor: colorScheme.surface,
                    child:
                        Container(color: colorScheme.surfaceContainerHighest),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported_outlined,
                        size: 48),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(product.price),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    exchangeRate.when(
                      data: (rate) => Text(
                        usdFormat.format(product.price * rate),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      loading: () => Text(
                        'Calculando USD...',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? colorScheme.primaryContainer
                            : colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.stock > 0
                            ? '${product.stock} disponibles'
                            : 'Agotado',
                        style: TextStyle(
                          color: product.stock > 0
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Descripción',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.currency_exchange,
                                size: 20, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: exchangeRate.when(
                                data: (rate) => Text(
                                  'Tasa de cambio: 1 COP = ${rate.toStringAsFixed(6)} USD (API externa en tiempo real)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                loading: () => Text(
                                  'Obteniendo tasa de cambio...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                error: (_, _) => Text(
                                  'Tasa de cambio no disponible',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: product.stock > 0
                            ? () {
                                final error = ref.read(cartProvider.notifier).addItem(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error ?? '${product.name} agregado al carrito'),
                                    backgroundColor: error != null ? Colors.orange : null,
                                    behavior: SnackBarBehavior.floating,
                                    action: error == null ? SnackBarAction(
                                      label: 'Ver carrito',
                                      onPressed: () => context.push('/cart'),
                                    ) : null,
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text(
                          'Agregar al carrito',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              const Text('Error al cargar el producto'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(productDetailProvider(productId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}