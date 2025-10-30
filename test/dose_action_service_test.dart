import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/models/dose_history_entry.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/dose_action_service.dart';
import 'package:medicapp/services/notification_service.dart';
import 'helpers/database_test_helper.dart';
import 'helpers/medication_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DatabaseTestHelper.setup();

  setUp(() {
    NotificationService.instance.enableTestMode();
  });

  group('DoseActionService - registerTakenDose', () {
    test('should register taken dose and reduce stock', () async {
      final medication = MedicationBuilder()
          .withId('med1')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerTakenDose(
        medication: medication,
        doseTime: '08:00',
      );

      expect(updatedMed.stockQuantity, 9.0);
      expect(updatedMed.takenDosesToday, ['08:00']);
      expect(updatedMed.takenDosesDate, isNotNull);
    });

    test('should throw InsufficientStockException when stock is too low', () async {
      final medication = MedicationBuilder()
          .withId('med2')
          .withSingleDose('08:00', 2.0)
          .withStock(1.0) // Not enough for dose of 2.0
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      expect(
        () => DoseActionService.registerTakenDose(
          medication: medication,
          doseTime: '08:00',
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('should create history entry for taken dose', () async {
      final medication = MedicationBuilder()
          .withId('med3')
          .withName('Test Med')
          .withSingleDose('08:00', 1.5)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerTakenDose(
        medication: medication,
        doseTime: '08:00',
      );

      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med3');
      expect(history.length, 1);
      expect(history.first.status, DoseStatus.taken);
      expect(history.first.quantity, 1.5);
      expect(history.first.medicationName, 'Test Med');
    });

    test('should handle multiple doses in same day', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = MedicationBuilder()
          .withId('med4')
          .withDoseSchedule({'08:00': 1.0, '16:00': 1.0, '22:00': 1.0})
          .withStock(10.0)
          .withTakenDoses(['08:00'], todayString)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerTakenDose(
        medication: medication,
        doseTime: '16:00',
      );

      expect(updatedMed.takenDosesToday, ['08:00', '16:00']);
      expect(updatedMed.stockQuantity, 9.0);
    });

    test('should reset doses when registering on new day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      final medication = MedicationBuilder()
          .withId('med5')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .withTakenDoses(['08:00', '16:00'], yesterdayString)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerTakenDose(
        medication: medication,
        doseTime: '08:00',
      );

      expect(updatedMed.takenDosesToday, ['08:00']); // Reset to just new dose
      expect(updatedMed.skippedDosesToday, isEmpty); // Reset skipped too
    });

    test('should handle fractional dose quantities', () async {
      final medication = MedicationBuilder()
          .withId('med6')
          .withMultipleDoses(['08:00', '20:00'], 0.5)
          .withStock(5.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerTakenDose(
        medication: medication,
        doseTime: '08:00',
      );

      expect(updatedMed.stockQuantity, 4.5);
    });

    test('should persist changes to database', () async {
      final medication = MedicationBuilder()
          .withId('med7')
          .withSingleDose('08:00', 1.0)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerTakenDose(
        medication: medication,
        doseTime: '08:00',
      );

      // Reload from database
      final reloadedMed = await DatabaseHelper.instance.getMedication('med7');
      expect(reloadedMed!.stockQuantity, 9.0);
      expect(reloadedMed.takenDosesToday, ['08:00']);
    });
  });

  group('DoseActionService - registerSkippedDose', () {
    test('should register skipped dose without reducing stock', () async {
      final medication = MedicationBuilder()
          .withId('med8')
          .withDoseSchedule({'08:00': 1.0, '16:00': 1.0})
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerSkippedDose(
        medication: medication,
        doseTime: '08:00',
      );

      expect(updatedMed.stockQuantity, 10.0); // Stock unchanged
      expect(updatedMed.skippedDosesToday, ['08:00']);
      expect(updatedMed.takenDosesToday, isEmpty);
    });

    test('should create history entry for skipped dose', () async {
      final medication = MedicationBuilder()
          .withId('med9')
          .withSingleDose('08:00', 1.0)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerSkippedDose(
        medication: medication,
        doseTime: '08:00',
      );

      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med9');
      expect(history.length, 1);
      expect(history.first.status, DoseStatus.skipped);
      expect(history.first.quantity, 1.0);
    });

    test('should handle multiple skipped doses in same day', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = MedicationBuilder()
          .withId('med10')
          .withMultipleDoses(['08:00', '16:00', '22:00'], 1.0)
          .withStock(10.0)
          .withSkippedDoses(['08:00'], todayString)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerSkippedDose(
        medication: medication,
        doseTime: '16:00',
      );

      expect(updatedMed.skippedDosesToday, ['08:00', '16:00']);
    });

    test('should reset doses when skipping on new day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      final medication = MedicationBuilder()
          .withId('med11')
          .withSingleDose('08:00', 1.0)
          .withStock(10.0)
          .withTakenDoses(['08:00'], yesterdayString)
          .withSkippedDoses(['16:00'], yesterdayString)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerSkippedDose(
        medication: medication,
        doseTime: '08:00',
      );

      expect(updatedMed.skippedDosesToday, ['08:00']); // Reset to just new dose
      expect(updatedMed.takenDosesToday, isEmpty); // Reset taken too
    });

    test('should persist changes to database', () async {
      final medication = MedicationBuilder()
          .withId('med12')
          .withSingleDose('08:00', 1.0)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerSkippedDose(
        medication: medication,
        doseTime: '08:00',
      );

      final reloadedMed = await DatabaseHelper.instance.getMedication('med12');
      expect(reloadedMed!.skippedDosesToday, ['08:00']);
      expect(reloadedMed.stockQuantity, 10.0);
    });
  });

  group('DoseActionService - registerManualDose', () {
    test('should register manual dose and reduce stock', () async {
      final medication = MedicationBuilder()
          .withId('med13')
          .withAsNeeded()
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerManualDose(
        medication: medication,
        quantity: 2.0,
      );

      expect(updatedMed.stockQuantity, 8.0);
    });

    test('should throw InsufficientStockException when stock is too low', () async {
      final medication = MedicationBuilder()
          .withId('med14')
          .withAsNeeded()
          .withStock(1.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      expect(
        () => DoseActionService.registerManualDose(
          medication: medication,
          quantity: 2.0,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('should create history entry for manual dose', () async {
      final medication = MedicationBuilder()
          .withId('med15')
          .withAsNeeded()
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerManualDose(
        medication: medication,
        quantity: 1.5,
      );

      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med15');
      expect(history.length, 1);
      expect(history.first.status, DoseStatus.taken);
      expect(history.first.quantity, 1.5);
      expect(history.first.isExtraDose, false); // Manual doses are not extra doses
    });

    test('should update lastDailyConsumption when provided', () async {
      final medication = MedicationBuilder()
          .withId('med16')
          .withAsNeeded()
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerManualDose(
        medication: medication,
        quantity: 2.0,
        lastDailyConsumption: 3.5,
      );

      expect(updatedMed.lastDailyConsumption, 3.5);
    });

    test('should handle fasting "after" notifications', () async {
      final medication = MedicationBuilder()
          .withId('med17')
          .withName('Test Med with Fasting')
          .withAsNeeded()
          .withStock(10.0)
          .withFasting(type: 'after', duration: 60, notify: true)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Should not throw and should handle fasting notification scheduling
      final updatedMed = await DoseActionService.registerManualDose(
        medication: medication,
        quantity: 1.0,
      );

      expect(updatedMed.requiresFasting, true);
      expect(updatedMed.fastingType, 'after');
    });

    test('should NOT schedule fasting for "before" type', () async {
      final medication = MedicationBuilder()
          .withId('med18')
          .withAsNeeded()
          .withStock(10.0)
          .withFasting(type: 'before', duration: 60, notify: true)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerManualDose(
        medication: medication,
        quantity: 1.0,
      );

      expect(updatedMed.fastingType, 'before');
    });

    test('should handle fractional quantities', () async {
      final medication = MedicationBuilder()
          .withId('med19')
          .withAsNeeded()
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerManualDose(
        medication: medication,
        quantity: 0.25,
      );

      expect(updatedMed.stockQuantity, 9.75);
    });

    test('should persist changes to database', () async {
      final medication = MedicationBuilder()
          .withId('med20')
          .withAsNeeded()
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerManualDose(
        medication: medication,
        quantity: 2.0,
        lastDailyConsumption: 3.0,
      );

      final reloadedMed = await DatabaseHelper.instance.getMedication('med20');
      expect(reloadedMed!.stockQuantity, 8.0);
      expect(reloadedMed.lastDailyConsumption, 3.0);
    });
  });

  group('InsufficientStockException', () {
    test('should contain all required information', () {
      final exception = InsufficientStockException(
        doseQuantity: 2.0,
        availableStock: 1.0,
        unit: 'pastillas',
      );

      expect(exception.doseQuantity, 2.0);
      expect(exception.availableStock, 1.0);
      expect(exception.unit, 'pastillas');
    });

    test('should have descriptive toString', () {
      final exception = InsufficientStockException(
        doseQuantity: 2.0,
        availableStock: 1.0,
        unit: 'pastillas',
      );

      final message = exception.toString();
      expect(message, contains('2.0'));
      expect(message, contains('1.0'));
      expect(message, contains('pastillas'));
      expect(message, contains('Insufficient stock'));
    });
  });
}
