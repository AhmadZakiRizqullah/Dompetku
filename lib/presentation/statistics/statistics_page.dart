import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/transaction_provider.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final categoryDataAsync = ref.watch(expenseByCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            _MonthSelector(
              selectedMonth: selectedMonth,
              onChanged: (newMonth) {
                ref.read(selectedMonthProvider.notifier).state = newMonth;
              },
            ),
            const SizedBox(height: 24),

            // Summary cards
            summaryAsync.when(
              data: (summary) => _SummaryCards(
                income: summary['income'] ?? 0,
                expense: summary['expense'] ?? 0,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Gagal memuat ringkasan bulan ini',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(monthlySummaryProvider),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Pie chart
            Text('Pengeluaran per Kategori',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            categoryDataAsync.when(
              data: (data) => data.isEmpty
                  ? _EmptyChart()
                  : _ExpensePieChart(data: data),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.secondary,
                      ),
                      SizedBox(height: 12),
                      Text('Memuat grafik kategori...'),
                    ],
                  ),
                ),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Gagal memuat data kategori',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(expenseByCategoryProvider),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final void Function(DateTime) onChanged;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              final prev = DateTime(
                  selectedMonth.year, selectedMonth.month - 1, 1);
              onChanged(prev);
            },
          ),
          Text(
            DateFormatter.formatMonthYear(selectedMonth),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: selectedMonth.month == DateTime.now().month &&
                    selectedMonth.year == DateTime.now().year
                ? null
                : () {
                    final next = DateTime(
                        selectedMonth.year, selectedMonth.month + 1, 1);
                    onChanged(next);
                  },
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final double income;
  final double expense;

  const _SummaryCards({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    final netColor = net >= 0 ? AppColors.income : AppColors.expense;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        if (isCompact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Pemasukan',
                      amount: income,
                      color: AppColors.income,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Pengeluaran',
                      amount: expense,
                      color: AppColors.expense,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: netColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: netColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: netColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.balance_rounded,
                          color: netColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selisih (Net)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: netColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          net >= 0 ? 'Surplus Bulan Ini' : 'Defisit Bulan Ini',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${net < 0 ? '-' : '+'} ${CurrencyFormatter.format(net.abs())}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: netColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pemasukan',
                amount: income,
                color: AppColors.income,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Pengeluaran',
                amount: expense,
                color: AppColors.expense,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Selisih',
                amount: net,
                color: netColor,
                icon: Icons.balance_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(amount.abs()),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class _ExpensePieChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const _ExpensePieChart({required this.data});

  @override
  State<_ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<_ExpensePieChart> {
  int touchedIndex = -1;

  double get _totalExpense =>
      widget.data.fold(0, (sum, item) => sum + (item['total'] as double));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pie chart
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _buildSections(),
              centerSpaceRadius: 60,
              sectionsSpace: 3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Center total text overlay
        const SizedBox(height: 8),
        // Legend
        ...widget.data.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final pct = _totalExpense > 0
              ? (item['total'] as double) / _totalExpense * 100
              : 0;
          final color = AppColors.chartColors[i % AppColors.chartColors.length];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: touchedIndex == i
                  ? color.withOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: touchedIndex == i ? color : AppColors.border,
                width: touchedIndex == i ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['categoryName'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(item['total'] as double),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 13,
                            color: color,
                          ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.data.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final pct = _totalExpense > 0
          ? (item['total'] as double) / _totalExpense * 100
          : 0;
      final isTouched = i == touchedIndex;
      final color = AppColors.chartColors[i % AppColors.chartColors.length];

      return PieChartSectionData(
        value: item['total'] as double,
        color: color,
        radius: isTouched ? 75 : 60,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        showTitle: pct > 4,
      );
    }).toList();
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 48, color: AppColors.secondary),
            const SizedBox(height: 12),
            Text(
              'Belum ada data pengeluaran bulan ini',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
