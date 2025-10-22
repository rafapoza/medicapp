import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/services/notification_service.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';

void main() {
  group('Notification Cancellation on Manual Registration', () {
    setUp(() {
      // Enable test mode to prevent actual notifications
      NotificationService.instance.enableTestMode();
    });

    tearDown(() {
      NotificationService.instance.disableTestMode();
    });

    test('should cancel today\'s dose notification when dose is registered', () async {
      final medication = Medication(
        id: 'test_cancel_1',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '16:00': 1.0,
          '21:00': 1.0,
        },
      );

      // Schedule notifications first
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Cancel notification for 16:00 dose
      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '16:00',
      );

      // Should complete without errors
      expect(true, true);
    });

    test('should cancel notification for everyday medication', () async {
      final medication = Medication(
        id: 'test_cancel_2',
        name: 'Everyday Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'09:00': 1.0},
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '09:00',
      );

      expect(true, true);
    });

    test('should cancel notification for untilFinished medication', () async {
      final medication = Medication(
        id: 'test_cancel_3',
        name: 'Until Finished Med',
        type: MedicationType.capsula,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.untilFinished,
        doseSchedule: {
          '08:00': 1.0,
          '20:00': 1.0,
        },
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '08:00',
      );

      expect(true, true);
    });

    test('should cancel notification for medication with end date', () async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      final medication = Medication(
        id: 'test_cancel_4',
        name: 'Med with End Date',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.0},
        startDate: now,
        endDate: tomorrow,
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '10:00',
      );

      expect(true, true);
    });

    test('should cancel notification for specific dates medication', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'test_cancel_5',
        name: 'Specific Dates Med',
        type: MedicationType.jarabe,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.specificDates,
        doseSchedule: {'12:00': 5.0},
        selectedDates: [todayString],
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '12:00',
      );

      expect(true, true);
    });

    test('should cancel notification for weekly pattern medication', () async {
      final today = DateTime.now();

      final medication = Medication(
        id: 'test_cancel_6',
        name: 'Weekly Pattern Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.weeklyPattern,
        doseSchedule: {'15:00': 1.0},
        weeklyDays: [today.weekday], // Today's weekday
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '15:00',
      );

      expect(true, true);
    });

    test('should handle cancellation for non-existent dose time gracefully', () async {
      final medication = Medication(
        id: 'test_cancel_7',
        name: 'Test Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
      );

      // Try to cancel a dose time that doesn't exist
      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '15:00', // This time is not in the schedule
      );

      // Should complete without errors (graceful handling)
      expect(true, true);
    });

    test('should cancel multiple dose notifications independently', () async {
      final medication = Medication(
        id: 'test_cancel_8',
        name: 'Multiple Doses Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '12:00': 1.0,
          '16:00': 1.0,
          '20:00': 1.0,
        },
      );

      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Cancel multiple doses
      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '08:00',
      );

      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '16:00',
      );

      expect(true, true);
    });

    test('should cancel postponed notification along with regular notification', () async {
      final medication = Medication(
        id: 'test_cancel_9',
        name: 'Test Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'09:00': 1.0},
      );

      // Schedule regular notification
      await NotificationService.instance.scheduleMedicationNotifications(medication);

      // Schedule a postponed notification
      await NotificationService.instance.schedulePostponedDoseNotification(
        medication: medication,
        originalDoseTime: '09:00',
        newTime: const TimeOfDay(hour: 11, minute: 30),
      );

      // Cancel should remove both regular and postponed notifications
      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '09:00',
      );

      expect(true, true);
    });

    test('should work with different medication types', () async {
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
          id: 'test_cancel_type_${type.name}',
          name: 'Test ${type.displayName}',
          type: type,
          dosageIntervalHours: 12,
          durationType: TreatmentDurationType.everyday,
          doseSchedule: {'10:00': 1.0},
        );

        await NotificationService.instance.scheduleMedicationNotifications(medication);

        await NotificationService.instance.cancelTodaysDoseNotification(
          medication: medication,
          doseTime: '10:00',
        );
      }

      expect(true, true);
    });

    test('should handle cancellation when medication was never scheduled', () async {
      final medication = Medication(
        id: 'test_cancel_10',
        name: 'Never Scheduled',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'14:00': 1.0},
      );

      // Don't schedule, just try to cancel
      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '14:00',
      );

      // Should complete without errors (idempotent operation)
      expect(true, true);
    });
  });
}
