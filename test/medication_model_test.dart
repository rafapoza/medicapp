import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';

void main() {
  group('Medication Model - Skipped Doses', () {
    test('should create medication with skippedDosesToday', () {
      final medication = Medication(
        id: 'test_1',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
        skippedDosesToday: ['08:00'],
        takenDosesToday: ['16:00'],
        takenDosesDate: '2025-10-10',
      );

      expect(medication.skippedDosesToday, ['08:00']);
      expect(medication.takenDosesToday, ['16:00']);
    });

    test('should serialize and deserialize skippedDosesToday', () {
      final medication = Medication(
        id: 'test_2',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
        skippedDosesToday: ['08:00', '16:00'],
        takenDosesToday: ['00:00'],
        takenDosesDate: '2025-10-10',
      );

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.skippedDosesToday, ['08:00', '16:00']);
      expect(deserialized.takenDosesToday, ['00:00']);
      expect(deserialized.takenDosesDate, '2025-10-10');
    });

    test('should handle empty skippedDosesToday', () {
      final medication = Medication(
        id: 'test_3',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
      );

      expect(medication.skippedDosesToday, isEmpty);
      expect(medication.takenDosesToday, isEmpty);
    });

    test('getAvailableDosesToday should exclude both taken and skipped doses', () {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'test_4',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
        takenDosesToday: ['08:00'],
        skippedDosesToday: ['16:00'],
        takenDosesDate: todayString,
      );

      final available = medication.getAvailableDosesToday();

      expect(available.length, 1);
      expect(available, contains('00:00'));
      expect(available, isNot(contains('08:00'))); // taken
      expect(available, isNot(contains('16:00'))); // skipped
    });

    test('getAvailableDosesToday should return all doses for new day', () {
      final medication = Medication(
        id: 'test_5',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
        takenDosesToday: ['08:00'],
        skippedDosesToday: ['16:00'],
        takenDosesDate: '2025-01-01', // Old date
      );

      final available = medication.getAvailableDosesToday();

      expect(available.length, 3);
      expect(available, containsAll(['08:00', '16:00', '00:00']));
    });

    test('getAvailableDosesToday should return empty when all doses are taken or skipped', () {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'test_6',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '20:00': 1.0},
        takenDosesToday: ['08:00'],
        skippedDosesToday: ['20:00'],
        takenDosesDate: todayString,
      );

      final available = medication.getAvailableDosesToday();

      expect(available, isEmpty);
    });

    test('should handle only skipped doses (no taken doses)', () {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'test_7',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
        takenDosesToday: [],
        skippedDosesToday: ['08:00', '16:00'],
        takenDosesDate: todayString,
      );

      final available = medication.getAvailableDosesToday();

      expect(available.length, 1);
      expect(available, contains('00:00'));
    });

    test('should handle only taken doses (no skipped doses)', () {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'test_8',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
        takenDosesToday: ['08:00', '16:00'],
        skippedDosesToday: [],
        takenDosesDate: todayString,
      );

      final available = medication.getAvailableDosesToday();

      expect(available.length, 1);
      expect(available, contains('00:00'));
    });

    test('toJson should include skippedDosesToday as comma-separated string', () {
      final medication = Medication(
        id: 'test_9',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        skippedDosesToday: ['08:00', '16:00'],
      );

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
      final medication = Medication(
        id: 'test_12',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.5, '16:00': 2.0, '00:00': 1.0},
      );

      expect(medication.totalDailyDose, 4.5);
    });

    test('isStockLow should consider skipped doses do not affect stock', () {
      // Stock is low if less than 3 days worth
      // 3 doses/day * 1.0 per dose = 3.0 per day
      // 3 days = 9.0 total needed
      final medication = Medication(
        id: 'test_13',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '00:00': 1.0},
        stockQuantity: 8.0, // Less than 9.0
      );

      expect(medication.isStockLow, isTrue);
    });
  });

  group('Medication Model - Refill', () {
    test('should create medication with lastRefillAmount', () {
      final medication = Medication(
        id: 'test_14',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 10.0,
        lastRefillAmount: 30.0,
      );

      expect(medication.lastRefillAmount, 30.0);
    });

    test('should handle null lastRefillAmount', () {
      final medication = Medication(
        id: 'test_15',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 10.0,
      );

      expect(medication.lastRefillAmount, isNull);
    });

    test('should serialize and deserialize lastRefillAmount', () {
      final medication = Medication(
        id: 'test_16',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 10.0,
        lastRefillAmount: 50.0,
      );

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.lastRefillAmount, 50.0);
    });

    test('should handle null lastRefillAmount in serialization', () {
      final medication = Medication(
        id: 'test_17',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 10.0,
        lastRefillAmount: null,
      );

      final json = medication.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.lastRefillAmount, isNull);
    });

    test('should update lastRefillAmount when refilling', () {
      final medication = Medication(
        id: 'test_18',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 10.0,
        lastRefillAmount: 30.0,
      );

      // Simulate refill with new amount
      final refillAmount = 40.0;
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + refillAmount,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: refillAmount,
      );

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
