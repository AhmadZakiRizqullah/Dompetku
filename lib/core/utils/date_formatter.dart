import 'package:intl/intl.dart';

class DateFormatter {
  static final _fullDate = DateFormat('d MMMM yyyy', 'id_ID');
  static final _shortDate = DateFormat('d MMM yyyy', 'id_ID');
  static final _monthYear = DateFormat('MMMM yyyy', 'id_ID');
  static final _dayMonthYear = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _fullDateTime = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
  static final _isoDate = DateFormat('yyyy-MM-dd');
  static final _dayName = DateFormat('EEEE', 'id_ID');
  static final _shortDay = DateFormat('EEE', 'id_ID');

  /// Full date format: "31 Oktober 2026"
  static String formatFull(DateTime date) => _fullDate.format(date);

  /// Short date format: "31 Okt 2026"
  static String formatShort(DateTime date) => _shortDate.format(date);

  /// Month and year: "Oktober 2026"
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// DD/MM/YYYY format: "31/10/2026"
  static String formatSlash(DateTime date) => _dayMonthYear.format(date);

  /// Time only: "19:30"
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Full date-time: "31 Okt 2026, 19:30"
  static String formatFullDateTime(DateTime date) =>
      _fullDateTime.format(date);

  /// ISO date for import/export: "2026-10-31"
  static String formatISO(DateTime date) => _isoDate.format(date);

  /// Day name: "Sabtu"
  static String formatDayName(DateTime date) => _dayName.format(date);

  /// Short day name: "Sab"
  static String formatShortDay(DateTime date) => _shortDay.format(date);

  /// Parse ISO date string to DateTime.
  static DateTime? parseISO(String dateStr) {
    try {
      return _isoDate.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Returns "Hari ini", "Kemarin", or formatted date.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDay).inDays;

    if (difference == 0) return 'Hari ini';
    if (difference == 1) return 'Kemarin';
    return formatShort(date);
  }
}
