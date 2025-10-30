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

  group('Extra Dose Registration', () {
    test('should save extra dose to history with isExtraDose=true', () async {
      final medication = MedicationBuilder()
          .withId('med2')
          .withSingleDose('08:00', 1.0)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // Get history entries
      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med2');

      expect(history.length, 1);
      expect(history.first.isExtraDose, true);
      expect(history.first.status, DoseStatus.taken);
      expect(history.first.quantity, 1.0);
    });

    test('should not affect takenDosesToday when registering extra dose', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = MedicationBuilder()
          .withId('med3')
          .withMultipleDoses(['08:00', '14:00'], 1.0)
          .withStock(10.0)
          .withTakenDoses(['08:00'], todayString)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // takenDosesToday should remain unchanged
      expect(updatedMed.takenDosesToday, ['08:00']);
      // extraDosesToday should have one entry
      expect(updatedMed.extraDosesToday.length, 1);
    });

    test('should handle multiple extra doses in same day', () async {
      final medication = MedicationBuilder()
          .withId('med4')
          .withSingleDose('08:00', 1.0)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Register first extra dose
      var updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      expect(updatedMed.extraDosesToday.length, 1);
      expect(updatedMed.stockQuantity, 9.0);

      // Register second extra dose
      updatedMed = await DoseActionService.registerExtraDose(
        medication: updatedMed,
        quantity: 1.0,
      );

      expect(updatedMed.extraDosesToday.length, 2);
      expect(updatedMed.stockQuantity, 8.0);
    });

    test('should reset extraDosesToday on new day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      final baseMed = MedicationBuilder()
          .withId('med6')
          .withSingleDose('08:00', 1.0)
          .withStock(10.0)
          .withTakenDoses(['08:00'], yesterdayString)
          .build();

      // Create medication with extraDosesToday from yesterday
      final medication = MedicationBuilder.from(baseMed)
          .withExtraDoses(['10:30', '15:45'], yesterdayString)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Register extra dose today
      final updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // Should reset old extra doses and start fresh
      expect(updatedMed.extraDosesToday.length, 1);
      // Should also reset takenDosesToday
      expect(updatedMed.takenDosesToday.length, 0);
    });
  });

  group('Extra Dose with Different Quantities', () {
    test('should handle fractional and larger dose quantities', () async {
      // Test fractional quantity (0.5)
      final medication1 = MedicationBuilder()
          .withId('med10')
          .withSingleDose('08:00', 0.5)
          .withStock(10.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication1);

      final updatedMed1 = await DoseActionService.registerExtraDose(
        medication: medication1,
        quantity: 0.5,
      );

      expect(updatedMed1.stockQuantity, 9.5);

      // Test larger quantity (3.0)
      final medication2 = MedicationBuilder()
          .withId('med11')
          .withSingleDose('08:00', 3.0)
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication2);

      final updatedMed2 = await DoseActionService.registerExtraDose(
        medication: medication2,
        quantity: 3.0,
      );

      expect(updatedMed2.stockQuantity, 17.0);
    });
  });
}
