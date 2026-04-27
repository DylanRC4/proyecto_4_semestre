/// Configuración de rutas con GoRouter.
/// Protección de rutas por rol (cliente, trabajador, admin).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/core/constants/app_constants.dart';
import 'package:flash_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flash_app/features/auth/presentation/screens/register_screen.dart';
import 'package:flash_app/features/products/presentation/screens/home_screen.dart';
import 'package:flash_app/features/products/presentation/screens/product_detail_screen.dart';
import 'package:flash_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:flash_app/features/cart/presentation/screens/checkout_screen.dart';
import 'package:flash_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:flash_app/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:flash_app/features/orders/presentation/screens/admin_orders_screen.dart';
import 'package:flash_app/features/orders/presentation/screens/worker_orders_screen.dart';
import 'package:flash_app/features/orders/presentation/screens/worker_order_detail_screen.dart';
import 'package:flash_app/features/profile/presentation/screens/profile_screen.dart';

String _getUserRole(String? email) {
  if (email == null) return 'none';
  if (email == AppConstants.adminEmail) return 'admin';
  if (AppConstants.workerEmails.contains(email)) return 'worker';
  return 'client';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final email = Supabase.instance.client.auth.currentUser?.email;
      final role = _getUserRole(email);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      // No autenticado: solo login y register
      if (!isAuth && !isAuthRoute) return '/login';

      // Autenticado en login/register: redirigir a su home
      if (isAuth && isAuthRoute) {
        switch (role) {
          case 'admin': return '/admin/orders';
          case 'worker': return '/worker/orders';
          default: return '/home';
        }
      }

      // Proteger rutas de admin: solo admin puede acceder
      if (isAuth && location.startsWith('/admin') && role != 'admin') {
        return '/home';
      }

      // Proteger rutas de worker: solo worker y admin pueden acceder
      if (isAuth &&
          location.startsWith('/worker') &&
          role != 'worker' &&
          role != 'admin') {
        return '/home';
      }

      // Proteger rutas de cliente: worker y admin no van a /home
      if (isAuth && !isAuthRoute && !location.startsWith('/admin') && !location.startsWith('/worker')) {
        if (role == 'worker' && location == '/home') return '/worker/orders';
        if (role == 'admin' && location == '/home') return '/admin/orders';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Pagina no encontrada'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/worker/orders',
        builder: (context, state) => const WorkerOrdersScreen(),
      ),
      GoRoute(
        path: '/worker/order/:id',
        builder: (context, state) => WorkerOrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});