/// Proveedor Riverpod para el servicio de tasas de cambio.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_app/core/network/exchange_rate_service.dart';

final exchangeRateServiceProvider = Provider((ref) => ExchangeRateService());

final copToUsdProvider = FutureProvider<double>((ref) async {
  final service = ref.read(exchangeRateServiceProvider);
  return await service.getCopToUsd();
});