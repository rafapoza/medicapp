import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/medication_builder.dart';

void main() {
  group('As-Needed Medications - Stock Management', () {
    test('isStockLow should return false when lastDailyConsumption is null', () {
      final medication = MedicationBuilder()
          .withId('test_1')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(10.0)
          .build();

      expect(medication.isStockLow, isFalse);
    });

    test('isStockLow should return false when lastDailyConsumption is zero', () {
      final medication = MedicationBuilder()
          .withId('test_2')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(10.0)
          .withLastDailyConsumption(0.0)
          .build();

      expect(medication.isStockLow, isFalse);
    });

    test('isStockLow should calculate correctly based on lastDailyConsumption', () {
      // Stock: 10 pills
      // Last day consumption: 4 pills
      // Days remaining: 10 / 4 = 2.5 days
      // Threshold: 3 days
      // Should be LOW since 2.5 < 3
      final medication = MedicationBuilder()
          .withId('test_3')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(10.0)
          .withLastDailyConsumption(4.0)
          .build();

      expect(medication.isStockLow, isTrue);
    });

    test('isStockLow should return false when stock is above threshold', () {
      // Stock: 20 pills
      // Last day consumption: 3 pills
      // Days remaining: 20 / 3 = 6.67 days
      // Threshold: 3 days
      // Should NOT be low since 6.67 >= 3
      final medication = MedicationBuilder()
          .withId('test_4')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(20.0)
          .withLastDailyConsumption(3.0)
          .build();

      expect(medication.isStockLow, isFalse);
    });

    test('isStockLow should handle exactly at threshold boundary', () {
      // Stock: 9 pills
      // Last day consumption: 3 pills
      // Days remaining: 9 / 3 = 3.0 days exactly
      // Threshold: 3 days
      // Should NOT be low since 3.0 >= 3
      final medication = MedicationBuilder()
          .withId('test_5')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(9.0)
          .withLastDailyConsumption(3.0)
          .build();

      expect(medication.isStockLow, isFalse);
    });

    test('isStockLow should handle just below threshold boundary', () {
      // Stock: 8.9 pills
      // Last day consumption: 3 pills
      // Days remaining: 8.9 / 3 = 2.97 days
      // Threshold: 3 days
      // Should be LOW since 2.97 < 3
      final medication = MedicationBuilder()
          .withId('test_6')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(8.9)
          .withLastDailyConsumption(3.0)
          .build();

      expect(medication.isStockLow, isTrue);
    });

    test('isStockLow should respect custom threshold days', () {
      // Stock: 40 pills
      // Last day consumption: 2 pills
      // Days remaining: 40 / 2 = 20 days
      // Threshold: 30 days (custom high threshold)
      // Should be LOW since 20 < 30
      final medication = MedicationBuilder()
          .withId('test_7')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(40.0)
          .withLowStockThreshold(30)
          .withLastDailyConsumption(2.0)
          .build();

      expect(medication.isStockLow, isTrue);
    });

    test('isStockLow should work with decimal consumption values', () {
      // Stock: 5.5 ml
      // Last day consumption: 1.5 ml
      // Days remaining: 5.5 / 1.5 = 3.67 days
      // Threshold: 3 days
      // Should NOT be low since 3.67 >= 3
      final medication = MedicationBuilder()
          .withId('test_8')
          .withName('Jarabe')
          .withType(MedicationType.jarabe)
          .withAsNeeded()
          .withStock(5.5)
          .withLastDailyConsumption(1.5)
          .build();

      expect(medication.isStockLow, isFalse);
    });

    test('isStockLow should return false when stock is zero (empty, not low)', () {
      final medication = MedicationBuilder()
          .withId('test_9')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(0.0)
          .withLastDailyConsumption(2.0)
          .build();

      // Stock is 0, so it's empty, not "low"
      // The getter should return false (use isStockEmpty for this case)
      expect(medication.isStockLow, isFalse);
      expect(medication.isStockEmpty, isTrue);
    });

    test('scheduled medication should still use old logic (not affected)', () {
      // Stock: 8 pills
      // Dose schedule: 3 doses/day * 1.0 pill = 3.0 pills/day
      // Days remaining: 8 / 3 = 2.67 days
      // Threshold: 3 days
      // Should be LOW since 2.67 < 3
      final medication = MedicationBuilder()
          .withId('test_10')
          .withName('Atorvastatina')
          .withDosageInterval(8)
          .withDurationType(TreatmentDurationType.everyday)
          .withDoseSchedule({'08:00': 1.0, '16:00': 1.0, '00:00': 1.0})
          .withStock(8.0)
          .build();

      expect(medication.isStockLow, isTrue);
    });
  });

  group('As-Needed Medications - Serialization', () {
    test('should serialize and deserialize lastDailyConsumption', () {
      final medication = MedicationBuilder()
          .withId('test_11')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(20.0)
          .withLastDailyConsumption(3.5)
          .build();

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.lastDailyConsumption, 3.5);
    });

    test('should handle null lastDailyConsumption in serialization', () {
      final medication = MedicationBuilder()
          .withId('test_12')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.lastDailyConsumption, isNull);
    });

    test('fromJson should handle missing lastDailyConsumption field (legacy data)', () {
      final json = {
        'id': 'test_13',
        'name': 'Ibuprofeno',
        'type': 'pastilla',
        'dosageIntervalHours': 0,
        'durationType': 'asNeeded',
        'doseTimes': '',
        'doseSchedule': '{}',
        'stockQuantity': 20,
        'takenDosesToday': '',
        'skippedDosesToday': '',
        // lastDailyConsumption not present (legacy data)
      };

      final medication = Medication.fromJson(json);

      expect(medication.lastDailyConsumption, isNull);
    });
  });

  group('As-Needed Medications - Integration with other features', () {
    test('should handle as-needed medication with all fields', () {
      final medication = MedicationBuilder()
          .withId('test_14')
          .withName('Ibuprofeno 400mg')
          .withAsNeeded()
          .withStock(24.0)
          .withLowStockThreshold(5)
          .withLastDailyConsumption(2.5)
          .withLastRefill(30.0)
          .build();

      expect(medication.durationType, TreatmentDurationType.asNeeded);
      expect(medication.lastDailyConsumption, 2.5);
      expect(medication.lastRefillAmount, 30.0);

      // Days remaining: 24 / 2.5 = 9.6 days
      // Threshold: 5 days
      // Should NOT be low since 9.6 >= 5
      expect(medication.isStockLow, isFalse);
    });

    test('should work correctly with different medication types', () {
      final medications = [
        MedicationBuilder()
            .withId('test_15_a')
            .withName('Ibuprofeno')
            .withType(MedicationType.pastilla)
            .withAsNeeded()
            .withStock(10.0)
            .withLastDailyConsumption(4.0) // 2.5 days remaining < 3
            .build(),
        MedicationBuilder()
            .withId('test_15_b')
            .withName('Jarabe para la tos')
            .withType(MedicationType.jarabe)
            .withAsNeeded()
            .withStock(100.0)
            .withLastDailyConsumption(15.0) // 6.67 days remaining >= 3
            .build(),
        MedicationBuilder()
            .withId('test_15_c')
            .withName('Spray nasal')
            .withType(MedicationType.spray)
            .withAsNeeded()
            .withStock(20.0)
            .withLastDailyConsumption(8.0) // 2.5 days remaining < 3
            .build(),
      ];

      expect(medications[0].isStockLow, isTrue);  // Pills
      expect(medications[1].isStockLow, isFalse); // Jarabe
      expect(medications[2].isStockLow, isTrue);  // Spray
    });
  });
}
