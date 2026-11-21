import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/local/daos/transaction_dao.dart';
import '../../providers/transaction_provider.dart';
import '../transaction/add_transaction_page.dart';

/// Reusable modal sheet displaying transaction details with edit and delete capabilities
class TransactionDetailSheet extends ConsumerWidget {
  final TransactionWithDetails data;

  const TransactionDetailSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = data.transaction;

    return Container(
      padding: const EdgeInsets.all(24),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Detail Transaksi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          _DetailRow(
            label: 'Jenis',
            value: _typeLabel(tx.type),
          ),
          _DetailRow(
            label: 'Nominal',
            value: 'Rp ${tx.amount.toStringAsFixed(0)}',
          ),
          if (tx.adminFee > 0)
            _DetailRow(
              label: 'Biaya Admin',
              value: 'Rp ${tx.adminFee.toStringAsFixed(0)}',
            ),
          _DetailRow(label: 'Wallet', value: data.wallet.name),
          if (data.toWallet != null)
            _DetailRow(label: 'Tujuan', value: data.toWallet!.name),
          if (data.category != null)
            _DetailRow(label: 'Kategori', value: data.category!.name),
          _DetailRow(
            label: 'Tanggal',
            value: DateFormatter.formatFullDateTime(tx.transactionDate),
          ),
          if (tx.note != null && tx.note!.isNotEmpty)
            _DetailRow(label: 'Catatan', value: tx.note!),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTransactionPage(
                          editTransaction: data.transaction,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(transactionNotifierProvider.notifier)
                        .deleteTransaction(data.transaction);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'INCOME':
        return 'Pemasukan';
      case 'EXPENSE':
        return 'Pengeluaran';
      case 'TRANSFER':
        return 'Transfer';
      default:
        return type;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
