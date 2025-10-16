import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';

void main() {
  group('Medication Model - Fasting Configuration', () {
    test('should create medication without fasting by default', () {
      final medication = Medication(
        id: 'test_1',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
      );

      expect(medication.requiresFasting, false);
      expect(medication.fastingType, isNull);
      expect(medication.fastingDurationMinutes, isNull);
      expect(medication.notifyFasting, false);
    });

    test('should create medication with fasting before dose', () {
      final medication = Medication(
        id: 'test_2',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60, // 1 hour
        notifyFasting: true,
      );

      expect(medication.requiresFasting, true);
      expect(medication.fastingType, 'before');
      expect(medication.fastingDurationMinutes, 60);
      expect(medication.notifyFasting, true);
    });

    test('should create medication with fasting after dose', () {
      final medication = Medication(
        id: 'test_3',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '20:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 120, // 2 hours
        notifyFasting: false,
      );

      expect(medication.requiresFasting, true);
      expect(medication.fastingType, 'after');
      expect(medication.fastingDurationMinutes, 120);
      expect(medication.notifyFasting, false);
    });

    test('should handle fasting duration in minutes', () {
      final medication = Medication(
        id: 'test_4',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 30, // 30 minutes
        notifyFasting: true,
      );

      expect(medication.fastingDurationMinutes, 30);
    });

    test('should handle fasting duration in hours and minutes', () {
      final medication = Medication(
        id: 'test_5',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 90, // 1 hour 30 minutes
        notifyFasting: true,
      );

      expect(medication.fastingDurationMinutes, 90);
    });

    test('should serialize fasting configuration to JSON', () {
      final medication = Medication(
        id: 'test_6',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      final json = medication.toJson();

      expect(json['requiresFasting'], 1); // Stored as integer
      expect(json['fastingType'], 'before');
      expect(json['fastingDurationMinutes'], 60);
      expect(json['notifyFasting'], 1); // Stored as integer
    });

    test('should serialize fasting disabled to JSON', () {
      final medication = Medication(
        id: 'test_7',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: false,
      );

      final json = medication.toJson();

      expect(json['requiresFasting'], 0); // Stored as integer
      expect(json['fastingType'], isNull);
      expect(json['fastingDurationMinutes'], isNull);
      expect(json['notifyFasting'], 0); // Stored as integer
    });

    test('should deserialize fasting configuration from JSON', () {
      final json = {
        'id': 'test_8',
        'name': 'Test Medication',
        'type': 'pastilla',
        'dosageIntervalHours': 8,
        'durationType': 'everyday',
        'doseTimes': '08:00,16:00',
        'doseSchedule': '{"08:00": 1.0, "16:00": 1.0}',
        'stockQuantity': 10,
        'takenDosesToday': '',
        'skippedDosesToday': '',
        'requiresFasting': 1,
        'fastingType': 'before',
        'fastingDurationMinutes': 60,
        'notifyFasting': 1,
      };

      final medication = Medication.fromJson(json);

      expect(medication.requiresFasting, true);
      expect(medication.fastingType, 'before');
      expect(medication.fastingDurationMinutes, 60);
      expect(medication.notifyFasting, true);
    });

    test('should deserialize fasting disabled from JSON', () {
      final json = {
        'id': 'test_9',
        'name': 'Test Medication',
        'type': 'pastilla',
        'dosageIntervalHours': 8,
        'durationType': 'everyday',
        'doseTimes': '08:00',
        'doseSchedule': '{"08:00": 1.0}',
        'stockQuantity': 10,
        'takenDosesToday': '',
        'skippedDosesToday': '',
        'requiresFasting': 0,
        'fastingType': null,
        'fastingDurationMinutes': null,
        'notifyFasting': 0,
      };

      final medication = Medication.fromJson(json);

      expect(medication.requiresFasting, false);
      expect(medication.fastingType, isNull);
      expect(medication.fastingDurationMinutes, isNull);
      expect(medication.notifyFasting, false);
    });

    test('should handle missing fasting fields in JSON (legacy data)', () {
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
        // Fasting fields missing (legacy data)
      };

      final medication = Medication.fromJson(json);

      expect(medication.requiresFasting, false);
      expect(medication.fastingType, isNull);
      expect(medication.fastingDurationMinutes, isNull);
      expect(medication.notifyFasting, false);
    });

    test('should round-trip serialize and deserialize fasting configuration', () {
      final original = Medication(
        id: 'test_11',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 90,
        notifyFasting: true,
      );

      final json = original.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.requiresFasting, original.requiresFasting);
      expect(deserialized.fastingType, original.fastingType);
      expect(deserialized.fastingDurationMinutes, original.fastingDurationMinutes);
      expect(deserialized.notifyFasting, original.notifyFasting);
    });

    test('should update medication with fasting configuration', () {
      final original = Medication(
        id: 'test_12',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 10,
        requiresFasting: false,
      );

      // Update to require fasting
      final updated = Medication(
        id: original.id,
        name: original.name,
        type: original.type,
        dosageIntervalHours: original.dosageIntervalHours,
        durationType: original.durationType,
        doseSchedule: original.doseSchedule,
        stockQuantity: original.stockQuantity,
        takenDosesToday: original.takenDosesToday,
        skippedDosesToday: original.skippedDosesToday,
        takenDosesDate: original.takenDosesDate,
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      expect(updated.requiresFasting, true);
      expect(updated.fastingType, 'before');
      expect(updated.fastingDurationMinutes, 60);
      expect(updated.notifyFasting, true);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
    });

    test('should handle fasting with various duration values', () {
      // Test 15 minutes
      final med15 = Medication(
        id: 'test_13',
        name: 'Test Med 15min',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 15,
        notifyFasting: true,
      );
      expect(med15.fastingDurationMinutes, 15);

      // Test 4 hours (240 minutes)
      final med4h = Medication(
        id: 'test_14',
        name: 'Test Med 4h',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 240,
        notifyFasting: false,
      );
      expect(med4h.fastingDurationMinutes, 240);

      // Test 12 hours (720 minutes)
      final med12h = Medication(
        id: 'test_15',
        name: 'Test Med 12h',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 720,
        notifyFasting: true,
      );
      expect(med12h.fastingDurationMinutes, 720);
    });

    test('should handle fasting configuration with all medication types', () {
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
          id: 'test_${type.name}',
          name: 'Test ${type.displayName}',
          type: type,
          dosageIntervalHours: 8,
          durationType: TreatmentDurationType.everyday,
          doseSchedule: {'08:00': 1.0},
          requiresFasting: true,
          fastingType: 'before',
          fastingDurationMinutes: 60,
          notifyFasting: true,
        );

        expect(medication.requiresFasting, true);
        expect(medication.fastingType, 'before');
        expect(medication.fastingDurationMinutes, 60);
        expect(medication.notifyFasting, true);
      }
    });

    test('should preserve other fields when adding fasting', () {
      final original = Medication(
        id: 'test_16',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.weeklyPattern,
        doseSchedule: {'08:00': 1.5, '16:00': 2.0},
        stockQuantity: 50,
        takenDosesToday: ['08:00'],
        skippedDosesToday: ['16:00'],
        takenDosesDate: '2025-10-16',
        lastRefillAmount: 30,
        lowStockThresholdDays: 5,
        weeklyDays: [1, 3, 5], // Monday, Wednesday, Friday
        startDate: DateTime(2025, 10, 1),
        endDate: DateTime(2025, 10, 31),
      );

      // Add fasting
      final withFasting = Medication(
        id: original.id,
        name: original.name,
        type: original.type,
        dosageIntervalHours: original.dosageIntervalHours,
        durationType: original.durationType,
        doseSchedule: original.doseSchedule,
        stockQuantity: original.stockQuantity,
        takenDosesToday: original.takenDosesToday,
        skippedDosesToday: original.skippedDosesToday,
        takenDosesDate: original.takenDosesDate,
        lastRefillAmount: original.lastRefillAmount,
        lowStockThresholdDays: original.lowStockThresholdDays,
        weeklyDays: original.weeklyDays,
        startDate: original.startDate,
        endDate: original.endDate,
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      // Verify all original fields are preserved
      expect(withFasting.id, original.id);
      expect(withFasting.name, original.name);
      expect(withFasting.type, original.type);
      expect(withFasting.dosageIntervalHours, original.dosageIntervalHours);
      expect(withFasting.durationType, original.durationType);
      expect(withFasting.doseSchedule, original.doseSchedule);
      expect(withFasting.stockQuantity, original.stockQuantity);
      expect(withFasting.takenDosesToday, original.takenDosesToday);
      expect(withFasting.skippedDosesToday, original.skippedDosesToday);
      expect(withFasting.takenDosesDate, original.takenDosesDate);
      expect(withFasting.lastRefillAmount, original.lastRefillAmount);
      expect(withFasting.lowStockThresholdDays, original.lowStockThresholdDays);
      expect(withFasting.weeklyDays, original.weeklyDays);
      expect(withFasting.startDate, original.startDate);
      expect(withFasting.endDate, original.endDate);

      // Verify fasting fields are added
      expect(withFasting.requiresFasting, true);
      expect(withFasting.fastingType, 'before');
      expect(withFasting.fastingDurationMinutes, 60);
      expect(withFasting.notifyFasting, true);
    });
  });
}
