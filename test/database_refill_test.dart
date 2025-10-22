import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/medication_builder.dart';
import 'helpers/database_test_helper.dart';

void main() {
  DatabaseTestHelper.setup();

  group('Database - Refill Persistence', () {
    test('should save and retrieve lastRefillAmount from database', () async {
      final medication = MedicationBuilder()
          .withId('test_db_1')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(30.0)
          .withLastRefill(50.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final retrieved = await DatabaseHelper.instance.getMedication('test_db_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.lastRefillAmount, 50.0);
    });

    test('should save and retrieve null lastRefillAmount from database', () async {
      final medication = MedicationBuilder()
          .withId('test_db_2')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(30.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final retrieved = await DatabaseHelper.instance.getMedication('test_db_2');

      expect(retrieved, isNotNull);
      expect(retrieved!.lastRefillAmount, isNull);
    });

    test('should update lastRefillAmount in database', () async {
      final medication = MedicationBuilder()
          .withId('test_db_3')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(30.0)
          .withLastRefill(50.0)
          .build();

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate refill
      final updatedMedication = MedicationBuilder.from(medication)
          .withStock(medication.stockQuantity + 40.0) // Add 40
          .withLastRefill(40.0) // New refill amount
          .build();

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Retrieve and verify
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_3');

      expect(retrieved, isNotNull);
      expect(retrieved!.stockQuantity, 70.0);
      expect(retrieved.lastRefillAmount, 40.0);
    });

    test('should preserve lastRefillAmount when updating other fields', () async {
      final medication = MedicationBuilder()
          .withId('test_db_4')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(30.0)
          .withLastRefill(50.0)
          .build();

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Update only the name
      final updatedMedication = MedicationBuilder.from(medication)
          .withName('Updated Name')
          .build();

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Retrieve and verify
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_4');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.lastRefillAmount, 50.0); // Still preserved
    });

    test('should handle multiple medications with different lastRefillAmount', () async {
      final med1 = MedicationBuilder()
          .withId('test_db_5')
          .withName('Medication 1')
          .withDosageInterval(8)
          .withSingleDose('08:00', 1.0)
          .withStock(30.0)
          .withLastRefill(50.0)
          .build();

      final med2 = MedicationBuilder()
          .withId('test_db_6')
          .withName('Medication 2')
          .withType(MedicationType.jarabe)
          .withDosageInterval(12)
          .withSingleDose('09:00', 5.0)
          .withStock(100.0)
          .withLastRefill(200.0)
          .build();

      final med3 = MedicationBuilder()
          .withId('test_db_7')
          .withName('Medication 3')
          .withType(MedicationType.capsula)
          .withDosageInterval(24)
          .withSingleDose('08:00', 1.0)
          .withStock(15.0)
          .build(); // No lastRefill (null)

      // Insert all medications
      await DatabaseHelper.instance.insertMedication(med1);
      await DatabaseHelper.instance.insertMedication(med2);
      await DatabaseHelper.instance.insertMedication(med3);

      // Retrieve all
      final allMeds = await DatabaseHelper.instance.getAllMedications();

      expect(allMeds.length, 3);

      final retrieved1 = allMeds.firstWhere((m) => m.id == 'test_db_5');
      final retrieved2 = allMeds.firstWhere((m) => m.id == 'test_db_6');
      final retrieved3 = allMeds.firstWhere((m) => m.id == 'test_db_7');

      expect(retrieved1.lastRefillAmount, 50.0);
      expect(retrieved2.lastRefillAmount, 200.0);
      expect(retrieved3.lastRefillAmount, isNull);
    });

    test('should handle decimal lastRefillAmount values', () async {
      final medication = MedicationBuilder()
          .withId('test_db_8')
          .withName('Test Medication')
          .withType(MedicationType.jarabe)
          .withDosageInterval(8)
          .withSingleDose('08:00', 5.5)
          .withStock(100.5)
          .withLastRefill(150.75) // Decimal value
          .build();

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Retrieve medication
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_8');

      expect(retrieved, isNotNull);
      expect(retrieved!.lastRefillAmount, 150.75);
    });
  });
}
