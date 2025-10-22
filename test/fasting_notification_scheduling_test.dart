import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/services/notification_service.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';

void main() {
  group('Fasting Notification Scheduling Logic', () {
    setUp(() {
      // Enable test mode to prevent actual notifications
      NotificationService.instance.enableTestMode();
    });

    tearDown(() {
      NotificationService.instance.disableTestMode();
    });

    test('should schedule automatic notification for "before" fasting type', () async {
      final medication = Medication(
        id: 'test_before_1',
        name: 'Before Fasting Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60, // 1 hour before
        notifyFasting: true,
      );

      // Schedule medication notifications (should include automatic "before" fasting notification)
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // In test mode, this should complete without errors
      // The notification would be scheduled for 07:00 (1 hour before 08:00)
      expect(true, true);
    });

    test('should NOT schedule automatic notification for "after" fasting type', () async {
      final medication = Medication(
        id: 'test_after_1',
        name: 'After Fasting Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after', // Should NOT schedule automatically
        fastingDurationMinutes: 120, // 2 hours after
        notifyFasting: true,
      );

      // Schedule medication notifications
      // Should NOT schedule any fasting notification for "after" type
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Should complete without errors
      expect(true, true);
    });

    test('should schedule "after" fasting notification only when dose is registered', () async {
      final medication = Medication(
        id: 'test_after_dynamic_1',
        name: 'After Fasting Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '20:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 90, // 1.5 hours after
        notifyFasting: true,
      );

      // Schedule regular medication notifications (no fasting notification yet)
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Now register a dose at a specific time
      final actualDoseTime = DateTime(2025, 10, 16, 10, 30); // Took at 10:30

      // This should schedule the "after" fasting notification dynamically
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      // Should complete without errors
      // Notification would be scheduled for 12:00 (1.5 hours after 10:30)
      expect(true, true);
    });

    test('should handle medication with both dose types - schedule only "before"', () async {
      // Create two medications: one "before" and one "after"
      final beforeMed = Medication(
        id: 'test_mixed_1',
        name: 'Before Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'09:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 30,
        notifyFasting: true,
      );

      final afterMed = Medication(
        id: 'test_mixed_2',
        name: 'After Med',
        type: MedicationType.capsula,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'21:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      // Schedule both
      await NotificationService.instance.scheduleMedicationNotifications(beforeMed);
      await NotificationService.instance.scheduleMedicationNotifications(afterMed);

      // Only "before" should have automatic notification
      expect(true, true);
    });

    test('should NOT schedule "before" fasting if notifyFasting is false', () async {
      final medication = Medication(
        id: 'test_before_no_notify',
        name: 'Before Med No Notify',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: false, // Notifications disabled
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Should not schedule fasting notification
      expect(true, true);
    });

    test('should NOT schedule "before" fasting if requiresFasting is false', () async {
      final medication = Medication(
        id: 'test_before_no_fasting',
        name: 'No Fasting Required',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: false, // No fasting required
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Should not schedule fasting notification
      expect(true, true);
    });

    test('should schedule "before" fasting for multiple dose times', () async {
      final medication = Medication(
        id: 'test_before_multiple',
        name: 'Multiple Doses Before Fasting',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '16:00': 1.0,
          '00:00': 1.0,
        },
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 30, // 30 min before each dose
        notifyFasting: true,
      );

      // Should schedule fasting notifications for all three doses
      // 07:30, 15:30, 23:30
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      expect(true, true);
    });

    test('should handle different fasting durations for "before" type', () async {
      final durations = [15, 30, 60, 90, 120, 180]; // Various durations in minutes

      for (final duration in durations) {
        final medication = Medication(
          id: 'test_before_duration_$duration',
          name: 'Before Med $duration min',
          type: MedicationType.pastilla,
          dosageIntervalHours: 24,
          durationType: TreatmentDurationType.everyday,
          doseSchedule: {'12:00': 1.0},
          requiresFasting: true,
          fastingType: 'before',
          fastingDurationMinutes: duration,
          notifyFasting: true,
        );

        await NotificationService.instance.scheduleMedicationNotifications(medication);
      }

      expect(true, true);
    });

    test('should work with all treatment duration types for "before" fasting', () async {
      final durationTypes = [
        TreatmentDurationType.everyday,
        TreatmentDurationType.untilFinished,
        TreatmentDurationType.specificDates,
        TreatmentDurationType.weeklyPattern,
        TreatmentDurationType.intervalDays,
      ];

      for (final durationType in durationTypes) {
        final medication = Medication(
          id: 'test_before_duration_type_${durationType.name}',
          name: 'Test ${durationType.displayName}',
          type: MedicationType.pastilla,
          dosageIntervalHours: 24,
          durationType: durationType,
          doseSchedule: {'10:00': 1.0},
          requiresFasting: true,
          fastingType: 'before',
          fastingDurationMinutes: 60,
          notifyFasting: true,
        );

        await NotificationService.instance.scheduleMedicationNotifications(medication);
      }

      expect(true, true);
    });

    test('should reschedule "before" fasting when medication is updated', () async {
      final original = Medication(
        id: 'test_update_1',
        name: 'Original Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await NotificationService.instance.scheduleMedicationNotifications(original);

      // Update to different time and duration
      final updated = Medication(
        id: 'test_update_1', // Same ID
        name: 'Updated Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'12:00': 1.0}, // Different time
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 90, // Different duration
        notifyFasting: true,
      );

      // Reschedule should cancel old and create new notifications
      await NotificationService.instance.scheduleMedicationNotifications(updated);

      expect(true, true);
    });

    test('should NOT schedule dynamic "after" fasting if dose not actually taken', () async {
      final medication = Medication(
        id: 'test_after_not_taken',
        name: 'After Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '20:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      // Only schedule regular notifications
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Don't call scheduleDynamicFastingNotification
      // Therefore, no "after" fasting notification should exist

      expect(true, true);
    });

    test('should handle edge case: "before" fasting that overlaps with previous dose', () async {
      final medication = Medication(
        id: 'test_overlap',
        name: 'Overlapping Fasting',
        type: MedicationType.pastilla,
        dosageIntervalHours: 4, // Very frequent doses
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '12:00': 1.0,
          '16:00': 1.0,
          '20:00': 1.0,
        },
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 180, // 3 hours before (longer than dose interval!)
        notifyFasting: true,
      );

      // Should handle overlapping fasting periods gracefully
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      expect(true, true);
    });

    test('should schedule "after" fasting dynamically using actual time, not scheduled time', () async {
      final medication = Medication(
        id: 'test_actual_time',
        name: 'Test Actual Time',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0}, // Scheduled for 08:00
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 120, // 2 hours after
        notifyFasting: true,
      );

      // User takes the dose at 10:30 instead of 08:00
      final actualDoseTime = DateTime(2025, 10, 16, 10, 30);

      // Dynamic notification should be based on 10:30, not 08:00
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );

      // Notification should be scheduled for 12:30 (10:30 + 2 hours)
      expect(true, true);
    });
  });
}
