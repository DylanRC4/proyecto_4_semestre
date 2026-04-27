/// Punto de entrada principal de la aplicación Flash.
/// Inicializa Supabase, notificaciones y localización.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flash_app/config/router/app_router.dart';
import 'package:flash_app/config/theme/app_theme.dart';
import 'package:flash_app/config/theme/theme_provider.dart';
import 'package:flash_app/core/constants/app_constants.dart';
import 'package:flash_app/core/network/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await NotificationService.initialize();

  runApp(const ProviderScope(child: FlashApp()));
}

class FlashApp extends ConsumerWidget {
  const FlashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Flash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}