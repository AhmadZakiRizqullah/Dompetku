import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Keys ───────────────────────────────────────────────────────────────────
const _kUserName = 'user_name';
const _kBalanceVisible = 'balance_visible';
const _kWalletsVisible = 'wallets_visible';
const _kReminderEnabled = 'reminder_enabled';
const _kReminderHour = 'reminder_hour';
const _kReminderMinute = 'reminder_minute';

// ─── SharedPreferences instance ─────────────────────────────────────────────
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden with a valid instance');
});

// ─── User Name ──────────────────────────────────────────────────────────────
final userNameProvider =
    StateNotifierProvider<UserNameNotifier, String>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return UserNameNotifier(prefs);
});

class UserNameNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  UserNameNotifier(this._prefs)
      : super(_prefs.getString(_kUserName) ?? 'Dompetku');

  void setName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
    _prefs.setString(_kUserName, trimmed);
  }
}

// ─── Balance Visibility ─────────────────────────────────────────────────────
final balanceVisibleProvider =
    StateNotifierProvider<BalanceVisibleNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return BalanceVisibleNotifier(prefs);
});

class BalanceVisibleNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  BalanceVisibleNotifier(this._prefs)
      : super(_prefs.getBool(_kBalanceVisible) ?? true);

  void toggle() {
    state = !state;
    _prefs.setBool(_kBalanceVisible, state);
  }
}

// ─── Wallets Visibility (Dashboard) ─────────────────────────────────────────
final walletsVisibleProvider =
    StateNotifierProvider<WalletsVisibleNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return WalletsVisibleNotifier(prefs);
});

class WalletsVisibleNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  WalletsVisibleNotifier(this._prefs)
      : super(_prefs.getBool(_kWalletsVisible) ?? true);

  void toggle() {
    state = !state;
    _prefs.setBool(_kWalletsVisible, state);
  }

  void setVisible(bool visible) {
    state = visible;
    _prefs.setBool(_kWalletsVisible, visible);
  }
}

// ─── Daily Reminder ─────────────────────────────────────────────────────────
final reminderEnabledProvider =
    StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ReminderEnabledNotifier(prefs);
});

class ReminderEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  ReminderEnabledNotifier(this._prefs)
      : super(_prefs.getBool(_kReminderEnabled) ?? false);

  void setEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_kReminderEnabled, enabled);
  }

  void toggle() {
    state = !state;
    _prefs.setBool(_kReminderEnabled, state);
  }
}

final reminderTimeProvider =
    StateNotifierProvider<ReminderTimeNotifier, ({int hour, int minute})>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ReminderTimeNotifier(prefs);
});

class ReminderTimeNotifier
    extends StateNotifier<({int hour, int minute})> {
  final SharedPreferences _prefs;

  ReminderTimeNotifier(this._prefs)
      : super((
          hour: _prefs.getInt(_kReminderHour) ?? 20,
          minute: _prefs.getInt(_kReminderMinute) ?? 0,
        ));

  void setTime(int hour, int minute) {
    state = (hour: hour, minute: minute);
    _prefs.setInt(_kReminderHour, hour);
    _prefs.setInt(_kReminderMinute, minute);
  }
}
