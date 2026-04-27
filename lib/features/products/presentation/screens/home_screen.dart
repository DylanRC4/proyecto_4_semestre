/// Pantalla principal: banner hero, categorías y grilla de productos.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flash_app/features/products/presentation/providers/product_provider.dart';
import 'package:flash_app/features/products/domain/entities/product.dart';
import 'package:flash_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const _logo =
      'https://sdsstyqhgirubafmvfnk.supabase.co/storage/v1/object/public/products/logo-marca/logomodoclaro.png';
  static const _heroImage =
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80';

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : screenWidth > 600 ? 3 : 2;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: _logo,
                  height: 36,
                  width: 36,
                  errorWidget: (c, u, e) => Icon(Icons.flash_on_rounded,
                      color: colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 8),
                Text(
                  'Flash',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/cart'),
                  ),
                  Consumer(builder: (context, ref, _) {
                    final cart = ref.watch(cartProvider);
                    if (cart.isEmpty) return const SizedBox.shrink();
                    return Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                onPressed: () => context.push('/orders'),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.push('/profile'),
              ),
            ],
          ),

          // Hero Banner grande
          SliverToBoxAdapter(
            child: Container(
              height: 280,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(_heroImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Tu mercado sin\nbajarte del carro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Elige, paga y recoge en autoservicio.\nEl mercado del futuro ya esta aqui.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Baja al catálogo de productos
                        _scrollController.animateTo(
                          500,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.flash_on, size: 18),
                      label: const Text('Comenzar a comprar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Caracteristicas centradas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _FeatureChip(
                      icon: Icons.home_outlined,
                      label: 'Elige desde\ncasa',
                      color: Colors.blue),
                  _FeatureChip(
                      icon: Icons.flash_on,
                      label: 'Pedido\nrapido',
                      color: Colors.green),
                  _FeatureChip(
                      icon: Icons.directions_car_outlined,
                      label: 'Auto\nservicio',
                      color: Colors.purple),
                  _FeatureChip(
                      icon: Icons.lock_outlined,
                      label: 'Pago\nseguro',
                      color: Colors.orange),
                ],
              ),
            ),
          ),

          // Titulo categorias
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Explora por categoria',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Categorias
          SliverToBoxAdapter(
            child: categories.when(
              data: (cats) => SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Todos'),
                        selected: selectedCategory == null,
                        onSelected: (_) => ref
                            .read(selectedCategoryProvider.notifier)
                            .select(null),
                      ),
                    ),
                    ...cats.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.name),
                          selected: selectedCategory == cat.id,
                          onSelected: (_) => ref
                              .read(selectedCategoryProvider.notifier)
                              .select(
                                  selectedCategory == cat.id ? null : cat.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(
                  height: 44,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) =>
                  SizedBox(height: 44, child: Center(child: Text('Error: $e'))),
            ),
          ),

          // Titulo productos
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Productos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  products.whenOrNull(
                        data: (prods) => Text(
                          '${prods.length} disponibles',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ) ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // Grid de productos
          products.when(
            data: (prods) => prods.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No hay productos disponibles'),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = prods[index];
                          return _ProductCard(
                            product: product,
                            currencyFormat: currencyFormat,
                            isDark: isDark,
                            onTap: () =>
                                context.push('/product/${product.id}'),
                            onAddToCart: () {
                              final error = ref.read(cartProvider.notifier).addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error ?? '${product.name} agregado'),
                                  backgroundColor: error != null ? Colors.orange : null,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                        childCount: prods.length,
                      ),
                    ),
                  ),
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Shimmer.fromColors(
                    baseColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    highlightColor:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  childCount: 6,
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      const Text('Error al cargar productos'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(productsProvider),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40)),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final NumberFormat currencyFormat;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.currencyFormat,
    required this.isDark,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        highlightColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        child: Container(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  if (product.stock <= 5 && product.stock > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Quedan ${product.stock}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            currencyFormat.format(product.price),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Material(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: onAddToCart,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.add,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}