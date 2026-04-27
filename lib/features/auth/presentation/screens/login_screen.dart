/// Pantalla de login con selector de 3 roles y animación fade-in.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flash_app/core/constants/app_constants.dart';
import 'package:flash_app/config/theme/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _logo =
      'https://sdsstyqhgirubafmvfnk.supabase.co/storage/v1/object/public/products/logo-marca/logomodoclaro.png';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _selectedRole = 'client';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    if (_selectedRole == 'admin' && email != AppConstants.adminEmail) {
      _showError('Este correo no tiene permisos de administrador');
      return;
    }

    if (_selectedRole == 'worker' &&
        !AppConstants.workerEmails.contains(email)) {
      _showError('Este correo no tiene permisos de trabajador');
      return;
    }

    if (_selectedRole == 'client' &&
        (email == AppConstants.adminEmail ||
            AppConstants.workerEmails.contains(email))) {
      _showError(
          'Esta cuenta tiene un rol asignado. Usa el acceso correspondiente.');
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final error = await authNotifier.signIn(
      email: email,
      password: _passwordController.text,
    );

    if (mounted) {
      if (error != null) {
        _showError(error);
      } else {
        switch (_selectedRole) {
          case 'admin':
            context.go('/admin/orders');
            break;
          case 'worker':
            context.go('/worker/orders');
            break;
          default:
            context.go('/home');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _showResetPasswordDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_reset, size: 48, color: Color(0xFFFF1744)),
        title: const Text('Recuperar contrasena'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo y te enviaremos un enlace para restablecer tu contrasena.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electronico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              resetController.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isEmpty || !email.contains('@')) return;
              try {
                await Supabase.instance.client.auth
                    .resetPasswordForEmail(email);
                resetController.dispose();
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Enlace enviado. Revisa tu correo.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CachedNetworkImage(
                          imageUrl: _logo,
                          height: 85,
                          width: 85,
                          errorWidget: (c, u, e) => const Icon(
                            Icons.flash_on_rounded,
                            size: 70,
                            color: Color(0xFFFF1744),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'FLASH',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 34,
                            color: Color(0xFFFF1744),
                            letterSpacing: 3,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TU MERCADO EXPRESS',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFFBDBDBD)
                                : Colors.grey.shade600,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              _RoleTab(
                                icon: Icons.shopping_bag_outlined,
                                label: 'Cliente',
                                isSelected: _selectedRole == 'client',
                                onTap: () =>
                                    setState(() => _selectedRole = 'client'),
                                isDark: isDark,
                              ),
                              _RoleTab(
                                icon: Icons.work_outline,
                                label: 'Trabajador',
                                isSelected: _selectedRole == 'worker',
                                onTap: () =>
                                    setState(() => _selectedRole = 'worker'),
                                isDark: isDark,
                              ),
                              _RoleTab(
                                icon: Icons.admin_panel_settings_outlined,
                                label: 'Admin',
                                isSelected: _selectedRole == 'admin',
                                onTap: () =>
                                    setState(() => _selectedRole = 'admin'),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_selectedRole != 'client')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF1744)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFF1744)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock,
                                      size: 16, color: Color(0xFFFF1744)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedRole == 'admin'
                                          ? 'Acceso restringido para administradores.'
                                          : 'Acceso restringido para trabajadores.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFF1744),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: _selectedRole == 'client'
                                ? 'Correo electronico'
                                : 'Correo corporativo',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Ingresa un correo valido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contrasena',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contrasena';
                            }
                            if (value.length < 6) {
                              return 'Minimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        if (_selectedRole == 'client')
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showResetPasswordDialog,
                              child: const Text(
                                'Olvidaste tu contrasena?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF1744),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _login,
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _selectedRole == 'client'
                                        ? 'Iniciar sesion'
                                        : _selectedRole == 'worker'
                                            ? 'Acceder como trabajador'
                                            : 'Acceder al panel',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        if (_selectedRole == 'client') ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.push('/register'),
                              child: const Text('Crear cuenta nueva'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color:
                      isDark ? const Color(0xFFBDBDBD) : Colors.grey.shade600,
                ),
                onPressed: () =>
                    ref.read(themeProvider.notifier).toggleTheme(),
                tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _RoleTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF1744) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}