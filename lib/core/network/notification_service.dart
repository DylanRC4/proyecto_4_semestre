/// Servicio de notificaciones push usando Web Notifications API.
import 'package:web/web.dart' as web;

class NotificationService {
  static Future<void> initialize() async {
    try {
      web.Notification.requestPermission();
    } catch (_) {}
  }

  static void showNotification({
    required String title,
    required String body,
  }) {
    try {
      if (web.Notification.permission == 'granted') {
        web.Notification(
          title,
          web.NotificationOptions(body: body),
        );
      }
    } catch (_) {}
  }

  static void orderStatusNotification(String orderId, String status) {
    final messages = {
      'pending': 'Tu pedido ha sido recibido. Lo estamos procesando.',
      'confirmed': '¡Tu pedido ha sido confirmado!',
      'preparing': 'Estamos preparando tu pedido. ¡Ya casi!',
      'ready': '¡Tu pedido está listo! Ven a recogerlo a la tienda.',
      'picked_up': 'Pedido entregado. ¡Gracias por comprar en Flash!',
    };

    showNotification(
      title: 'Flash - Pedido #${orderId.substring(0, 8)}',
      body: messages[status] ?? 'Tu pedido ha sido actualizado.',
    );
  }
}