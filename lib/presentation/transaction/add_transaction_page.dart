import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/local/database.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../widgets/wallet_icon_widget.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final Transaction? editTransaction;

  const AddTransactionPage({super.key, this.editTransaction});

  @override
  ConsumerState<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form state
  late TextEditingController _amountCtrl;
  late TextEditingController _adminFeeCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _selectedDate;

  String _selectedType = TransactionType.expense;
  int? _selectedWalletId;
  int? _selectedToWalletId;
  int? _selectedCategoryId;

  bool get _isEdit => widget.editTransaction != null;

  @override
  void initState() {
    super.initState();

    final tx = widget.editTransaction;
    _selectedType = tx?.type ?? TransactionType.expense;
    _selectedDate = tx?.transactionDate ?? DateTime.now();
    _amountCtrl = TextEditingController(
        text: tx != null ? tx.amount.toStringAsFixed(0) : '');
    _adminFeeCtrl = TextEditingController(
        text: tx != null ? tx.adminFee.toStringAsFixed(0) : '0');
    _noteCtrl = TextEditingController(text: tx?.note ?? '');
    _selectedWalletId = tx?.walletId;
    _selectedToWalletId = tx?.toWalletId;
    _selectedCategoryId = tx?.categoryId;

    final tabIndex = _typeToTabIndex(_selectedType);
    _tabController = TabController(length: 3, vsync: this, initialIndex: tabIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedType = _tabIndexToType(_tabController.index);
          // Reset category when switching
          if (_selectedType == TransactionType.transfer) {
            _selectedCategoryId = null;
          }
        });
      }
    });
  }

  int _typeToTabIndex(String type) {
    switch (type) {
      case TransactionType.expense:
        return 0;
      case TransactionType.income:
        return 1;
      case TransactionType.transfer:
        return 2;
      default:
        return 0;
    }
  }

  String _tabIndexToType(int index) {
    switch (index) {
      case 0:
        return TransactionType.expense;
      case 1:
        return TransactionType.income;
      case 2:
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountCtrl.dispose();
    _adminFeeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _activeColor {
    switch (_selectedType) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
            Tab(text: 'Transfer'),
          ],
          indicatorColor: AppColors.accent,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount field
              _buildAmountField(),
              const SizedBox(height: 16),

              // Wallet selector
              walletsAsync.when(
                data: (wallets) => _buildWalletSelector(wallets),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // To-wallet (only for transfer)
              if (_selectedType == TransactionType.transfer) ...[
                walletsAsync.when(
                  data: (wallets) => _buildToWalletSelector(wallets),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                _buildAdminFeeField(),
                const SizedBox(height: 16),
              ],

              // Category (not for transfer)
              if (_selectedType != TransactionType.transfer) ...[
                _buildCategorySelector(),
                const SizedBox(height: 16),
              ],

              // Date picker
              _buildDateSelector(context),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  hintText: 'Tambahkan catatan...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeColor,
                  ),
                  child: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Transaksi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nominal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                )),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
                color: _activeColor,
              ),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            hintText: '0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: _activeColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _activeColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: _activeColor.withOpacity(0.3)),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Masukkan nominal';
            final parsed = double.tryParse(v.replaceAll('.', ''));
            if (parsed == null || parsed <= 0) return 'Nominal harus > 0';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWalletSelector(List<Wallet> wallets) {
    final label = _selectedType == TransactionType.transfer
        ? 'Wallet Sumber'
        : 'Wallet';
    return DropdownButtonFormField<int>(
      initialValue: _selectedWalletId,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
      ),
      items: wallets
          .map(
            (w) => DropdownMenuItem<int>(
              value: w.id,
              child: Row(
                children: [
                  WalletIconWidget(iconName: w.iconName, size: 24),
                  const SizedBox(width: 8),
                  Expanded(child: Text(w.name)),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.formatCompact(w.currentBalance),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedWalletId = v),
      validator: (v) => v == null ? 'Pilih wallet' : null,
    );
  }

  Widget _buildToWalletSelector(List<Wallet> wallets) {
    final available =
        wallets.where((w) => w.id != _selectedWalletId).toList();
    return DropdownButtonFormField<int>(
      initialValue: _selectedToWalletId,
      decoration: const InputDecoration(
        labelText: 'Wallet Tujuan',
        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
      ),
      items: available
          .map(
            (w) => DropdownMenuItem<int>(
              value: w.id,
              child: Row(
                children: [
                  WalletIconWidget(iconName: w.iconName, size: 24),
                  const SizedBox(width: 8),
                  Text(w.name),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedToWalletId = v),
      validator: (v) {
        if (_selectedType == TransactionType.transfer && v == null) {
          return 'Pilih wallet tujuan';
        }
        return null;
      },
    );
  }

  Widget _buildAdminFeeField() {
    return TextFormField(
      controller: _adminFeeCtrl,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Biaya Admin (opsional)',
        prefixText: 'Rp ',
        hintText: '0',
        prefixIcon: Icon(Icons.price_change_outlined),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final type = _selectedType == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;
    final categoriesAsync = type == CategoryType.income
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) => DropdownButtonFormField<int>(
        initialValue: _selectedCategoryId,
        decoration: const InputDecoration(
          labelText: 'Kategori',
          prefixIcon: Icon(Icons.category_rounded),
        ),
        items: categories
            .map(
              (c) => DropdownMenuItem<int>(
                value: c.id,
                child: Row(
                  children: [
                    CategoryIconWidget(
                        iconName: c.iconName, categoryType: c.type, size: 24),
                    const SizedBox(width: 8),
                    Text(c.name),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _selectedCategoryId = v),
        validator: (v) =>
            v == null ? 'Pilih kategori' : null,
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          if (!context.mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_selectedDate),
          );
          if (time != null) {
            setState(() {
              _selectedDate = DateTime(
                picked.year,
                picked.month,
                picked.day,
                time.hour,
                time.minute,
              );
            });
          } else {
            setState(() {
              _selectedDate = picked;
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, d MMMM yyyy  •  HH:mm', 'id_ID')
                  .format(_selectedDate),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.tryParse(_amountCtrl.text.replaceAll('.', '')) ?? 0;
    final adminFee =
        double.tryParse(_adminFeeCtrl.text.replaceAll('.', '')) ?? 0;

    final notifier = ref.read(transactionNotifierProvider.notifier);

    try {
      if (_isEdit) {
        await notifier.editTransaction(
          widget.editTransaction!,
          amount: amount,
          type: _selectedType,
          walletId: _selectedWalletId!,
          transactionDate: _selectedDate,
          adminFee: adminFee,
          toWalletId: _selectedToWalletId,
          categoryId: _selectedCategoryId,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
        );
      } else {
        await notifier.addTransaction(
          amount: amount,
          type: _selectedType,
          walletId: _selectedWalletId!,
          transactionDate: _selectedDate,
          adminFee: adminFee,
          toWalletId: _selectedToWalletId,
          categoryId: _selectedCategoryId,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Transaksi berhasil diperbarui'
                : 'Transaksi berhasil disimpan'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }
}
