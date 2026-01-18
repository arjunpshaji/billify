import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.app';

  /// Fetches the exchange rate from [base] to [target] for a specific [date].
  /// If the date is today, it uses 'latest'.
  Future<double?> getExchangeRate(
    String base,
    String target,
    DateTime date,
  ) async {
    if (base == target) return 1.0;

    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    // If date is today, Frankfurter might not have it yet, so check if it's really recent.
    // Ideally we assume 'latest' for today/future, and historical for past.
    if (date.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
      dateStr = 'latest';
    }

    final url = Uri.parse('$_baseUrl/$dateStr?from=$base&to=$target');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && data['rates'][target] != null) {
          return (data['rates'][target] as num).toDouble();
        }
      }
    } catch (e) {
      // debugPrint('Failed to load exchange rate: $e');
    }
    return null;
  }
}
