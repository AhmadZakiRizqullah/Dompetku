import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku_tracker/core/utils/currency_formatter.dart';
import 'package:dompetku_tracker/core/constants/app_constants.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats positive amounts correctly in Rupiah', () {
      expect(CurrencyFormatter.format(50000), contains('50.000'));
      expect(CurrencyFormatter.format(1500000), contains('1.500.000'));
    });

    test('formats with sign for income and expense', () {
      expect(CurrencyFormatter.formatWithSign(25000, isExpense: true), startsWith('-'));
      expect(CurrencyFormatter.formatWithSign(50000, isExpense: false), startsWith('+'));
    });

    test('parses Rupiah string to double correctly', () {
      expect(CurrencyFormatter.parse('Rp 1.500.000'), 1500000.0);
      expect(CurrencyFormatter.parse('50.000'), 50000.0);
    });

    test('compact format works as expected', () {
      expect(CurrencyFormatter.formatCompact(1500000), contains('Jt'));
      expect(CurrencyFormatter.formatCompact(50000), contains('Rb'));
    });
  });

  group('AppConstants Tests', () {
    test('transaction types are correct', () {
      expect(TransactionType.expense, 'EXPENSE');
      expect(TransactionType.income, 'INCOME');
      expect(TransactionType.transfer, 'TRANSFER');
    });

    test('wallet types are correct', () {
      expect(WalletType.bank, 'BANK');
      expect(WalletType.eWallet, 'EWALLET');
      expect(WalletType.cash, 'CASH');
    });
  });
}
