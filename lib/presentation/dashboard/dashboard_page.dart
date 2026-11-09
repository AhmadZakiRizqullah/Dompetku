import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/wallet_card.dart';
import '../widgets/transaction_item.dart';
import '../transaction/add_transaction_page.dart';
import '../wallet/wallet_list_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final monthlySummaryAsync = ref.watch(monthlySummaryProvider);
    final recentTxAsync = ref.watch(recentTransactionsProvider);
    final userName = ref.watch(userNameProvider);
    final isBalanceVisible = ref.watch(balanceVisibleProvider);
    final isWalletsVisible = ref.watch(walletsVisibleProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang 👋',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        GestureDetector(
                          onTap: () => _showEditNameDialog(context, ref, userName),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: AppColors.primary),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormatter.formatMonthYear(now),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Balance Card ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: totalBalanceAsync.when(
                  data: (total) => monthlySummaryAsync.when(
                    data: (summary) => TotalBalanceCard(
                      totalBalance: total,
                      totalIncome: summary['income'] ?? 0,
                      totalExpense: summary['expense'] ?? 0,
                      isBalanceVisible: isBalanceVisible,
                      onToggleVisibility: () =>
                          ref.read(balanceVisibleProvider.notifier).toggle(),
                    ),
                    loading: () => TotalBalanceCard(
                      totalBalance: total,
                      totalIncome: 0,
                      totalExpense: 0,
                      isBalanceVisible: isBalanceVisible,
                      onToggleVisibility: () =>
                          ref.read(balanceVisibleProvider.notifier).toggle(),
                    ),
                    error: (_, __) => TotalBalanceCard(
                      totalBalance: total,
                      totalIncome: 0,
                      totalExpense: 0,
                      isBalanceVisible: isBalanceVisible,
                      onToggleVisibility: () =>
                          ref.read(balanceVisibleProvider.notifier).toggle(),
                    ),
                  ),
                  loading: () => const _LoadingCard(height: 180),
                  error: (e, _) => const _ErrorCard(),
                ),
              ),
            ),

            // ── Wallets Section ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Wallet Saya',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            isWalletsVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: isWalletsVisible
                              ? 'Sembunyikan Wallet'
                              : 'Tampilkan Wallet',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => ref
                              .read(walletsVisibleProvider.notifier)
                              .toggle(),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WalletListPage()),
                      ),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: AnimatedCrossFade(
                firstChild: walletsAsync.when(
                  data: (walletList) => walletList.isEmpty
                      ? _EmptyWallets(
                          onAdd: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WalletListPage()),
                          ),
                        )
                      : SizedBox(
                          height: 140,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: walletList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) => WalletCard(
                              wallet: walletList[i],
                            ),
                          ),
                        ),
                  loading: () => const _LoadingCard(height: 130),
                  error: (e, _) => const _ErrorCard(),
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () =>
                        ref.read(walletsVisibleProvider.notifier).toggle(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility_off_outlined,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Wallet disembunyikan • Ketuk untuk tampilkan',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                crossFadeState: isWalletsVisible
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 250),
              ),
            ),

            // ── Recent Transactions ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'Transaksi Terakhir',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: recentTxAsync.when(
                data: (txList) => txList.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyTransactions(
                          onAdd: () => _openAddTransaction(context),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => TransactionItem(
                            data: txList[index],
                            onTap: () {},
                          ),
                          childCount: txList.length,
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: _LoadingCard(height: 200),
                ),
                error: (e, _) =>
                    const SliverToBoxAdapter(child: _ErrorCard()),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTransaction(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Transaksi'),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
  }

  void _showEditNameDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Nama'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama kamu',
            counterText: '',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(userNameProvider.notifier).setName(value);
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text;
              if (value.trim().isNotEmpty) {
                ref.read(userNameProvider.notifier).setName(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Terjadi kesalahan memuat data'),
      ),
    );
  }
}

class _EmptyWallets extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyWallets({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onAdd,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.secondary, size: 32),
              const SizedBox(height: 8),
              Text(
                'Tambah Wallet Pertama',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTransactions({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              color: AppColors.textSecondary, size: 60),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat pemasukan atau pengeluaran Anda',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Catat Transaksi'),
          ),
        ],
      ),
    );
  }
}
