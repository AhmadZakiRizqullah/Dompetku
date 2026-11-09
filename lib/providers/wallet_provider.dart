import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import 'database_provider.dart';

// ─── Streams ───────────────────────────────────────────────────────────────

/// Stream of all wallets
final walletsProvider = StreamProvider<List<Wallet>>((ref) {
  return ref.watch(databaseProvider).walletDao.watchAllWallets();
});

/// Stream of total balance
final totalBalanceProvider = StreamProvider<double>((ref) {
  return ref.watch(databaseProvider).walletDao.watchTotalBalance();
});

// ─── Wallet Form State ─────────────────────────────────────────────────────

class WalletNotifier extends AsyncNotifier<void> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  Future<void> build() async {}

  Future<void> addWallet({
    required String name,
    required String type,
    required double initialBalance,
    required String iconName,
  }) async {
    await _db.walletDao.insertWallet(
      WalletsCompanion.insert(
        name: name,
        type: type,
        initialBalance: Value(initialBalance),
        currentBalance: Value(initialBalance),
        iconName: Value(iconName),
      ),
    );
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _db.walletDao.updateWallet(wallet.toCompanion(true));
  }

  Future<void> adjustBalance(Wallet wallet, double newBalance) async {
    await _db.walletDao.updateBalance(wallet.id, newBalance);
  }

  Future<void> deleteWallet(int walletId) async {
    await _db.walletDao.deleteWallet(walletId);
  }
}

final walletNotifierProvider =
    AsyncNotifierProvider<WalletNotifier, void>(WalletNotifier.new);
