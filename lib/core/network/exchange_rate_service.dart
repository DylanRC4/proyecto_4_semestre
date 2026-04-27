/// Servicio de tasas de cambio COP/USD con caché de 1 hora.
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest/COP';
  double? _copToUsd;
  DateTime? _lastFetch;

  Future<double> getCopToUsd() async {
    if (_copToUsd != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inHours < 1) {
      return _copToUsd!;
    }

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _copToUsd = (data['rates']['USD'] as num).toDouble();
        _lastFetch = DateTime.now();
        return _copToUsd!;
      }
      throw Exception('Error al obtener tasa de cambio');
    } catch (e) {
      if (_copToUsd != null) return _copToUsd!;
      return 0.00023;
    }
  }
}