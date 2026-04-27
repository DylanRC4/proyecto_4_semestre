/// Pantalla de perfil: datos del usuario, tema y cerrar sesión.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flash_app/config/theme/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fullName =
        user?.userMetadata?['full_name'] as String? ?? 'Usuario Flash';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mi perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Mis pedidos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/orders'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: const Text('Mi carrito'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/cart'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Tema de la app'),
                  subtitle: Text(isDark ? 'Modo oscuro' : 'Modo claro'),
                  trailing: Switch(
                    value: isDark,
                    activeColor: colorScheme.primary,
                    onChanged: (_) =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.primary),
                  title: const Text('Acerca de Flash'),
                  subtitle: const Text('Version 1.0.0'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Cerrar sesion',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }
}