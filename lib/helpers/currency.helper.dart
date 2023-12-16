import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(
    double amount, {
    String? symbol = "₹",
    String? name = "INR",
    String? locale = "en_IN",
  }) {
    return NumberFormat('###,###,###.####', locale).format(amount);
  }

  static String formatCompact(
    double amount, {
    String? symbol = "RM",
    String? name = "MYR",
    String? locale = "en_IN",
  }) {
    return NumberFormat.compact(locale: locale).format(amount) + (symbol ?? "");
  }
}
