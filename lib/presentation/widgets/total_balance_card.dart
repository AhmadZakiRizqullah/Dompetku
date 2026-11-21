import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';

/// Hero card displaying total balance on the dashboard
class TotalBalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;

  const TotalBalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
  });

  String _maskedAmount(String formatted) {
    // Replace digits with bullet characters
    return formatted.replaceAll(RegExp(r'[0-9]'), '•');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Total Kekayaan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.background.withOpacity(0.75),
                          fontSize: 13,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onToggleVisibility,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isBalanceVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        key: ValueKey(isBalanceVisible),
                        color: AppColors.background.withOpacity(0.6),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  isBalanceVisible
                      ? CurrencyFormatter.format(totalBalance)
                      : _maskedAmount(CurrencyFormatter.format(totalBalance)),
                  key: ValueKey('balance_$isBalanceVisible'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.background,
                        fontSize: 30,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: 'Pemasukan',
                      amount: totalIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.secondary,
                      isVisible: isBalanceVisible,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.background.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _SummaryItem(
                      label: 'Pengeluaran',
                      amount: totalExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.accent,
                      alignRight: true,
                      isVisible: isBalanceVisible,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool alignRight;
  final bool isVisible;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.alignRight = false,
    this.isVisible = true,
  });

  String _maskedCompact(String formatted) {
    return formatted.replaceAll(RegExp(r'[0-9]'), '•');
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = CurrencyFormatter.formatCompact(amount);
    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 16 : 0,
        right: alignRight ? 0 : 16,
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: alignRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.background.withOpacity(0.75),
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isVisible ? formattedAmount : _maskedCompact(formattedAmount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.background,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
