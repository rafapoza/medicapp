import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/medication_builder.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('Medication Model - Skipped Doses', () {
    test('should create medication with skippedDosesToday', () {
      final medication = MedicationBuilder()
          .withId('test_1')
          .withDoseSchedule({'08:00': 1.0, '16:00': 1.0, '00:00': 1.0})
          .withSkippedDoses(['08:00'], '2025-10-10')
          .withTakenDoses(['16:00'], '2025-10-10')
          .build();

      expect(medication.skippedDosesToday, ['08:00']);
      expect(medication.takenDosesToday, ['16:00']);
    });

    test('should serialize and deserialize skippedDosesToday', () {
      final medication = MedicationBuilder()
          .withId('test_2')
          .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
          .withSkippedDoses(['08:00', '16:00'], '2025-10-10')
          .withTakenDoses(['00:00'], '2025-10-10')
          .build();

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.skippedDosesToday, ['08:00', '16:00']);
      expect(deserialized.takenDosesToday, ['00:00']);
      expect(deserialized.takenDosesDate, '2025-10-10');
    });

    test('should handle empty skippedDosesToday', () {
      final medication = MedicationBuilder()
          .withId('test_3')
          .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
          .build();

      expect(medication.skippedDosesToday, isEmpty);
      expect(medication.takenDosesToday, isEmpty);
    });

    test('getAvailableDosesToday should exclude both taken and skipped doses', () {
      final medication = MedicationBuilder()
          .withId('test_4')
          .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
          .withTakenDoses(['08:00'], getTodayString())
          .withSkippedDoses(['16:00'], getTodayString())
          .build();

      final available = medication.getAvailableDosesToday();

      expect(available.length, 1);
      expect(available, contains('00:00'));
      expect(available, isNot(contains('08:00'))); // taken
      expect(available, isNot(contains('16:00'))); // skipped
    });

    test('getAvailableDosesToday should return all doses for new day', () {
      final medication = MedicationBuilder()
          .withId('test_5')
          .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
          .withTakenDoses(['08:00'], '2025-01-01')
          .withSkippedDoses(['16:00'], '2025-01-01')
          .build();

      final available = medication.getAvailableDosesToday();

      expect(available.length, 3);
      expect(available, containsAll(['08:00', '16:00', '00:00']));
    });

    test('getAvailableDosesToday should return empty when all doses are taken or skipped', () {
      final todayString = getTodayString();

      final medication = MedicationBuilder()
          .withId('test_6')
          .withName('Test Medication')
          .withDosageInterval(12)
          .withMultipleDoses(['08:00', '20:00'], 1.0)
          .withTakenDoses(['08:00'], todayString)
          .withSkippedDoses(['20:00'], todayString)
          .build();

      final available = medication.getAvailableDosesToday();

      expect(available, isEmpty);
    });

    test('should handle only skipped doses (no taken doses)', () {
      final todayString = getTodayString();

      final medication = MedicationBuilder()
          .withId('test_7')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
          .withSkippedDoses(['08:00', '16:00'], todayString)
          .build();

      final available = medication.getAvailableDosesToday();

      expect(available.length, 1);
      expect(available, contains('00:00'));
    });

    test('should handle only taken doses (no skipped doses)', () {
      final todayString = getTodayString();

      final medication = MedicationBuilder()
          .withId('test_8')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
          .withTakenDoses(['08:00', '16:00'], todayString)
          .build();

      final available = medication.getAvailableDosesToday();

      expect(available.length, 1);
      expect(available, contains('00:00'));
    });

    test('toJson should include skippedDosesToday as comma-separated string', () {
      final medication = MedicationBuilder()
          .withId('test_9')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withSkippedDoses(['08:00', '16:00'], getTodayString())
          .build();

      final json = medication.toJson();

      expect(json['skippedDosesToday'], '08:00,16:00');
    });

    test('fromJson should parse empty skippedDosesToday string', () {
      final json = {
        'id': 'test_10',
        'name': 'Test Medication',
        'type': 'pastilla',
        'dosageIntervalHours': 8,
        'durationType': 'everyday',
        'doseTimes': '08:00,16:00',
        'doseSchedule': '{"08:00": 1.0, "16:00": 1.0}',
        'stockQuantity': 10,
        'takenDosesToday': '',
        'skippedDosesToday': '',
      };

      final medication = Medication.fromJson(json);

      expect(medication.takenDosesToday, isEmpty);
      expect(medication.skippedDosesToday, isEmpty);
    });

    test('fromJson should handle missing skippedDosesToday field (legacy data)', () {
      final json = {
        'id': 'test_11',
        'name': 'Test Medication',
        'type': 'pastilla',
        'dosageIntervalHours': 8,
        'durationType': 'everyday',
        'doseTimes': '08:00,16:00',
        'doseSchedule': '{"08:00": 1.0, "16:00": 1.0}',
        'stockQuantity': 10,
        'takenDosesToday': '08:00',
        // skippedDosesToday not present (legacy data)
      };

      final medication = Medication.fromJson(json);

      expect(medication.takenDosesToday, ['08:00']);
      expect(medication.skippedDosesToday, isEmpty);
    });
  });

  group('Medication Model - Stock and Doses', () {
    test('totalDailyDose should sum all doses', () {
      final medication = MedicationBuilder()
          .withId('test_12')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withDoseSchedule({'08:00': 1.5, '16:00': 2.0, '00:00': 1.0})
          .build();

      expect(medication.totalDailyDose, 4.5);
    });

    test('isStockLow should consider skipped doses do not affect stock', () {
      // Stock is low if less than 3 days worth
      // 3 doses/day * 1.0 per dose = 3.0 per day
      // 3 days = 9.0 total needed
      final medication = MedicationBuilder()
          .withId('test_13')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00', '00:00'], 1.0)
          .withStock(8.0) // Less than 9.0
          .build();

      expect(medication.isStockLow, isTrue);
    });
  });

  group('Medication Model - Refill', () {
    test('should create medication with lastRefillAmount', () {
      final medication = MedicationBuilder()
          .withId('test_14')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .withLastRefill(30.0)
          .build();

      expect(medication.lastRefillAmount, 30.0);
    });

    test('should handle null lastRefillAmount', () {
      final medication = MedicationBuilder()
          .withId('test_15')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .build();

      expect(medication.lastRefillAmount, isNull);
    });

    test('should serialize and deserialize lastRefillAmount', () {
      final medication = MedicationBuilder()
          .withId('test_16')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .withLastRefill(50.0)
          .build();

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.lastRefillAmount, 50.0);
    });

    test('should handle null lastRefillAmount in serialization', () {
      final medication = MedicationBuilder()
          .withId('test_17')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .build();

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.lastRefillAmount, isNull);
    });

    test('should update lastRefillAmount when refilling', () {
      final medication = MedicationBuilder()
          .withId('test_18')
          .withName('Test Medication')
          .withDosageInterval(8)
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .withLastRefill(30.0)
          .build();

      // Simulate refill with new amount
      final refillAmount = 40.0;
      final updatedMedication = MedicationBuilder.from(medication)
          .withStock(medication.stockQuantity + refillAmount)
          .withLastRefill(refillAmount)
          .build();

      expect(updatedMedication.stockQuantity, 50.0);
      expect(updatedMedication.lastRefillAmount, 40.0);
    });

    test('fromJson should handle missing lastRefillAmount field (legacy data)', () {
      final json = {
        'id': 'test_19',
        'name': 'Test Medication',
        'type': 'pastilla',
        'dosageIntervalHours': 8,
        'durationType': 'everyday',
        'doseTimes': '08:00,16:00',
        'doseSchedule': '{"08:00": 1.0, "16:00": 1.0}',
        'stockQuantity': 10,
        'takenDosesToday': '',
        'skippedDosesToday': '',
        // lastRefillAmount not present (legacy data)
      };

      final medication = Medication.fromJson(json);

      expect(medication.lastRefillAmount, isNull);
    });
  });
}
