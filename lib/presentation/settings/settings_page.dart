import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/services/excel_service.dart';
import '../../data/services/pdf_service.dart';
import '../../data/services/notification_service.dart';
import '../../providers/database_provider.dart';
import '../../providers/user_preferences_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isExporting = false;
  bool _isImporting = false;

  DateTime? _exportStart;
  DateTime? _exportEnd;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final excelService = ExcelService(db);
    final pdfService = PdfService(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export section
            Text('Ekspor Data',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Unduh data transaksi ke dalam file Excel atau PDF.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Date range selector
            _DateRangeCard(
              startDate: _exportStart,
              endDate: _exportEnd,
              onStartPick: (d) => setState(() => _exportStart = d),
              onEndPick: (d) => setState(
                  () => _exportEnd = DateTime(d.year, d.month, d.day, 23, 59, 59)),
              onClear: () => setState(() {
                _exportStart = null;
                _exportEnd = null;
              }),
            ),
            const SizedBox(height: 16),

            // Excel export
            _SettingsTile(
              icon: Icons.table_chart_rounded,
              iconColor: const Color(0xFF1D6F42),
              title: 'Export ke Excel (.xlsx)',
              subtitle: 'Unduh riwayat transaksi ke spreadsheet',
              trailing: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: () async {
                setState(() => _isExporting = true);
                try {
                  await excelService.exportToExcel(
                    startDate: _exportStart,
                    endDate: _exportEnd,
                  );
                  _showSnackBar('File Excel berhasil diekspor!', isError: false);
                } catch (e) {
                  _showSnackBar('Gagal export: $e');
                } finally {
                  setState(() => _isExporting = false);
                }
              },
            ),
            const SizedBox(height: 12),

            // PDF export
            _SettingsTile(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: const Color(0xFFBE0000),
              title: 'Export ke PDF (.pdf)',
              subtitle: 'Buat laporan keuangan siap cetak',
              onTap: () async {
                setState(() => _isExporting = true);
                try {
                  await pdfService.exportToPdf(
                    startDate: _exportStart,
                    endDate: _exportEnd,
                  );
                  _showSnackBar('Laporan PDF berhasil dibuat!', isError: false);
                } catch (e) {
                  _showSnackBar('Gagal buat PDF: $e');
                } finally {
                  setState(() => _isExporting = false);
                }
              },
            ),
            const SizedBox(height: 32),

            // Import section
            Text('Impor Data',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Masukkan banyak transaksi sekaligus dari file Excel.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Download template
            _SettingsTile(
              icon: Icons.download_rounded,
              iconColor: AppColors.secondary,
              title: 'Unduh Template Excel',
              subtitle: 'Dapatkan format kolom yang benar untuk impor',
              onTap: () async {
                try {
                  await excelService.exportTemplate();
                } catch (e) {
                  _showSnackBar('Gagal unduh template: $e');
                }
              },
            ),
            const SizedBox(height: 12),

            // Import Excel
            _SettingsTile(
              icon: Icons.upload_file_rounded,
              iconColor: AppColors.primary,
              title: 'Import dari Excel (.xlsx)',
              subtitle: 'Pilih file Excel sesuai template untuk diimpor',
              trailing: _isImporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: () async {
                setState(() => _isImporting = true);
                try {
                  final result = await excelService.importFromExcel();
                  if (mounted) {
                    if (result.errorCount > 0 || result.skippedCount > 0) {
                      _showImportResultDialog(result);
                    } else {
                      _showSnackBar(result.message, isError: false);
                    }
                  }
                } catch (e) {
                  _showSnackBar('Gagal import: $e');
                } finally {
                  setState(() => _isImporting = false);
                }
              },
            ),
            const SizedBox(height: 32),

            // Daily Reminder section
            Text('Pengingat Harian',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Notifikasi harian agar tidak lupa mencatat keuangan kamu.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const _ReminderCard(),
            const SizedBox(height: 32),

            // App info
            Text('Informasi Aplikasi',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.textSecondary,
              title: 'Dompetku v1.1.0',
              subtitle: 'Aplikasi pencatatan keuangan pribadi (Offline)',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.accent : AppColors.primary,
      ),
    );
  }

  void _showImportResultDialog(dynamic result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hasil Import'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(result.message),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Detail Error:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...result.errors.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $e',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.accent)),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
        ],
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(reminderEnabledProvider);
    final reminderTime = ref.watch(reminderTimeProvider);

    final hourStr = reminderTime.hour.toString().padLeft(2, '0');
    final minuteStr = reminderTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hourStr:$minuteStr';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengingat Harian',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled
                          ? 'Aktif setiap pukul $timeStr WIB'
                          : 'Pengingat harian nonaktif',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (val) async {
                  if (val) {
                    final granted =
                        await NotificationService.instance.requestPermission();
                    if (!context.mounted) return;
                    if (!granted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Izin notifikasi belum diberikan di pengaturan HP'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                      return;
                    }
                    await NotificationService.instance.scheduleDailyReminder(
                      hour: reminderTime.hour,
                      minute: reminderTime.minute,
                    );
                    ref
                        .read(reminderEnabledProvider.notifier)
                        .setEnabled(true);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Pengingat harian aktif setiap pukul $timeStr WIB'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } else {
                    await NotificationService.instance.cancelDailyReminder();
                    ref
                        .read(reminderEnabledProvider.notifier)
                        .setEnabled(false);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengingat harian dinonaktifkan'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Waktu Pengingat',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: reminderTime.hour,
                        minute: reminderTime.minute,
                      ),
                    );
                    if (picked != null) {
                      ref
                          .read(reminderTimeProvider.notifier)
                          .setTime(picked.hour, picked.minute);
                      await NotificationService.instance.scheduleDailyReminder(
                        hour: picked.hour,
                        minute: picked.minute,
                      );
                      if (!context.mounted) return;
                      final newH = picked.hour.toString().padLeft(2, '0');
                      final newM = picked.minute.toString().padLeft(2, '0');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Waktu pengingat diubah ke $newH:$newM WIB'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$timeStr WIB',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_outlined,
                            size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.instance.showTestNotification();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifikasi tes berhasil dikirim! 🔔'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Kirim Notifikasi Tes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime) onStartPick;
  final void Function(DateTime) onEndPick;
  final VoidCallback onClear;

  const _DateRangeCard({
    required this.startDate,
    required this.endDate,
    required this.onStartPick,
    required this.onEndPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Rentang Tanggal (Opsional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      )),
              const Spacer(),
              if (startDate != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.accent, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Dari',
                  date: startDate,
                  onPick: onStartPick,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('—', style: TextStyle(color: AppColors.textSecondary)),
              ),
              Expanded(
                child: _DateButton(
                  label: 'Sampai',
                  date: endDate,
                  onPick: onEndPick,
                ),
              ),
            ],
          ),
          if (startDate == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Kosongkan untuk ekspor semua data',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final void Function(DateTime) onPick;

  const _DateButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              date != null ? DateFormatter.formatShort(date!) : 'Pilih...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        date != null ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
