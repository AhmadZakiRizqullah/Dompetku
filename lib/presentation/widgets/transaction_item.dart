import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/daos/transaction_dao.dart';
import 'wallet_icon_widget.dart';

/// A single transaction item card in the history list
class TransactionItem extends StatelessWidget {
  final TransactionWithDetails data;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.data,
    this.onTap,
  });

  Color get _amountColor {
    switch (data.transaction.type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
      default:
        return AppColors.textPrimary;
    }
  }

  String get _amountText {
    final amount = data.transaction.amount;
    switch (data.transaction.type) {
      case TransactionType.income:
        return '+ ${CurrencyFormatter.format(amount)}';
      case TransactionType.expense:
        return '- ${CurrencyFormatter.format(amount)}';
      case TransactionType.transfer:
        return CurrencyFormatter.format(amount);
      default:
        return CurrencyFormatter.format(amount);
    }
  }

  IconData get _typeIcon {
    switch (data.transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
      default:
        return Icons.circle;
    }
  }

  String get _subtitle {
    if (data.transaction.type == TransactionType.transfer) {
      final toWalletName = data.toWallet?.name ?? '?';
      return '${data.wallet.name} → $toWalletName';
    }
    return data.wallet.name;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // Icon
            _buildLeadingIcon(),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.category?.name ??
                        TransactionType.label(data.transaction.type),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (data.transaction.note != null &&
                      data.transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.transaction.note!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount & date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _amountText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        color: _amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatTime(data.transaction.transactionDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    if (data.category != null) {
      return CategoryIconWidget(
        iconName: data.category!.iconName,
        categoryType: data.category!.type,
        size: 42,
      );
    }
    // Transfer or fallback
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _amountColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_typeIcon, color: _amountColor, size: 20),
    );
  }
}
