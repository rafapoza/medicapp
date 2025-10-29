import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/models/dose_history_entry.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/medication_builder.dart';
import 'helpers/database_test_helper.dart';
import 'helpers/test_helpers.dart';

void main() {
  // Setup database with helper
  DatabaseTestHelper.setup();

  group('As-Needed Medications - Main Screen Display', () {
    test('getMedicationIdsWithDosesToday returns empty set when no doses taken today', () async {
      // Create an as-needed medication
      final medication = MedicationBuilder()
          .withId('test_as_needed_1')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should be empty since no doses have been registered
      expect(idsWithDosesToday, isEmpty);
    });

    test('getMedicationIdsWithDosesToday includes medication when dose taken today', () async {
      // Create an as-needed medication
      final medication = MedicationBuilder()
          .withId('test_as_needed_2')
          .withName('Paracetamol')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Register a dose taken today
      final now = DateTime.now();
      final historyEntry = DoseHistoryEntry(
        id: 'dose_1',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: now, // For as-needed, scheduled = registered
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should include the medication
      expect(idsWithDosesToday, contains(medication.id));
      expect(idsWithDosesToday.length, 1);
    });

    test('getMedicationIdsWithDosesToday does NOT include skipped doses', () async {
      // Create an as-needed medication
      final medication = MedicationBuilder()
          .withId('test_as_needed_3')
          .withName('Aspirina')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Register a SKIPPED dose (not taken)
      final now = DateTime.now();
      final historyEntry = DoseHistoryEntry(
        id: 'dose_2',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: now,
        registeredDateTime: now,
        status: DoseStatus.skipped, // Skipped, not taken
        quantity: 0.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should be empty since dose was skipped
      expect(idsWithDosesToday, isEmpty);
    });

    test('getMedicationIdsWithDosesToday does NOT include doses from yesterday', () async {
      // Create an as-needed medication
      final medication = MedicationBuilder()
          .withId('test_as_needed_4')
          .withName('Omeprazol')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Register a dose from yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final historyEntry = DoseHistoryEntry(
        id: 'dose_3',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: yesterday,
        registeredDateTime: yesterday, // Registered yesterday
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should be empty since dose was yesterday
      expect(idsWithDosesToday, isEmpty);
    });

    test('getMedicationIdsWithDosesToday handles multiple doses of same medication', () async {
      // Create an as-needed medication
      final medication = MedicationBuilder()
          .withId('test_as_needed_5')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final now = DateTime.now();

      // Register first dose at 10:00
      final dose1 = DoseHistoryEntry(
        id: 'dose_4',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: todayAt(10, 0),
        registeredDateTime: todayAt(10, 0),
        status: DoseStatus.taken,
        quantity: 1.0,
      );
      await DatabaseHelper.instance.insertDoseHistory(dose1);

      // Register second dose at 15:00
      final dose2 = DoseHistoryEntry(
        id: 'dose_5',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: todayAt(15, 0),
        registeredDateTime: todayAt(15, 0),
        status: DoseStatus.taken,
        quantity: 2.0,
      );
      await DatabaseHelper.instance.insertDoseHistory(dose2);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should include the medication only once (not duplicated)
      expect(idsWithDosesToday, contains(medication.id));
      expect(idsWithDosesToday.length, 1);
    });

    test('getMedicationIdsWithDosesToday handles multiple different medications', () async {
      // Create two as-needed medications
      final med1 = MedicationBuilder()
          .withId('test_as_needed_6')
          .withName('Ibuprofeno')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      final med2 = MedicationBuilder()
          .withId('test_as_needed_7')
          .withName('Paracetamol')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(med1);
      await DatabaseHelper.instance.insertMedication(med2);

      final now = DateTime.now();

      // Register dose for first medication
      final dose1 = DoseHistoryEntry(
        id: 'dose_6',
        medicationId: med1.id,
        medicationName: med1.name,
        medicationType: med1.type,
        scheduledDateTime: now,
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: 1.0,
      );
      await DatabaseHelper.instance.insertDoseHistory(dose1);

      // Register dose for second medication
      final dose2 = DoseHistoryEntry(
        id: 'dose_7',
        medicationId: med2.id,
        medicationName: med2.name,
        medicationType: med2.type,
        scheduledDateTime: now,
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: 1.0,
      );
      await DatabaseHelper.instance.insertDoseHistory(dose2);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should include both medications
      expect(idsWithDosesToday, contains(med1.id));
      expect(idsWithDosesToday, contains(med2.id));
      expect(idsWithDosesToday.length, 2);
    });

    test('getMedicationIdsWithDosesToday works for programmed medications too', () async {
      // Create a programmed medication (not as-needed)
      final medication = MedicationBuilder()
          .withId('test_programmed_1')
          .withName('Atorvastatina')
          .withDurationType(TreatmentDurationType.everyday)
          .withDosageInterval(24)
          .withSingleDose('20:00', 1.0)
          .withStock(30.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Register a dose taken today
      final now = DateTime.now();
      final historyEntry = DoseHistoryEntry(
        id: 'dose_8',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: todayAt(20, 0),
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should include the programmed medication too
      expect(idsWithDosesToday, contains(medication.id));
    });

    test('getMedicationIdsWithDosesToday uses registeredDateTime, not scheduledDateTime', () async {
      // Create an as-needed medication
      final medication = MedicationBuilder()
          .withId('test_as_needed_8')
          .withName('Test Med')
          .withAsNeeded()
          .withStock(20.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Register a dose that was scheduled yesterday but registered today
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      final historyEntry = DoseHistoryEntry(
        id: 'dose_9',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: yesterday, // Scheduled yesterday
        registeredDateTime: today, // But registered today
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Get medications with doses today
      final idsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();

      // Should include the medication because it was registered today
      expect(idsWithDosesToday, contains(medication.id));
    });
  });
}
