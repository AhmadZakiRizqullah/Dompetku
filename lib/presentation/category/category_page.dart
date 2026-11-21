import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/database.dart';
import '../../providers/category_provider.dart';
import '../widgets/wallet_icon_widget.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incomeAsync = ref.watch(incomeCategoriesProvider);
    final expenseAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddCategorySheet(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Income tab
          _CategoryList(
            categoriesAsync: incomeAsync,
            type: CategoryType.income,
            onAdd: () => _showAddCategorySheet(context,
                defaultType: CategoryType.income),
            onEdit: (cat) => _showAddCategorySheet(context, category: cat),
            onDelete: (cat) => _confirmDelete(context, cat),
          ),
          // Expense tab
          _CategoryList(
            categoriesAsync: expenseAsync,
            type: CategoryType.expense,
            onAdd: () => _showAddCategorySheet(context,
                defaultType: CategoryType.expense),
            onEdit: (cat) => _showAddCategorySheet(context, category: cat),
            onDelete: (cat) => _confirmDelete(context, cat),
          ),
        ],
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context,
      {Category? category, String? defaultType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditCategorySheet(
        category: category,
        defaultType: defaultType ?? CategoryType.expense,
        ref: ref,
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content:
            Text('Hapus kategori "${category.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(categoryNotifierProvider.notifier)
                  .deleteCategory(category.id);
            },
            child: Text('Hapus',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final AsyncValue<List<Category>> categoriesAsync;
  final String type;
  final VoidCallback onAdd;
  final void Function(Category) onEdit;
  final void Function(Category) onDelete;

  const _CategoryList({
    required this.categoriesAsync,
    required this.type,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      data: (categories) => categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined,
                      size: 60, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  Text('Belum ada kategori',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Kategori'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final cat = categories[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CategoryIconWidget(
                          iconName: cat.iconName, categoryType: cat.type),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(cat.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        color: AppColors.primary,
                        onPressed: () => onEdit(cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18),
                        color: AppColors.accent,
                        onPressed: () => onDelete(cat),
                      ),
                    ],
                  ),
                );
              },
            ),
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Memuat daftar kategori...',
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
                'Gagal memuat kategori',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Terjadi kendala saat mengambil data kategori.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add/Edit Category Bottom Sheet ────────────────────────────────────────

class AddEditCategorySheet extends StatefulWidget {
  final Category? category;
  final String defaultType;
  final WidgetRef ref;

  const AddEditCategorySheet({
    super.key,
    this.category,
    required this.defaultType,
    required this.ref,
  });

  @override
  State<AddEditCategorySheet> createState() => _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends State<AddEditCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late String _selectedType;
  String _selectedIcon = 'other';

  final _iconOptions = [
    'food', 'transport', 'shopping', 'bill', 'health',
    'entertainment', 'education', 'home', 'communication',
    'salary', 'bonus', 'investment', 'freelance', 'gift', 'other',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.category?.type ?? widget.defaultType;
    _selectedIcon = widget.category?.iconName ?? 'other';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
            Text(
              widget.category != null ? 'Edit Kategori' : 'Tambah Kategori',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // Type
            Text('Tipe',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Pemasukan'),
                  selected: _selectedType == CategoryType.income,
                  onSelected: (v) {
                    if (v) setState(() => _selectedType = CategoryType.income);
                  },
                  selectedColor: AppColors.income,
                  labelStyle: TextStyle(
                    color: _selectedType == CategoryType.income
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Pengeluaran'),
                  selected: _selectedType == CategoryType.expense,
                  onSelected: (v) {
                    if (v) setState(() => _selectedType = CategoryType.expense);
                  },
                  selectedColor: AppColors.expense,
                  labelStyle: TextStyle(
                    color: _selectedType == CategoryType.expense
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ],
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
                    child: CategoryIconWidget(
                        iconName: icon,
                        categoryType: _selectedType,
                        size: 32),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(widget.category != null
                    ? 'Simpan Perubahan'
                    : 'Tambah Kategori'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = widget.ref.read(categoryNotifierProvider.notifier);

    if (widget.category == null) {
      await notifier.addCategory(
        name: _nameCtrl.text.trim(),
        type: _selectedType,
        iconName: _selectedIcon,
      );
    } else {
      await notifier.updateCategory(
        widget.category!.copyWith(
          name: _nameCtrl.text.trim(),
          type: _selectedType,
          iconName: _selectedIcon,
        ),
      );
    }

    if (mounted) Navigator.pop(context);
  }
}
