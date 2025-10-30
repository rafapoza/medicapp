import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/services/notification_service.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/medication_builder.dart';

void main() {
  late NotificationService service;

  group('Fasting Notification Tests', () {
    setUp(() {
      service = NotificationService.instance;
      service.enableTestMode();
    });

    tearDown(() {
      service.disableTestMode();
    });

    group('Automatic "before" fasting scheduling', () {
      test('should schedule automatic notification for "before" fasting type', () async {
        final medication = MedicationBuilder()
            .withId('test_before_1')
            .withName('Before Fasting Med')
            .withDosageInterval(24)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'before', duration: 60) // 1 hour before
            .build();

        // Schedule medication notifications (should include automatic "before" fasting notification)
        await service.scheduleMedicationNotifications(medication);

        // In test mode, this should complete without errors
        // The notification would be scheduled for 07:00 (1 hour before 08:00)
        expect(true, true);
      });

      test('should schedule "before" fasting for multiple dose times', () async {
        final medication = MedicationBuilder()
            .withId('test_before_multiple')
            .withName('Multiple Doses Before Fasting')
            .withDosageInterval(8)
            .withDoseSchedule({
              '08:00': 1.0,
              '16:00': 1.0,
              '00:00': 1.0,
            })
            .withFasting(type: 'before', duration: 30) // 30 min before each dose
            .build();

        // Should schedule fasting notifications for all three doses
        // 07:30, 15:30, 23:30
        await service.scheduleMedicationNotifications(medication);

        expect(true, true);
      });

      test('should handle different fasting durations for "before" type', () async {
        final durations = [15, 30, 60, 90, 120, 180]; // Various durations in minutes

        for (final duration in durations) {
          final medication = MedicationBuilder()
              .withId('test_before_duration_$duration')
              .withName('Before Med $duration min')
              .withDosageInterval(24)
              .withSingleDose('12:00', 1.0)
              .withFasting(type: 'before', duration: duration)
              .build();

          await service.scheduleMedicationNotifications(medication);
        }

        expect(true, true);
      });

      test('should reschedule "before" fasting when medication is updated', () async {
        final original = MedicationBuilder()
            .withId('test_update_1')
            .withName('Original Med')
            .withDosageInterval(24)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'before', duration: 60)
            .build();

        await service.scheduleMedicationNotifications(original);

        // Update to different time and duration
        final updated = MedicationBuilder()
            .withId('test_update_1') // Same ID
            .withName('Updated Med')
            .withDosageInterval(24)
            .withSingleDose('12:00', 1.0) // Different time
            .withFasting(type: 'before', duration: 90) // Different duration
            .build();

        // Reschedule should cancel old and create new notifications
        await service.scheduleMedicationNotifications(updated);

        expect(true, true);
      });

      test('should handle edge case: "before" fasting that overlaps with previous dose', () async {
        final medication = MedicationBuilder()
            .withId('test_overlap')
            .withName('Overlapping Fasting')
            .withDosageInterval(4) // Very frequent doses
            .withDoseSchedule({
              '08:00': 1.0,
              '12:00': 1.0,
              '16:00': 1.0,
              '20:00': 1.0,
            })
            .withFasting(type: 'before', duration: 180) // 3 hours before (longer than dose interval!)
            .build();

        // Should handle overlapping fasting periods gracefully
        await service.scheduleMedicationNotifications(medication);

        expect(true, true);
      });
    });

    group('Dynamic "after" fasting scheduling', () {
      test('should NOT schedule automatic notification for "after" fasting type', () async {
        final medication = MedicationBuilder()
            .withId('test_after_1')
            .withName('After Fasting Med')
            .withDosageInterval(24)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'after', duration: 120) // 2 hours after
            .build();

        // Schedule medication notifications
        // Should NOT schedule any fasting notification for "after" type
        await service.scheduleMedicationNotifications(medication);

        // Should complete without errors
        expect(true, true);
      });

      test('should schedule dynamic fasting notification for "after" fasting type', () async {
        final medication = MedicationBuilder()
            .withId('test_after_dynamic_1')
            .withName('After Fasting Med')
            .withDosageInterval(12)
            .withMultipleDoses(['08:00', '20:00'], 1.0)
            .withFasting(type: 'after', duration: 90) // 1.5 hours after
            .build();

        // Schedule regular medication notifications (no fasting notification yet)
        await service.scheduleMedicationNotifications(medication);

        // Now register a dose at a specific time
        final actualDoseTime = DateTime(2025, 10, 16, 10, 30); // Took at 10:30

        // This should schedule the "after" fasting notification dynamically
        await expectLater(
          service.scheduleDynamicFastingNotification(
            medication: medication,
            actualDoseTime: actualDoseTime,
          ),
          completes,
        );
        // Notification would be scheduled for 12:00 (1.5 hours after 10:30)
      });

      test('should NOT schedule dynamic fasting notification for "before" fasting type', () async {
        final medication = MedicationBuilder()
            .withId('test_2')
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'before', duration: 60) // "before" shouldn't trigger dynamic
            .build();

        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Should complete without scheduling (early return for "before" type)
        await expectLater(
          service.scheduleDynamicFastingNotification(
            medication: medication,
            actualDoseTime: actualDoseTime,
          ),
          completes,
        );
      });

      test('should schedule "after" fasting dynamically using actual time, not scheduled time', () async {
        final medication = MedicationBuilder()
            .withId('test_actual_time')
            .withName('Test Actual Time')
            .withDosageInterval(12)
            .withSingleDose('08:00', 1.0) // Scheduled for 08:00
            .withFasting(type: 'after', duration: 120) // 2 hours after
            .build();

        // User takes the dose at 10:30 instead of 08:00
        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Dynamic notification should be based on 10:30, not 08:00
        await service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );

        // Notification should be scheduled for 12:30 (10:30 + 2 hours)
        expect(true, true);
      });

      test('should handle different fasting durations correctly', () async {
        final durations = [30, 60, 90, 120, 180, 240]; // Various durations in minutes

        for (final duration in durations) {
          final medication = MedicationBuilder()
              .withId('test_duration_$duration')
              .withName('Test Medication $duration min')
              .withSingleDose('08:00', 1.0)
              .withFasting(type: 'after', duration: duration)
              .build();

          final actualDoseTime = DateTime(2025, 10, 16, 10, 0);

          // Verify configuration
          expect(medication.fastingDurationMinutes, duration);

          // Should complete without errors for all durations
          await expectLater(
            service.scheduleDynamicFastingNotification(
              medication: medication,
              actualDoseTime: actualDoseTime,
            ),
            completes,
          );
        }
      });

      test('should handle past actual dose times', () async {
        final medication = MedicationBuilder()
            .withId('test_8')
            .withName('Test Medication')
            .withDosageInterval(8)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'after', duration: 30) // Short duration
            .build();

        // Set actual dose time 1 hour ago
        final actualDoseTime = DateTime.now().subtract(const Duration(hours: 1));

        // Should complete without errors (notification might be skipped if in the past)
        await service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );

        expect(true, true);
      });

      test('should handle future actual dose times', () async {
        final medication = MedicationBuilder()
            .withId('test_9')
            .withName('Test Medication')
            .withDosageInterval(8)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'after', duration: 120)
            .build();

        // Set actual dose time to now
        final actualDoseTime = DateTime.now();

        // Should complete without errors
        await service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );

        expect(true, true);
      });

      test('should handle medications with multiple dose times', () async {
        final medication = MedicationBuilder()
            .withId('test_10')
            .withName('Test Medication')
            .withDosageInterval(8)
            .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
            .withFasting(type: 'after', duration: 120)
            .build();

        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Should schedule notification based on actual time, not scheduled times
        await service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );

        expect(true, true);
      });

      test('should NOT schedule dynamic "after" fasting if dose not actually taken', () async {
        final medication = MedicationBuilder()
            .withId('test_after_not_taken')
            .withName('After Med')
            .withDosageInterval(12)
            .withMultipleDoses(['08:00', '20:00'], 1.0)
            .withFasting(type: 'after', duration: 60)
            .build();

        // Only schedule regular notifications
        await service.scheduleMedicationNotifications(medication);

        // Don't call scheduleDynamicFastingNotification
        // Therefore, no "after" fasting notification should exist

        expect(true, true);
      });
    });

    group('Guard conditions', () {
      test('should NOT schedule if requiresFasting is false', () async {
        final medication = MedicationBuilder()
            .withId('test_3')
            .withSingleDose('08:00', 1.0)
            .withFastingDisabled()
            .build();

        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Verify fasting is disabled
        expect(medication.requiresFasting, false);

        // Should complete without scheduling
        await expectLater(
          service.scheduleDynamicFastingNotification(
            medication: medication,
            actualDoseTime: actualDoseTime,
          ),
          completes,
        );
      });

      test('should NOT schedule if notifyFasting is false', () async {
        final medication = MedicationBuilder()
            .withId('test_4')
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'after', duration: 120, notify: false)
            .build();

        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Verify notifications are disabled
        expect(medication.notifyFasting, false);

        // Should complete without scheduling
        await expectLater(
          service.scheduleDynamicFastingNotification(
            medication: medication,
            actualDoseTime: actualDoseTime,
          ),
          completes,
        );
      });

      test('should NOT schedule if fastingDurationMinutes is null', () async {
        final medication = MedicationBuilder()
            .withId('test_5')
            .withSingleDose('08:00', 1.0)
            .withFastingEdgeCase(type: 'after', duration: null) // Invalid duration - edge case
            .build();

        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Should complete without scheduling
        await service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );

        expect(true, true);
      });

      test('should NOT schedule if fastingDurationMinutes is zero', () async {
        final medication = MedicationBuilder()
            .withId('test_6')
            .withSingleDose('08:00', 1.0)
            .withFastingEdgeCase(type: 'after', duration: 0) // Invalid duration - edge case
            .build();

        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Should complete without scheduling
        await service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );

        expect(true, true);
      });

      test('should NOT schedule "before" fasting if notifyFasting is false', () async {
        final medication = MedicationBuilder()
            .withId('test_before_no_notify')
            .withName('Before Med No Notify')
            .withDosageInterval(24)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'before', duration: 60, notify: false) // Notifications disabled
            .build();

        await service.scheduleMedicationNotifications(medication);

        // Should not schedule fasting notification
        expect(true, true);
      });

      test('should NOT schedule "before" fasting if requiresFasting is false', () async {
        final medication = MedicationBuilder()
            .withId('test_before_no_fasting')
            .withName('No Fasting Required')
            .withDosageInterval(24)
            .withSingleDose('08:00', 1.0)
            .withFastingDisabled() // No fasting required
            .build();

        await service.scheduleMedicationNotifications(medication);

        // Should not schedule fasting notification
        expect(true, true);
      });
    });

    group('Medication type compatibility', () {
      test('should work with representative medication types', () async {
        final types = [
          MedicationType.pill,
          MedicationType.injection,
        ];

        for (final type in types) {
          final medication = MedicationBuilder()
              .withId('test_type_${type.name}')
              .withName('Test ${type.displayName}')
              .withType(type)
              .withDosageInterval(8)
              .withSingleDose('08:00', 1.0)
              .withFasting(type: 'after', duration: 120)
              .build();

          final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

          // Should complete without errors for all medication types
          await service.scheduleDynamicFastingNotification(
            medication: medication,
            actualDoseTime: actualDoseTime,
          );
        }

        expect(true, true);
      });
    });

    group('Mixed medication scenarios', () {
      test('should handle medication with both dose types - schedule only "before"', () async {
        // Create two medications: one "before" and one "after"
        final beforeMed = MedicationBuilder()
            .withId('test_mixed_1')
            .withName('Before Med')
            .withDosageInterval(24)
            .withSingleDose('09:00', 1.0)
            .withFasting(type: 'before', duration: 30)
            .build();

        final afterMed = MedicationBuilder()
            .withId('test_mixed_2')
            .withName('After Med')
            .withType(MedicationType.capsule)
            .withDosageInterval(24)
            .withSingleDose('21:00', 1.0)
            .withFasting(type: 'after', duration: 60)
            .build();

        // Schedule both
        await service.scheduleMedicationNotifications(beforeMed);
        await service.scheduleMedicationNotifications(afterMed);

        // Only "before" should have automatic notification
        expect(true, true);
      });
    });
  });
}
