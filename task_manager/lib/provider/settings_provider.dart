import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyReminderMinutes = 'reminder_minutes';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  
  int _reminderMinutes = 10; // Default: 10 minutes before
  bool _notificationsEnabled = true;

  int get reminderMinutes => _reminderMinutes;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderMinutes = prefs.getInt(_keyReminderMinutes) ?? 10;
    _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;
    notifyListeners();
  }

  Future<void> setReminderMinutes(int minutes) async {
    _reminderMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderMinutes, minutes);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
    notifyListeners();
  }

  // Get reminder options
  static List<int> get reminderOptions => [0, 5, 15, 30];
  
  String getReminderLabel(int minutes) {
    if (minutes == 0) return 'At time';
    return 'Before $minutes minutes';
  }
}



