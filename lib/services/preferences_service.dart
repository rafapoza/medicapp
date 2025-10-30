import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences
class PreferencesService {
  static const String _keyShowActualTime = 'show_actual_time_for_taken_doses';
  static const String _keyShowFastingCountdown = 'show_fasting_countdown';
  static const String _keyShowFastingNotification = 'show_fasting_notification';

  /// Get the preference for showing actual time for taken doses
  /// Returns true if the user wants to see the actual time when a dose was taken
  /// Returns false (default) to show the scheduled time
  static Future<bool> getShowActualTimeForTakenDoses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowActualTime) ?? false;
  }

  /// Set the preference for showing actual time for taken doses
  static Future<void> setShowActualTimeForTakenDoses(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowActualTime, value);
  }

  /// Get the preference for showing fasting countdown
  /// Returns true if the user wants to see a countdown of remaining fasting time
  /// Returns false (default) to not show the countdown
  static Future<bool> getShowFastingCountdown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowFastingCountdown) ?? false;
  }

  /// Set the preference for showing fasting countdown
  static Future<void> setShowFastingCountdown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowFastingCountdown, value);
  }

  /// Get the preference for showing fasting countdown in ongoing notification
  /// Returns true if the user wants to see an ongoing notification with fasting countdown
  /// Returns false (default) to not show the notification
  /// Note: This only works on Android, iOS doesn't support ongoing notifications
  static Future<bool> getShowFastingNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowFastingNotification) ?? false;
  }

  /// Set the preference for showing fasting countdown in ongoing notification
  static Future<void> setShowFastingNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowFastingNotification, value);
  }
}
