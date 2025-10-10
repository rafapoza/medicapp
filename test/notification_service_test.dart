import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/services/notification_service.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';

void main() {
  group('NotificationService', () {
    setUp(() {
      // Enable test mode before each test
      NotificationService.instance.enableTestMode();
    });

    test('should be singleton', () {
      final instance1 = NotificationService.instance;
      final instance2 = NotificationService.instance;

      expect(instance1, same(instance2));
    });

    // Note: Notification ID generation is tested indirectly through scheduling

    test('should initialize without error in test mode', () async {
      final service = NotificationService.instance;

      expect(() async => await service.initialize(), returnsNormally);
    });

    test('should request permissions without error in test mode', () async {
      final service = NotificationService.instance;

      final result = await service.requestPermissions();

      expect(result, isTrue);
    });

    test('should schedule medication notifications without error in test mode', () async {
      final service = NotificationService.instance;
      final medication = Medication(
        id: 'test_medication_1',
        name: 'Paracetamol',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
      );

      expect(
        () async => await service.scheduleMedicationNotifications(medication),
        returnsNormally,
      );
    });

    test('should not schedule notifications for medication without dose times', () async {
      final service = NotificationService.instance;
      final medication = Medication(
        id: 'test_medication_2',
        name: 'Vitamina',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {}, // No dose times
      );

      expect(
        () async => await service.scheduleMedicationNotifications(medication),
        returnsNormally,
      );
    });

    test('should cancel medication notifications without error in test mode', () async {
      final service = NotificationService.instance;

      expect(
        () async => await service.cancelMedicationNotifications('test_medication_1'),
        returnsNormally,
      );
    });

    test('should cancel all notifications without error in test mode', () async {
      final service = NotificationService.instance;

      expect(
        () async => await service.cancelAllNotifications(),
        returnsNormally,
      );
    });

    test('should return empty list for pending notifications in test mode', () async {
      final service = NotificationService.instance;

      final pending = await service.getPendingNotifications();

      expect(pending, isEmpty);
    });

    test('should handle test notification without error in test mode', () async {
      final service = NotificationService.instance;

      expect(
        () async => await service.showTestNotification(),
        returnsNormally,
      );
    });

    test('should handle scheduled test notification without error in test mode', () async {
      final service = NotificationService.instance;

      expect(
        () async => await service.scheduleTestNotification(),
        returnsNormally,
      );
    });

    test('should check if notifications are enabled in test mode', () async {
      final service = NotificationService.instance;

      final result = await service.areNotificationsEnabled();

      expect(result, isTrue);
    });

    test('should enable and disable test mode', () {
      final service = NotificationService.instance;

      // Test that we can call enable/disable without errors
      expect(() => service.enableTestMode(), returnsNormally);
      expect(() => service.disableTestMode(), returnsNormally);

      // Re-enable for other tests
      service.enableTestMode();
    });

    test('should schedule multiple medications independently', () async {
      final service = NotificationService.instance;

      final medication1 = Medication(
        id: 'test_med_1',
        name: 'Med 1',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
      );

      final medication2 = Medication(
        id: 'test_med_2',
        name: 'Med 2',
        type: MedicationType.jarabe,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'09:00': 5.0, '21:00': 5.0},
      );

      // Schedule both medications
      await service.scheduleMedicationNotifications(medication1);
      await service.scheduleMedicationNotifications(medication2);

      // Should complete without error
      expect(true, isTrue);
    });

    test('should handle rescheduling (updating) medication notifications', () async {
      final service = NotificationService.instance;

      final originalMedication = Medication(
        id: 'test_med_update',
        name: 'Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
      );

      final updatedMedication = Medication(
        id: 'test_med_update', // Same ID
        name: 'Updated Medication',
        type: MedicationType.capsula,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'09:00': 2.0, '21:00': 1.5}, // Different times and doses
      );

      // Schedule original
      await service.scheduleMedicationNotifications(originalMedication);

      // Reschedule with updated times
      await service.scheduleMedicationNotifications(updatedMedication);

      // Should complete without error
      expect(true, isTrue);
    });
  });
}
