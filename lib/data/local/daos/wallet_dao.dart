import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/wallets_table.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  // --- READ ---

  /// Stream of all wallets, ordered by creation date
  Stream<List<Wallet>> watchAllWallets() {
    return (select(wallets)..orderBy([(w) => OrderingTerm.asc(w.createdAt)]))
        .watch();
  }

  /// Future of all wallets
  Future<List<Wallet>> getAllWallets() {
    return (select(wallets)..orderBy([(w) => OrderingTerm.asc(w.createdAt)]))
        .get();
  }

  /// Get a single wallet by ID
  Future<Wallet?> getWalletById(int id) {
    return (select(wallets)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  /// Stream of total balance across all wallets
  Stream<double> watchTotalBalance() {
    final query = selectOnly(wallets)
      ..addColumns([wallets.currentBalance.sum()]);
    return query
        .watchSingle()
        .map((row) => row.read(wallets.currentBalance.sum()) ?? 0.0);
  }

  // --- CREATE ---

  /// Insert a new wallet, return new wallet's ID
  Future<int> insertWallet(WalletsCompanion wallet) {
    return into(wallets).insert(wallet);
  }

  // --- UPDATE ---

  /// Update an existing wallet
  Future<bool> updateWallet(WalletsCompanion wallet) {
    return update(wallets).replace(wallet);
  }

  /// Update only the current balance of a wallet
  Future<void> updateBalance(int walletId, double newBalance) async {
    await (update(wallets)..where((w) => w.id.equals(walletId))).write(
      WalletsCompanion(currentBalance: Value(newBalance)),
    );
  }

  /// Adjust balance by a delta (positive or negative)
  Future<void> adjustBalance(int walletId, double delta) async {
    final wallet = await getWalletById(walletId);
    if (wallet != null) {
      await updateBalance(walletId, wallet.currentBalance + delta);
    }
  }

  // --- DELETE ---

  /// Delete a wallet by ID
  Future<int> deleteWallet(int walletId) {
    return (delete(wallets)..where((w) => w.id.equals(walletId))).go();
  }
}
