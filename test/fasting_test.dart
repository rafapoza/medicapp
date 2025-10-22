import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/medication_builder.dart';

void main() {
  group('Medication Model - Fasting Configuration', () {
    test('should create medication without fasting by default', () {
      final medication = MedicationBuilder()
          .withId('test_1')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .build();

      expect(medication.requiresFasting, false);
      expect(medication.fastingType, isNull);
      expect(medication.fastingDurationMinutes, isNull);
      expect(medication.notifyFasting, false);
    });

    test('should create medication with fasting before dose', () {
      final medication = MedicationBuilder()
          .withId('test_2')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withFasting(type: 'before', duration: 60)
          .build();

      expect(medication.requiresFasting, true);
      expect(medication.fastingType, 'before');
      expect(medication.fastingDurationMinutes, 60);
      expect(medication.notifyFasting, true);
    });

    test('should create medication with fasting after dose', () {
      final medication = MedicationBuilder()
          .withId('test_3')
          .withDosageInterval(12)
          .withMultipleDoses(['08:00', '20:00'], 1.0)
          .withFasting(type: 'after', duration: 120, notify: false)
          .build();

      expect(medication.requiresFasting, true);
      expect(medication.fastingType, 'after');
      expect(medication.fastingDurationMinutes, 120);
      expect(medication.notifyFasting, false);
    });

    test('should handle fasting duration in minutes', () {
      final medication = MedicationBuilder()
          .withId('test_4')
          .withSingleDose('08:00', 1.0)
          .withFasting(type: 'before', duration: 30)
          .build();

      expect(medication.fastingDurationMinutes, 30);
    });

    test('should handle fasting duration in hours and minutes', () {
      final medication = MedicationBuilder()
          .withId('test_5')
          .withSingleDose('08:00', 1.0)
          .withFasting(type: 'before', duration: 90)
          .build();

      expect(medication.fastingDurationMinutes, 90);
    });

    test('should serialize fasting configuration to JSON', () {
      final medication = MedicationBuilder()
          .withId('test_6')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withFasting(type: 'before', duration: 60)
          .build();

      final json = medication.toJson();

      expect(json['requiresFasting'], 1); // Stored as integer
      expect(json['fastingType'], 'before');
      expect(json['fastingDurationMinutes'], 60);
      expect(json['notifyFasting'], 1); // Stored as integer
    });

    test('should serialize fasting disabled to JSON', () {
      final medication = MedicationBuilder()
          .withId('test_7')
          .withSingleDose('08:00', 1.0)
          .withFastingDisabled()
          .build();

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
      final original = MedicationBuilder()
          .withId('test_11')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withFasting(type: 'after', duration: 90)
          .build();

      final json = original.toJson();
      final deserialized = Medication.fromJson(json);

      expect(deserialized.requiresFasting, original.requiresFasting);
      expect(deserialized.fastingType, original.fastingType);
      expect(deserialized.fastingDurationMinutes, original.fastingDurationMinutes);
      expect(deserialized.notifyFasting, original.notifyFasting);
    });

    test('should update medication with fasting configuration', () {
      final original = MedicationBuilder()
          .withId('test_12')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .withStock(10.0)
          .withFastingDisabled()
          .build();

      // Update to require fasting using builder
      final updated = MedicationBuilder.from(original)
          .withFasting(type: 'before', duration: 60)
          .build();

      expect(updated.requiresFasting, true);
      expect(updated.fastingType, 'before');
      expect(updated.fastingDurationMinutes, 60);
      expect(updated.notifyFasting, true);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
    });

    test('should handle fasting with various duration values', () {
      // Test 15 minutes
      final med15 = MedicationBuilder()
          .withId('test_13')
          .withName('Test Med 15min')
          .withSingleDose('08:00', 1.0)
          .withFasting(type: 'before', duration: 15)
          .build();
      expect(med15.fastingDurationMinutes, 15);

      // Test 4 hours (240 minutes)
      final med4h = MedicationBuilder()
          .withId('test_14')
          .withName('Test Med 4h')
          .withSingleDose('08:00', 1.0)
          .withFasting(type: 'after', duration: 240, notify: false)
          .build();
      expect(med4h.fastingDurationMinutes, 240);

      // Test 12 hours (720 minutes)
      final med12h = MedicationBuilder()
          .withId('test_15')
          .withName('Test Med 12h')
          .withDosageInterval(24)
          .withSingleDose('08:00', 1.0)
          .withFasting(type: 'before', duration: 720)
          .build();
      expect(med12h.fastingDurationMinutes, 720);
    });

    test('should handle fasting configuration with all medication types', () {
      final types = [
        MedicationType.pill,
        MedicationType.capsule,
        MedicationType.syrup,
        MedicationType.injection,
        MedicationType.ointment,
        MedicationType.spray,
      ];

      for (final type in types) {
        final medication = MedicationBuilder()
            .withId('test_${type.name}')
            .withName('Test ${type.displayName}')
            .withType(type)
            .withSingleDose('08:00', 1.0)
            .withFasting(type: 'before', duration: 60)
            .build();

        expect(medication.requiresFasting, true);
        expect(medication.fastingType, 'before');
        expect(medication.fastingDurationMinutes, 60);
        expect(medication.notifyFasting, true);
      }
    });

    test('should preserve other fields when adding fasting', () {
      final original = MedicationBuilder()
          .withId('test_16')
          .withDurationType(TreatmentDurationType.weeklyPattern)
          .withDoseSchedule({'08:00': 1.5, '16:00': 2.0})
          .withStock(50.0)
          .withTakenDoses(['08:00'], '2025-10-16')
          .withSkippedDoses(['16:00'], '2025-10-16')
          .withLastRefill(30.0)
          .withLowStockThreshold(5)
          .withWeeklyPattern([1, 3, 5])
          .withDateRange(DateTime(2025, 10, 1), DateTime(2025, 10, 31))
          .build();

      // Add fasting using builder.from()
      final withFasting = MedicationBuilder.from(original)
          .withFasting(type: 'before', duration: 60)
          .build();

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
