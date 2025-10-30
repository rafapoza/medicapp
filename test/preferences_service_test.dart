import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicapp/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock SharedPreferences with empty initial values
    SharedPreferences.setMockInitialValues({});
  });

  group('PreferencesService - Show Actual Time', () {
    test('should return false by default for show actual time', () async {
      final result = await PreferencesService.getShowActualTimeForTakenDoses();
      expect(result, false);
    });

    test('should save and retrieve show actual time preference', () async {
      await PreferencesService.setShowActualTimeForTakenDoses(true);
      final result = await PreferencesService.getShowActualTimeForTakenDoses();
      expect(result, true);
    });

    test('should update show actual time preference', () async {
      await PreferencesService.setShowActualTimeForTakenDoses(true);
      await PreferencesService.setShowActualTimeForTakenDoses(false);
      final result = await PreferencesService.getShowActualTimeForTakenDoses();
      expect(result, false);
    });
  });

  group('PreferencesService - Show Fasting Countdown', () {
    test('should return false by default for show fasting countdown', () async {
      final result = await PreferencesService.getShowFastingCountdown();
      expect(result, false);
    });

    test('should save and retrieve show fasting countdown preference', () async {
      await PreferencesService.setShowFastingCountdown(true);
      final result = await PreferencesService.getShowFastingCountdown();
      expect(result, true);
    });

    test('should update show fasting countdown preference', () async {
      await PreferencesService.setShowFastingCountdown(true);
      await PreferencesService.setShowFastingCountdown(false);
      final result = await PreferencesService.getShowFastingCountdown();
      expect(result, false);
    });
  });

  group('PreferencesService - Show Fasting Notification', () {
    test('should return false by default for show fasting notification', () async {
      final result = await PreferencesService.getShowFastingNotification();
      expect(result, false);
    });

    test('should save and retrieve show fasting notification preference', () async {
      await PreferencesService.setShowFastingNotification(true);
      final result = await PreferencesService.getShowFastingNotification();
      expect(result, true);
    });

    test('should update show fasting notification preference', () async {
      await PreferencesService.setShowFastingNotification(true);
      await PreferencesService.setShowFastingNotification(false);
      final result = await PreferencesService.getShowFastingNotification();
      expect(result, false);
    });

    test('should handle multiple preference changes', () async {
      // Set initial values
      await PreferencesService.setShowFastingNotification(true);
      expect(await PreferencesService.getShowFastingNotification(), true);

      // Toggle multiple times
      await PreferencesService.setShowFastingNotification(false);
      expect(await PreferencesService.getShowFastingNotification(), false);

      await PreferencesService.setShowFastingNotification(true);
      expect(await PreferencesService.getShowFastingNotification(), true);
    });
  });

  group('PreferencesService - Combined Preferences', () {
    test('should handle multiple preferences independently', () async {
      await PreferencesService.setShowActualTimeForTakenDoses(true);
      await PreferencesService.setShowFastingCountdown(true);
      await PreferencesService.setShowFastingNotification(false);

      expect(await PreferencesService.getShowActualTimeForTakenDoses(), true);
      expect(await PreferencesService.getShowFastingCountdown(), true);
      expect(await PreferencesService.getShowFastingNotification(), false);
    });

    test('should not affect other preferences when changing one', () async {
      // Set initial state
      await PreferencesService.setShowActualTimeForTakenDoses(true);
      await PreferencesService.setShowFastingCountdown(true);
      await PreferencesService.setShowFastingNotification(true);

      // Change one preference
      await PreferencesService.setShowFastingNotification(false);

      // Others should remain unchanged
      expect(await PreferencesService.getShowActualTimeForTakenDoses(), true);
      expect(await PreferencesService.getShowFastingCountdown(), true);
      expect(await PreferencesService.getShowFastingNotification(), false);
    });
  });
}
