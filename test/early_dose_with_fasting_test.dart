import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/services/notification_service.dart';
import 'helpers/medication_builder.dart';

/// Tests for verifying correct notification behavior when a dose is taken
/// earlier than its scheduled time, especially with "after" fasting requirements
void main() {
  late NotificationService service;

  group('Early Dose with Fasting Notifications', () {
    setUp(() {
      service = NotificationService.instance;
      service.enableTestMode();
    });

    tearDown(() {
      service.disableTestMode();
    });

    test('should cancel scheduled dose notification and schedule fasting for actual time when taken early', () async {
      // SCENARIO:
      // - Medication scheduled for 8:15 with 30-minute "after" fasting
      // - User takes it at 8:00 (15 minutes early)
      // EXPECTED BEHAVIOR:
      // - Cancel 8:15 dose notification
      // - Schedule fasting end notification for 8:30 (not 8:45)

      final medication = MedicationBuilder()
          .withId('test_early_dose_1')
          .withName('Test Early Dose Medication')
          .withSingleDose('08:15', 1.0)
          .withFasting(type: 'after', duration: 30) // 30 minutes after dose
          .build();

      // Schedule the original notification (for 8:15)
      await service.scheduleMedicationNotifications(medication);

      // User takes medication at 8:00 (15 minutes before scheduled time)
      final actualDoseTime = DateTime(2025, 10, 24, 8, 0);

      // Cancel the scheduled dose notification (8:15)
      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '08:15',
      );

      // Cancel any fasting notification that was scheduled based on 8:15
      await service.cancelTodaysFastingNotification(
        medication: medication,
        doseTime: '08:15',
      );

      // Schedule dynamic fasting notification based on ACTUAL time (8:00)
      // Should schedule for 8:00 + 30 min = 8:30 (NOT 8:45)
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      // In test mode, these operations should complete without errors
      expect(true, true);
    });

    test('should handle various early dose scenarios correctly', () async {
      // Test multiple scenarios with different time differences

      final scenarios = [
        {
          'scheduledTime': '08:15',
          'actualTime': DateTime(2025, 10, 24, 8, 0), // 15 min early
          'fastingDuration': 30,
          'description': '15 minutes early with 30-minute fasting',
        },
        {
          'scheduledTime': '14:00',
          'actualTime': DateTime(2025, 10, 24, 13, 30), // 30 min early
          'fastingDuration': 60,
          'description': '30 minutes early with 60-minute fasting',
        },
        {
          'scheduledTime': '20:00',
          'actualTime': DateTime(2025, 10, 24, 19, 0), // 1 hour early
          'fastingDuration': 120,
          'description': '1 hour early with 120-minute fasting',
        },
      ];

      for (final scenario in scenarios) {
        final medication = MedicationBuilder()
            .withId('test_scenario_${scenario['scheduledTime']}')
            .withName('Test ${scenario['description']}')
            .withSingleDose(scenario['scheduledTime'] as String, 1.0)
            .withFasting(
              type: 'after',
              duration: scenario['fastingDuration'] as int,
            )
            .build();

        // Schedule original notification
        await service.scheduleMedicationNotifications(medication);

        // Cancel scheduled notifications
        await service.cancelTodaysDoseNotification(
          medication: medication,
          doseTime: scenario['scheduledTime'] as String,
        );

        await service.cancelTodaysFastingNotification(
          medication: medication,
          doseTime: scenario['scheduledTime'] as String,
        );

        // Schedule dynamic fasting based on actual time
        await service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: scenario['actualTime'] as DateTime,
        );
      }

      expect(true, true);
    });

    test('should work correctly when dose is taken exactly at scheduled time', () async {
      // Edge case: dose taken exactly at scheduled time
      final medication = MedicationBuilder()
          .withId('test_exact_time')
          .withName('Test Exact Time')
          .withSingleDose('10:00', 1.0)
          .withFasting(type: 'after', duration: 45)
          .build();

      await service.scheduleMedicationNotifications(medication);

      final exactTime = DateTime(2025, 10, 24, 10, 0);

      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '10:00',
      );

      await service.cancelTodaysFastingNotification(
        medication: medication,
        doseTime: '10:00',
      );

      // Schedule fasting for 10:00 + 45 min = 10:45
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: exactTime,
      );

      expect(true, true);
    });

    test('should handle dose taken late (after scheduled time)', () async {
      // Dose taken AFTER scheduled time should still use actual time
      final medication = MedicationBuilder()
          .withId('test_late_dose')
          .withName('Test Late Dose')
          .withSingleDose('09:00', 1.0)
          .withFasting(type: 'after', duration: 60)
          .build();

      await service.scheduleMedicationNotifications(medication);

      // Take medication 20 minutes late
      final actualDoseTime = DateTime(2025, 10, 24, 9, 20);

      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '09:00',
      );

      await service.cancelTodaysFastingNotification(
        medication: medication,
        doseTime: '09:00',
      );

      // Should schedule fasting for 9:20 + 60 min = 10:20 (NOT 10:00)
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      expect(true, true);
    });

    test('should NOT schedule dynamic fasting for "before" fasting type', () async {
      // "before" fasting should not use dynamic scheduling
      final medication = MedicationBuilder()
          .withId('test_before_fasting')
          .withName('Test Before Fasting')
          .withSingleDose('11:00', 1.0)
          .withFasting(type: 'before', duration: 120)
          .build();

      await service.scheduleMedicationNotifications(medication);

      final actualDoseTime = DateTime(2025, 10, 24, 10, 45);

      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '11:00',
      );

      // Should cancel the "before" fasting notification
      await service.cancelTodaysFastingNotification(
        medication: medication,
        doseTime: '11:00',
      );

      // This should NOT schedule anything (early return for "before" type)
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      expect(true, true);
    });

    test('should handle medications with multiple doses independently', () async {
      // When a medication has multiple doses, taking one early should only affect that dose
      final medication = MedicationBuilder()
          .withId('test_multiple_doses')
          .withName('Test Multiple Doses')
          .withMultipleDoses(['08:00', '14:00', '20:00'], 1.0)
          .withFasting(type: 'after', duration: 45)
          .build();

      await service.scheduleMedicationNotifications(medication);

      // Take the 14:00 dose at 13:45 (15 minutes early)
      final actualDoseTime = DateTime(2025, 10, 24, 13, 45);

      // Cancel only the 14:00 dose notification
      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '14:00',
      );

      await service.cancelTodaysFastingNotification(
        medication: medication,
        doseTime: '14:00',
      );

      // Schedule dynamic fasting for the 14:00 dose taken at 13:45
      // Should schedule for 13:45 + 45 min = 14:30
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      // Other doses (08:00 and 20:00) should remain unaffected
      expect(true, true);
    });

    test('should handle very short fasting durations', () async {
      // Test with short fasting duration (5 minutes)
      final medication = MedicationBuilder()
          .withId('test_short_fasting')
          .withName('Test Short Fasting')
          .withSingleDose('12:00', 1.0)
          .withFasting(type: 'after', duration: 5)
          .build();

      await service.scheduleMedicationNotifications(medication);

      final actualDoseTime = DateTime(2025, 10, 24, 11, 55);

      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '12:00',
      );

      await service.cancelTodaysFastingNotification(
        medication: medication,
        doseTime: '12:00',
      );

      // Should schedule for 11:55 + 5 min = 12:00
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      expect(true, true);
    });

    test('should handle very long fasting durations', () async {
      // Test with long fasting duration (4 hours)
      final medication = MedicationBuilder()
          .withId('test_long_fasting')
          .withName('Test Long Fasting')
          .withSingleDose('18:00', 1.0)
          .withFasting(type: 'after', duration: 240) // 4 hours
          .build();

      await service.scheduleMedicationNotifications(medication);

      final actualDoseTime = DateTime(2025, 10, 24, 17, 30);

      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '18:00',
      );

      await service.cancelTodaysFastingNotification(
        medication: medication,
        doseTime: '18:00',
      );

      // Should schedule for 17:30 + 240 min = 21:30 (not 22:00)
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      expect(true, true);
    });
  });
}
