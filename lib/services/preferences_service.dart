import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences
class PreferencesService {
  static const String _keyShowActualTime = 'show_actual_time_for_taken_doses';

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
}
