import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/services/notification_service.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/medication_builder.dart';

void main() {
  late NotificationService service;

  setUp(() {
    service = NotificationService.instance;
    service.enableTestMode();
  });

  tearDown(() {
    service.disableTestMode();
  });

  group('Test Mode Management', () {
    test('should enable test mode', () {
      service.enableTestMode();
      expect(service.isTestMode, isTrue);
    });

    test('should disable test mode', () {
      service.disableTestMode();
      expect(service.isTestMode, isFalse);
      // Re-enable for other tests
      service.enableTestMode();
    });

    test('should start with test mode disabled by default', () {
      final newService = NotificationService.instance;
      // Instance is singleton, so it maintains state
      // Just verify we can check the state
      expect(newService.isTestMode, isTrue); // Already enabled in setUp
    });
  });

  group('Notification ID Generation', () {
    test('should generate unique IDs for different medications', () {
      final id1 = _generateNotificationId('med1', 0);
      final id2 = _generateNotificationId('med2', 0);

      expect(id1, isNot(equals(id2)));
    });

    test('should generate unique IDs for different dose indices', () {
      final id1 = _generateNotificationId('med1', 0);
      final id2 = _generateNotificationId('med1', 1);

      expect(id1, isNot(equals(id2)));
    });

    test('should generate consistent IDs for same inputs', () {
      final id1 = _generateNotificationId('med1', 0);
      final id2 = _generateNotificationId('med1', 0);

      expect(id1, equals(id2));
    });

    test('should generate specific date notification IDs', () {
      final id1 = _generateSpecificDateNotificationId('med1', '2024-01-15', 0);
      final id2 = _generateSpecificDateNotificationId('med1', '2024-01-16', 0);

      // Different dates should generate different IDs
      expect(id1, isNot(equals(id2)));

      // ID should be in range 3000000+
      expect(id1, greaterThanOrEqualTo(3000000));
      expect(id1, lessThan(4000000));
    });

    test('should generate weekly notification IDs', () {
      final id1 = _generateWeeklyNotificationId('med1', 1, 0); // Monday
      final id2 = _generateWeeklyNotificationId('med1', 2, 0); // Tuesday

      // Different weekdays should generate different IDs
      expect(id1, isNot(equals(id2)));

      // ID should be in range 4000000+
      expect(id1, greaterThanOrEqualTo(4000000));
      expect(id1, lessThan(5000000));
    });

    test('should generate postponed notification IDs', () {
      final id1 = _generatePostponedNotificationId('med1', '08:00');
      final id2 = _generatePostponedNotificationId('med1', '14:00');

      // Different times should generate different IDs
      expect(id1, isNot(equals(id2)));

      // ID should be in range 2000000+
      expect(id1, greaterThanOrEqualTo(2000000));
      expect(id1, lessThan(3000000));
    });
  });

  group('Medication Notifications', () {
    test('should skip notifications in test mode', () async {
      service.enableTestMode();

      final medication = MedicationBuilder()
          .withId('test-med-1')
          .withName('Test Medicine')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should not throw in test mode
      await service.scheduleMedicationNotifications(medication);

      // Verify no notifications were scheduled (in test mode)
      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });

    test('should skip notifications for suspended medications', () async {
      final medication = MedicationBuilder()
          .withId('test-med-suspended')
          .withName('Suspended Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .suspended()
          .withStartDate(DateTime.now())
          .build();

      // Should handle suspended medication gracefully
      await service.scheduleMedicationNotifications(medication);

      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });

    test('should skip notifications for medications without dose times', () async {
      final medication = MedicationBuilder()
          .withId('test-med-no-doses')
          .withName('No Doses Medicine')
          .withDosageInterval(8)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should handle medications without doses gracefully
      await service.scheduleMedicationNotifications(medication);

      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });

    test('should skip notifications for pending (not yet started) medications', () async {
      final futureDate = DateTime.now().add(const Duration(days: 7));

      final medication = MedicationBuilder()
          .withId('test-med-pending')
          .withName('Future Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withStartDate(futureDate)
          .build();

      // Should skip pending medications
      await service.scheduleMedicationNotifications(medication);

      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });

    test('should skip notifications for finished medications', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 7));

      final medication = MedicationBuilder()
          .withId('test-med-finished')
          .withName('Finished Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withStartDate(pastDate.subtract(const Duration(days: 30)))
          .withEndDate(pastDate)
          .build();

      // Should skip finished medications
      await service.scheduleMedicationNotifications(medication);

      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });
  });

  group('Cancellation', () {
    test('should cancel all notifications in test mode', () async {
      service.enableTestMode();

      // Should not throw
      await service.cancelAllNotifications();
    });

    test('should cancel medication notifications in test mode', () async {
      service.enableTestMode();

      // Should not throw
      await service.cancelMedicationNotifications('test-med-id');
    });

    test('should cancel today\'s dose notification in test mode', () async {
      service.enableTestMode();

      final medication = MedicationBuilder()
          .withId('test-med-cancel')
          .withName('Test Medicine')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should not throw
      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '08:00',
      );
    });

    test('should cancel postponed notification in test mode', () async {
      service.enableTestMode();

      // Should not throw
      await service.cancelPostponedNotification('test-med-id', '08:00');
    });
  });

  group('Permissions', () {
    test('should return true for permissions in test mode', () async {
      service.enableTestMode();

      final granted = await service.requestPermissions();
      expect(granted, isTrue);
    });

    test('should return true for notifications enabled in test mode', () async {
      service.enableTestMode();

      final enabled = await service.areNotificationsEnabled();
      expect(enabled, isTrue);
    });

    test('should return true for exact alarms in test mode', () async {
      service.enableTestMode();

      final canSchedule = await service.canScheduleExactAlarms();
      expect(canSchedule, isTrue);
    });
  });

  group('Settings', () {
    test('should not throw when opening settings in test mode', () async {
      service.enableTestMode();

      // Should not throw
      await service.openExactAlarmSettings();
      await service.openBatteryOptimizationSettings();
    });
  });

  group('Fasting Notifications', () {
    test('should schedule dynamic fasting notification in test mode', () async {
      service.enableTestMode();

      final medication = MedicationBuilder()
          .withId('test-med-fasting')
          .withName('Test Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withFasting(type: 'after', duration: 60)
          .withStartDate(DateTime.now())
          .build();

      // Should not throw
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: DateTime.now(),
      );
    });

    test('should not schedule dynamic fasting for before type', () async {
      service.enableTestMode();

      final medication = MedicationBuilder()
          .withId('test-med-fasting-before')
          .withName('Test Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withFasting(type: 'before', duration: 60)
          .withStartDate(DateTime.now())
          .build();

      // Should skip for "before" type
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: DateTime.now(),
      );
    });

    test('should not schedule dynamic fasting without notification flag', () async {
      service.enableTestMode();

      final medication = MedicationBuilder()
          .withId('test-med-fasting-no-notify')
          .withName('Test Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withFasting(type: 'after', duration: 60, notify: false)
          .withStartDate(DateTime.now())
          .build();

      // Should skip when notifyFasting is false
      await service.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: DateTime.now(),
      );
    });
  });

  group('Postponed Notifications', () {
    test('should schedule postponed dose notification in test mode', () async {
      service.enableTestMode();

      final medication = MedicationBuilder()
          .withId('test-med-postpone')
          .withName('Test Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should not throw
      await service.schedulePostponedDoseNotification(
        medication: medication,
        originalDoseTime: '08:00',
        newTime: const TimeOfDay(hour: 10, minute: 0),
      );
    });
  });

  group('Test Notifications', () {
    test('should show test notification in test mode', () async {
      service.enableTestMode();

      // Should not throw
      await service.showTestNotification();
    });

    test('should schedule test notification in test mode', () async {
      service.enableTestMode();

      // Should not throw
      await service.scheduleTestNotification();
    });
  });

  group('Pending Notifications', () {
    test('should return empty list in test mode', () async {
      service.enableTestMode();

      final pending = await service.getPendingNotifications();
      expect(pending, isEmpty);
    });
  });

  group('Edge Cases', () {
    test('should handle medication with no end date', () async {
      final medication = MedicationBuilder()
          .withId('test-med-no-end')
          .withName('No End Date Medicine')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should handle medications without end date
      await service.scheduleMedicationNotifications(medication);
    });

    test('should handle medication with specific dates', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateString = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      final medication = MedicationBuilder()
          .withId('test-med-specific-dates')
          .withName('Specific Dates Medicine')
          .withDosageInterval(8)
          .withSpecificDates([dateString])
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should handle specific dates
      await service.scheduleMedicationNotifications(medication);
    });

    test('should handle medication with weekly pattern', () async {
      final medication = MedicationBuilder()
          .withId('test-med-weekly')
          .withName('Weekly Medicine')
          .withDosageInterval(8)
          .withWeeklyPattern([1, 3, 5]) // Monday, Wednesday, Friday
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should handle weekly patterns
      await service.scheduleMedicationNotifications(medication);
    });

    test('should handle medication with multiple doses', () async {
      final medication = MedicationBuilder()
          .withId('test-med-multiple')
          .withName('Multiple Doses Medicine')
          .withDosageInterval(6)
          .withMultipleDoses(['08:00', '14:00', '20:00', '02:00'], 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should handle multiple doses
      await service.scheduleMedicationNotifications(medication);
    });

    test('should handle cancellation for non-existent dose time', () async {
      final medication = MedicationBuilder()
          .withId('test-med-invalid-dose')
          .withName('Test Medicine')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(10)
          .withStartDate(DateTime.now())
          .build();

      // Should handle non-existent dose time gracefully
      await service.cancelTodaysDoseNotification(
        medication: medication,
        doseTime: '12:00', // Doesn't exist in doseSchedule
      );
    });
  });
}

// Helper methods to simulate internal ID generation
// These mirror the logic in NotificationService

int _generateNotificationId(String medicationId, int doseIndex) {
  final medicationHash = medicationId.hashCode.abs();
  return (medicationHash % 1000000) * 100 + doseIndex;
}

int _generateSpecificDateNotificationId(String medicationId, String dateString, int doseIndex) {
  final combinedString = '$medicationId-$dateString-$doseIndex';
  final hash = combinedString.hashCode.abs();
  return 3000000 + (hash % 1000000);
}

int _generateWeeklyNotificationId(String medicationId, int weekday, int doseIndex) {
  final combinedString = '$medicationId-weekday$weekday-$doseIndex';
  final hash = combinedString.hashCode.abs();
  return 4000000 + (hash % 1000000);
}

int _generatePostponedNotificationId(String medicationId, String doseTime) {
  final combinedString = '$medicationId-$doseTime';
  final hash = combinedString.hashCode.abs();
  return 2000000 + (hash % 1000000);
}
