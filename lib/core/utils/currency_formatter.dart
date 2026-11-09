import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format double/int to Indonesian Rupiah string.
  /// Example: 1500000 → "Rp 1.500.000"
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format with sign prefix (+ or -) for transaction display.
  static String formatWithSign(double amount, {bool isExpense = false}) {
    final formatted = format(amount.abs());
    return isExpense ? '- $formatted' : '+ $formatted';
  }

  /// Parse a Rupiah string back to double.
  /// Example: "Rp 1.500.000" → 1500000.0
  static double parse(String value) {
    final cleaned = value
        .replaceAll('Rp ', '')
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }

  /// Format compact (e.g., 1.5 Jt, 100 Rb)
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return format(amount);
  }
}
