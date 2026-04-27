/// Pantalla de pago: Tarjeta, PSE, Nequi y pago en tienda.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flash_app/features/orders/presentation/providers/order_provider.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simular procesamiento de pago
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final cart = ref.read(cartProvider);
    final error = await ref.read(orderProvider.notifier).createOrder(cart);

    if (mounted) {
      if (error != null) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Theme.of(context).colorScheme.error),
        );
      } else {
        ref.read(cartProvider.notifier).clear();
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle, size: 64, color: colorScheme.primary),
        title: const Text('¡Pago exitoso!'),
        content: const Text(
          'Tu pedido ha sido recibido. Te notificaremos cuando esté listo para recoger.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/orders');
              },
              child: const Text('Ver mis pedidos'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('El carrito está vacío')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del pedido
            Text(
              'Resumen del pedido',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...cart.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
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
                          currencyFormat.format(cartNotifier.total),
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

            // Método de pago
            Text(
              'Método de pago',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              icon: Icons.credit_card,
              title: 'Tarjeta de crédito/débito',
              subtitle: 'Visa, Mastercard, Amex',
              value: 'card',
              selected: _selectedMethod,
              onTap: () => setState(() => _selectedMethod = 'card'),
            ),
            const SizedBox(height: 8),
            _PaymentMethodTile(
              icon: Icons.account_balance,
              title: 'PSE',
              subtitle: 'Débito bancario',
              value: 'pse',
              selected: _selectedMethod,
              onTap: () => setState(() => _selectedMethod = 'pse'),
            ),
            const SizedBox(height: 8),
            _PaymentMethodTile(
              icon: Icons.phone_android,
              title: 'Nequi',
              subtitle: 'Pago desde tu celular',
              value: 'nequi',
              selected: _selectedMethod,
              onTap: () => setState(() => _selectedMethod = 'nequi'),
            ),
            const SizedBox(height: 8),
            _PaymentMethodTile(
              icon: Icons.store,
              title: 'Pago en tienda',
              subtitle: 'Paga al recoger tu pedido',
              value: 'cash',
              selected: _selectedMethod,
              onTap: () => setState(() => _selectedMethod = 'cash'),
            ),
            const SizedBox(height: 20),

            // Formulario según método
            if (_selectedMethod == 'card') ...[
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: '1234 5678 9012 3456',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardNameController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Nombre en la tarjeta',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cardExpiryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'MM/AA',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cardCvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_selectedMethod == 'pse')
              Card(
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Serás redirigido a tu banco para completar el pago de forma segura.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_selectedMethod == 'nequi')
              Card(
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.phone_android, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Recibirás una notificación en tu app de Nequi para aprobar el pago.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_selectedMethod == 'cash')
              Card(
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.store, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pagarás directamente en la tienda cuando recojas tu pedido.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.flash_on),
                label: Text(
                  _isProcessing
                      ? 'Procesando pago...'
                      : 'Pagar ${currencyFormat.format(cartNotifier.total)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Pago seguro encriptado',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        )),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}