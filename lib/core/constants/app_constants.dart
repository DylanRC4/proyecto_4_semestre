/// Constantes globales. Importa credenciales desde env.dart (no versionado).
import 'package:flash_app/core/constants/env.dart';

class AppConstants {
  static const String appName = 'Flash';
  static const String supabaseUrl = Env.supabaseUrl;
  static const String supabaseAnonKey = Env.supabaseAnonKey;
  static const String adminEmail = Env.adminEmail;
  static const List<String> workerEmails = Env.workerEmails;
  static const String exchangeRateApiUrl =
      'https://open.er-api.com/v6/latest/COP';

  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'picked_up',
  ];
}