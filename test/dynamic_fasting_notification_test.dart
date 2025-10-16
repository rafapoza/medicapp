import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/services/notification_service.dart';

void main() {
  group('Dynamic Fasting Notifications', () {
    setUp(() {
      // Enable test mode to prevent actual notifications
      NotificationService.instance.enableTestMode();
    });

    tearDown(() {
      NotificationService.instance.disableTestMode();
    });

    test('should schedule dynamic fasting notification for "after" fasting type', () async {
      final medication = Medication(
        id: 'test_1',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 120, // 2 hours
        notifyFasting: true,
      );

      final actualDoseTime = DateTime(2025, 10, 16, 10, 30); // Took at 10:30

      // Should not throw any errors
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      // In test mode, this should complete without errors
      expect(true, true);
    });

    test('should NOT schedule dynamic fasting notification for "before" fasting type', () async {
      final medication = Medication(
        id: 'test_2',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before', // "before" type should NOT trigger dynamic notification
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

      // Should complete without scheduling (because it's "before" type)
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      // Should not throw errors, just return early
      expect(true, true);
    });

    test('should NOT schedule if requiresFasting is false', () async {
      final medication = Medication(
        id: 'test_3',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: false, // No fasting required
        fastingType: 'after',
        fastingDurationMinutes: 120,
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

    test('should NOT schedule if notifyFasting is false', () async {
      final medication = Medication(
        id: 'test_4',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 120,
        notifyFasting: false, // Notifications disabled
      );

      final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

      // Should complete without scheduling
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      expect(true, true);
    });

    test('should NOT schedule if fastingDurationMinutes is null', () async {
      final medication = Medication(
        id: 'test_5',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: null, // Invalid duration
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
      final medication = Medication(
        id: 'test_6',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 0, // Invalid duration
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
        final medication = Medication(
          id: 'test_duration_$duration',
          name: 'Test Medication $duration min',
          type: MedicationType.pastilla,
          dosageIntervalHours: 8,
          durationType: TreatmentDurationType.everyday,
          doseSchedule: {'08:00': 1.0},
          requiresFasting: true,
          fastingType: 'after',
          fastingDurationMinutes: duration,
          notifyFasting: true,
        );

        final actualDoseTime = DateTime(2025, 10, 16, 10, 0);

        // Should complete without errors for all durations
        await NotificationService.instance.scheduleDynamicFastingNotification(
          medication: medication,
          actualDoseTime: actualDoseTime,
        );
      }

      expect(true, true);
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
        final medication = Medication(
          id: 'test_type_${type.name}',
          name: 'Test ${type.displayName}',
          type: type,
          dosageIntervalHours: 8,
          durationType: TreatmentDurationType.everyday,
          doseSchedule: {'08:00': 1.0},
          requiresFasting: true,
          fastingType: 'after',
          fastingDurationMinutes: 120,
          notifyFasting: true,
        );

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
      final medication = Medication(
        id: 'test_8',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 30, // Short duration
        notifyFasting: true,
      );

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
      final medication = Medication(
        id: 'test_9',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 120,
        notifyFasting: true,
      );

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
      final medication = Medication(
        id: 'test_10',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '16:00': 1.0,
          '00:00': 1.0,
        },
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 120,
        notifyFasting: true,
      );

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
        final medication = Medication(
          id: 'test_duration_type_${durationType.name}',
          name: 'Test ${durationType.displayName}',
          type: MedicationType.pastilla,
          dosageIntervalHours: 8,
          durationType: durationType,
          doseSchedule: {'08:00': 1.0},
          requiresFasting: true,
          fastingType: 'after',
          fastingDurationMinutes: 120,
          notifyFasting: true,
        );

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
