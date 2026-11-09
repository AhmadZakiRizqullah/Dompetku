// Transaction types
class TransactionType {
  static const String income = 'INCOME';
  static const String expense = 'EXPENSE';
  static const String transfer = 'TRANSFER';

  static String label(String type) {
    switch (type) {
      case income:
        return 'Pemasukan';
      case expense:
        return 'Pengeluaran';
      case transfer:
        return 'Transfer';
      default:
        return type;
    }
  }
}

// Wallet types
class WalletType {
  static const String bank = 'BANK';
  static const String eWallet = 'EWALLET';
  static const String cash = 'CASH';

  static String label(String type) {
    switch (type) {
      case bank:
        return 'Bank';
      case eWallet:
        return 'E-Wallet';
      case cash:
        return 'Tunai';
      default:
        return type;
    }
  }
}

// Category types
class CategoryType {
  static const String income = 'INCOME';
  static const String expense = 'EXPENSE';
}

// Default category data for seeding
class DefaultCategories {
  static const List<Map<String, String>> income = [
    {'name': 'Gaji', 'icon': 'salary'},
    {'name': 'Bonus', 'icon': 'bonus'},
    {'name': 'Investasi', 'icon': 'investment'},
    {'name': 'Freelance', 'icon': 'freelance'},
    {'name': 'Hadiah', 'icon': 'gift'},
    {'name': 'Lainnya', 'icon': 'other'},
  ];

  static const List<Map<String, String>> expense = [
    {'name': 'Makanan & Minuman', 'icon': 'food'},
    {'name': 'Transportasi', 'icon': 'transport'},
    {'name': 'Belanja', 'icon': 'shopping'},
    {'name': 'Tagihan', 'icon': 'bill'},
    {'name': 'Kesehatan', 'icon': 'health'},
    {'name': 'Hiburan', 'icon': 'entertainment'},
    {'name': 'Pendidikan', 'icon': 'education'},
    {'name': 'Rumah', 'icon': 'home'},
    {'name': 'Komunikasi', 'icon': 'communication'},
    {'name': 'Lainnya', 'icon': 'other'},
  ];
}

// Default wallet data for onboarding
class DefaultWallets {
  static const List<Map<String, String>> wallets = [
    {'name': 'Uang Tunai', 'type': WalletType.cash, 'icon': 'cash'},
  ];
}

// App constants
class AppConstants {
  static const String appName = 'Dompetku';
  static const int recentTransactionsLimit = 10;
  static const String excelTemplateFileName = 'template_import_dompetku.xlsx';
  static const String excelExportFileName = 'laporan_transaksi_dompetku.xlsx';
  static const String pdfExportFileName = 'laporan_keuangan_dompetku.pdf';
}
