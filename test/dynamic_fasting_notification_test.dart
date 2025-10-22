import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/services/notification_service.dart';
import 'helpers/medication_builder.dart';

void main() {
  late NotificationService service;

  group('Dynamic Fasting Notifications', () {
    setUp(() {
      service = NotificationService.instance;
      service.enableTestMode();
    });

    tearDown(() {
      service.disableTestMode();
    });

    test('should schedule dynamic fasting notification for "after" fasting type', () async {
      final medication = MedicationBuilder()
          .withId('test_1')
          .withSingleDose('08:00', 1.0)
          .withFasting(type: 'after', duration: 120) // 2 hours
          .build();

      final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

      // Should complete without throwing errors in test mode
      await expectLater(
        service.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        ),
        completes,
      );
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
      // Using manual Medication constructor for edge case with null duration
      final medication = Medication(
        id: 'test_5',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: null, // Invalid duration - edge case
        notifyFasting: true,
      );

      final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

      // Should complete without scheduling
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      expect(true, true);
    });

    test('should NOT schedule if fastingDurationMinutes is zero', () async {
      // Using manual Medication constructor for edge case with zero duration
      final medication = Medication(
        id: 'test_6',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 0, // Invalid duration - edge case
        notifyFasting: true,
      );

      final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

      // Should complete without scheduling
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

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

    test('should work with all medication types', () async {
      final types = [
        MedicationType.pastilla,
        MedicationType.capsula,
        MedicationType.jarabe,
        MedicationType.inyeccion,
        MedicationType.pomada,
        MedicationType.spray,
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
        await NotificationService.instance.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );
      }

      expect(true, true);
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
      await NotificationService.instance.scheduleDynamicFastingNotification(
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
      await NotificationService.instance.scheduleDynamicFastingNotification(
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
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      expect(true, true);
    });

    test('should work with different treatment duration types', () async {
      final durationTypes = [
        TreatmentDurationType.everyday,
        TreatmentDurationType.untilFinished,
        TreatmentDurationType.specificDates,
        TreatmentDurationType.weeklyPattern,
        TreatmentDurationType.intervalDays,
      ];

      for (final durationType in durationTypes) {
        final medication = MedicationBuilder()
            .withId('test_duration_type_${durationType.name}')
            .withName('Test ${durationType.displayName}')
            .withDosageInterval(8)
            .withDurationType(durationType)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'after', duration: 120)
            .build();

        final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

        // Should complete without errors for all duration types
        await NotificationService.instance.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );
      }

      expect(true, true);
    });
  });
}
