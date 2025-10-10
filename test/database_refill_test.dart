import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for sqflite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Use in-memory database for tests
    DatabaseHelper.setInMemoryDatabase(true);
  });

  tearDown(() async {
    // Clean up after each test
    await DatabaseHelper.instance.deleteAllMedications();
    await DatabaseHelper.resetDatabase();
  });

  group('Database - Refill Persistence', () {
    test('should save and retrieve lastRefillAmount from database', () async {
      final medication = Medication(
        id: 'test_db_1',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 30.0,
        lastRefillAmount: 50.0,
      );

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Retrieve medication
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.lastRefillAmount, 50.0);
    });

    test('should save and retrieve null lastRefillAmount from database', () async {
      final medication = Medication(
        id: 'test_db_2',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 30.0,
        lastRefillAmount: null,
      );

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Retrieve medication
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_2');

      expect(retrieved, isNotNull);
      expect(retrieved!.lastRefillAmount, isNull);
    });

    test('should update lastRefillAmount in database', () async {
      final medication = Medication(
        id: 'test_db_3',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 30.0,
        lastRefillAmount: 50.0,
      );

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate refill
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + 40.0, // Add 40
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: 40.0, // New refill amount
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Retrieve and verify
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_3');

      expect(retrieved, isNotNull);
      expect(retrieved!.stockQuantity, 70.0);
      expect(retrieved.lastRefillAmount, 40.0);
    });

    test('should preserve lastRefillAmount when updating other fields', () async {
      final medication = Medication(
        id: 'test_db_4',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 30.0,
        lastRefillAmount: 50.0,
      );

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Update only the name
      final updatedMedication = Medication(
        id: medication.id,
        name: 'Updated Name',
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount, // Preserve it
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Retrieve and verify
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_4');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.lastRefillAmount, 50.0); // Still preserved
    });

    test('should handle multiple medications with different lastRefillAmount', () async {
      final med1 = Medication(
        id: 'test_db_5',
        name: 'Medication 1',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 30.0,
        lastRefillAmount: 50.0,
      );

      final med2 = Medication(
        id: 'test_db_6',
        name: 'Medication 2',
        type: MedicationType.jarabe,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'09:00': 5.0},
        stockQuantity: 100.0,
        lastRefillAmount: 200.0,
      );

      final med3 = Medication(
        id: 'test_db_7',
        name: 'Medication 3',
        type: MedicationType.capsula,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 15.0,
        lastRefillAmount: null, // No previous refill
      );

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
      final medication = Medication(
        id: 'test_db_8',
        name: 'Test Medication',
        type: MedicationType.jarabe,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 5.5},
        stockQuantity: 100.5,
        lastRefillAmount: 150.75, // Decimal value
      );

      // Insert medication
      await DatabaseHelper.instance.insertMedication(medication);

      // Retrieve medication
      final retrieved = await DatabaseHelper.instance.getMedication('test_db_8');

      expect(retrieved, isNotNull);
      expect(retrieved!.lastRefillAmount, 150.75);
    });
  });
}
