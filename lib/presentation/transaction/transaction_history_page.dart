import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/local/daos/transaction_dao.dart';
import '../../providers/transaction_provider.dart';
import '../widgets/transaction_item.dart';
import '../widgets/transaction_detail_sheet.dart';
import 'add_transaction_page.dart';

class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState
    extends ConsumerState<TransactionHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: filter.hasFilter ? AppColors.accent : AppColors.primary,
            ),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filter chips
          if (filter.hasFilter)
            _FilterChipsBar(
              filter: filter,
              onClear: () => ref
                  .read(transactionFilterProvider.notifier)
                  .state = const TransactionFilter(),
            ),

          // Transaction list grouped by date
          Expanded(
            child: txAsync.when(
              data: (txList) => txList.isEmpty
                  ? _EmptyState(onAdd: () => _openAddTransaction(context))
                  : _GroupedTransactionList(txList: txList),
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat riwayat transaksi...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: AppColors.accent),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat riwayat transaksi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Silakan coba muat ulang data transaksi Anda.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(filteredTransactionsProvider),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(ref: ref),
    );
  }
}

class _FilterChipsBar extends StatelessWidget {
  final TransactionFilter filter;
  final VoidCallback onClear;

  const _FilterChipsBar({required this.filter, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: AppColors.background,
      child: Row(
        children: [
          const Icon(Icons.filter_alt_rounded,
              color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _filterLabel(filter),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.accent,
                  ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded,
                color: AppColors.accent, size: 18),
          ),
        ],
      ),
    );
  }

  String _filterLabel(TransactionFilter f) {
    final parts = <String>[];
    if (f.startDate != null && f.endDate != null) {
      parts.add(
          '${DateFormatter.formatShort(f.startDate!)} - ${DateFormatter.formatShort(f.endDate!)}');
    }
    return parts.join(' • ');
  }
}

class _GroupedTransactionList extends StatelessWidget {
  final List<TransactionWithDetails> txList;

  const _GroupedTransactionList({required this.txList});

  @override
  Widget build(BuildContext context) {
    // Group by date
    final Map<String, List<TransactionWithDetails>> grouped = {};
    for (final tx in txList) {
      final key = DateFormatter.formatRelative(tx.transaction.transactionDate);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final dateLabel = keys[i];
        final dayTxList = grouped[dateLabel]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dateLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
              ),
            ),
            ...dayTxList.map(
              (tx) => TransactionItem(
                data: tx,
                onTap: () => _showTxDetail(context, tx),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTxDetail(BuildContext context, TransactionWithDetails tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionDetailSheet(data: tx),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final WidgetRef ref;

  const _FilterSheet({required this.ref});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filter Transaksi',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),

          // Quick date filters
          Text('Rentang Cepat',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _quickChip('Hari Ini', () {
                final now = DateTime.now();
                setState(() {
                  _startDate = DateTime(now.year, now.month, now.day);
                  _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                });
              }),
              _quickChip('Bulan Ini', () {
                final now = DateTime.now();
                setState(() {
                  _startDate = DateTime(now.year, now.month, 1);
                  _endDate =
                      DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                });
              }),
              _quickChip('Tahun Ini', () {
                final now = DateTime.now();
                setState(() {
                  _startDate = DateTime(now.year, 1, 1);
                  _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
                });
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Custom date range
          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: 'Dari Tanggal',
                  date: _startDate,
                  onPick: (d) => setState(() => _startDate = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DatePickerField(
                  label: 'Sampai Tanggal',
                  date: _endDate,
                  onPick: (d) => setState(() {
                    _endDate =
                        DateTime(d.year, d.month, d.day, 23, 59, 59);
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.ref.read(transactionFilterProvider.notifier).state =
                        const TransactionFilter();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.ref.read(transactionFilterProvider.notifier).state =
                        TransactionFilter(
                      startDate: _startDate,
                      endDate: _endDate,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      side: BorderSide.none,
      labelStyle: const TextStyle(
          color: AppColors.primary, fontWeight: FontWeight.w500),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final void Function(DateTime) onPick;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormatter.formatShort(date!) : 'Pilih...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        date != null ? FontWeight.w600 : FontWeight.w400,
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72, color: AppColors.secondary),
          const SizedBox(height: 16),
          Text('Tidak ada transaksi',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Coba ubah filter atau tambah transaksi baru'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Transaksi'),
          ),
        ],
      ),
    );
  }
}
