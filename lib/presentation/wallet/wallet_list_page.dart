import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/database.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/wallet_icon_widget.dart';
import '../../core/utils/currency_formatter.dart';

class WalletListPage extends ConsumerWidget {
  const WalletListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Wallet',
            onPressed: () => _showAddEditWalletSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Total balance header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: totalBalanceAsync.when(
              data: (total) => _TotalCard(total: total),
              loading: () => const SizedBox(height: 80),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Semua Wallet',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Wallet list
          Expanded(
            child: walletsAsync.when(
              data: (walletList) => walletList.isEmpty
                  ? _EmptyState(
                      onAdd: () => _showAddEditWalletSheet(context, ref))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: walletList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _WalletListItem(
                        wallet: walletList[i],
                        onEdit: () =>
                            _showAddEditWalletSheet(context, ref, wallet: walletList[i]),
                        onDelete: () =>
                            _confirmDelete(context, ref, walletList[i]),
                        onAdjust: () =>
                            _showAdjustBalanceSheet(context, ref, walletList[i]),
                      ),
                    ),
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat daftar wallet...',
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
                        'Gagal memuat wallet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Silakan periksa kembali atau muat ulang.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(walletsProvider),
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
        onPressed: () => _showAddEditWalletSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddEditWalletSheet(BuildContext context, WidgetRef ref,
      {Wallet? wallet}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditWalletSheet(wallet: wallet, ref: ref),
    );
  }

  void _showAdjustBalanceSheet(
      BuildContext context, WidgetRef ref, Wallet wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdjustBalanceSheet(wallet: wallet, ref: ref),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Wallet wallet) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Wallet'),
        content: Text('Hapus wallet "${wallet.name}"? Data transaksi terkait tidak akan ikut terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(walletNotifierProvider.notifier)
                  .deleteWallet(wallet.id);
            },
            child: Text('Hapus',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Saldo',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
              Text(
                CurrencyFormatter.format(total),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletListItem extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAdjust;

  const _WalletListItem({
    required this.wallet,
    required this.onEdit,
    required this.onDelete,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          WalletIconWidget(iconName: wallet.iconName, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.name,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  WalletType.label(wallet.type),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(wallet.currentBalance),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionBtn(
                    icon: Icons.tune_rounded,
                    tooltip: 'Sesuaikan Saldo',
                    onTap: onAdjust,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  _ActionBtn(
                    icon: Icons.edit_rounded,
                    tooltip: 'Edit',
                    onTap: onEdit,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  _ActionBtn(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Hapus',
                    onTap: onDelete,
                    color: AppColors.accent,
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

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
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
          Icon(Icons.account_balance_wallet_outlined,
              size: 72, color: AppColors.secondary),
          const SizedBox(height: 16),
          Text('Belum ada wallet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Tambahkan wallet pertama Anda'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Wallet'),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Sheets ─────────────────────────────────────────────────────────

class AddEditWalletSheet extends StatefulWidget {
  final Wallet? wallet;
  final WidgetRef ref;

  const AddEditWalletSheet({super.key, this.wallet, required this.ref});

  @override
  State<AddEditWalletSheet> createState() => _AddEditWalletSheetState();
}

class _AddEditWalletSheetState extends State<AddEditWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _balanceCtrl;
  String _selectedType = WalletType.cash;
  String _selectedIcon = 'wallet';

  final _walletTypes = [
    (value: WalletType.bank, label: 'Bank'),
    (value: WalletType.eWallet, label: 'E-Wallet'),
    (value: WalletType.cash, label: 'Tunai'),
  ];

  final _iconOptions = [
    'wallet', 'cash', 'bank', 'bca', 'mandiri', 'bni', 'bri',
    'gopay', 'ovo', 'shopeepay', 'dana',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceCtrl = TextEditingController(
      text: widget.wallet != null
          ? widget.wallet!.currentBalance.toStringAsFixed(0)
          : '',
    );
    if (widget.wallet != null) {
      _selectedType = widget.wallet!.type;
      _selectedIcon = widget.wallet!.iconName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.wallet != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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
              isEdit ? 'Edit Wallet' : 'Tambah Wallet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Name input
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Wallet',
                hintText: 'Contoh: BCA, GoPay, Tunai',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // Balance input
            TextFormField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isEdit ? 'Saldo Saat Ini' : 'Saldo Awal',
                hintText: '0',
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Masukkan nominal saldo';
                if (double.tryParse(v.replaceAll('.', '')) == null) {
                  return 'Nominal tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type selector
            Text('Tipe Wallet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(height: 8),
            Row(
              children: _walletTypes
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t.label),
                        selected: _selectedType == t.value,
                        onSelected: (_) =>
                            setState(() => _selectedType = t.value),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedType == t.value
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Icon selector
            Text('Ikon',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.05)
                          : AppColors.surface,
                    ),
                    child: WalletIconWidget(iconName: icon, size: 32),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final balance =
        double.tryParse(_balanceCtrl.text.replaceAll('.', '')) ?? 0;

    final notifier = widget.ref.read(walletNotifierProvider.notifier);

    if (widget.wallet == null) {
      await notifier.addWallet(
        name: name,
        type: _selectedType,
        initialBalance: balance,
        iconName: _selectedIcon,
      );
    } else {
      await notifier.updateWallet(widget.wallet!.copyWith(
        name: name,
        type: _selectedType,
        currentBalance: balance,
        iconName: _selectedIcon,
      ));
    }

    if (mounted) Navigator.pop(context);
  }
}

class AdjustBalanceSheet extends StatefulWidget {
  final Wallet wallet;
  final WidgetRef ref;

  const AdjustBalanceSheet(
      {super.key, required this.wallet, required this.ref});

  @override
  State<AdjustBalanceSheet> createState() => _AdjustBalanceSheetState();
}

class _AdjustBalanceSheetState extends State<AdjustBalanceSheet> {
  late TextEditingController _balanceCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _balanceCtrl = TextEditingController(
        text: widget.wallet.currentBalance.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
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
            Text('Sesuaikan Saldo',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Wallet: ${widget.wallet.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Saldo Aktual',
                prefixText: 'Rp ',
                hintText: '0',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Masukkan saldo baru';
                if (double.tryParse(v.replaceAll('.', '')) == null) {
                  return 'Nominal tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _adjust,
                child: const Text('Sesuaikan Saldo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adjust() async {
    if (!_formKey.currentState!.validate()) return;
    final newBalance =
        double.tryParse(_balanceCtrl.text.replaceAll('.', '')) ?? 0;
    await widget.ref
        .read(walletNotifierProvider.notifier)
        .adjustBalance(widget.wallet, newBalance);
    if (mounted) Navigator.pop(context);
  }
}
