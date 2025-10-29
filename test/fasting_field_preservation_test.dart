import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'helpers/medication_builder.dart';

/// Tests to verify that fasting fields are preserved when updating medications
/// This ensures that the bug where fasting configuration was lost is fixed
void main() {
  setUpAll(() async {
    // Initialize SQLite FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Use in-memory database for testing
    DatabaseHelper.setInMemoryDatabase(true);
  });

  setUp(() async {
    // Reset database before each test
    await DatabaseHelper.resetDatabase();
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  group('Fasting Field Preservation - Taking a Dose', () {
    test('should preserve fasting fields when taking a dose', () async {
      // Create a medication with fasting configuration
      final medication = MedicationBuilder()
          .withId('test-fasting-1')
          .withName('Test Med with Fasting')
          .withType(MedicationType.pill)
          .withDoseSchedule({'08:00': 1.0, '20:00': 1.0})
          .withStock(20.0)
          .withFasting(type: 'before', duration: 60, notify: true)
          .build();

      // Save to database
      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate taking a dose (what happens in medication_list_screen.dart)
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - 1.0,
        takenDosesToday: ['08:00'],
        skippedDosesToday: [],
        takenDosesDate: todayString,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Retrieve from database and verify fasting fields are preserved
      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should be preserved');
      expect(retrieved.fastingType, 'before', reason: 'fastingType should be preserved');
      expect(retrieved.fastingDurationMinutes, 60, reason: 'fastingDurationMinutes should be preserved');
      expect(retrieved.notifyFasting, true, reason: 'notifyFasting should be preserved');

      // Also verify the dose was taken
      expect(retrieved.stockQuantity, 19.0);
      expect(retrieved.takenDosesToday, ['08:00']);
    });

    test('should preserve fasting fields even when fasting is disabled', () async {
      final medication = MedicationBuilder()
          .withId('test-fasting-2')
          .withName('Test Med without Fasting')
          .withDoseSchedule({'08:00': 1.0})
          .withStock(10.0)
          .withFastingDisabled()
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - 1.0,
        takenDosesToday: ['08:00'],
        skippedDosesToday: [],
        takenDosesDate: todayString,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, false, reason: 'requiresFasting=false should be preserved');
      expect(retrieved.fastingType, isNull, reason: 'fastingType=null should be preserved');
      expect(retrieved.fastingDurationMinutes, isNull, reason: 'fastingDurationMinutes=null should be preserved');
      expect(retrieved.notifyFasting, false, reason: 'notifyFasting=false should be preserved');
    });
  });

  group('Fasting Field Preservation - Refilling Stock', () {
    test('should preserve fasting fields when refilling stock', () async {
      final medication = MedicationBuilder()
          .withId('test-fasting-3')
          .withName('Test Med Refill')
          .withDoseSchedule({'08:00': 1.0})
          .withStock(5.0)
          .withFasting(type: 'after', duration: 120, notify: true)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate refilling stock (what happens in medication_list_screen.dart)
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + 30.0,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: 30.0,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should be preserved after refill');
      expect(retrieved.fastingType, 'after', reason: 'fastingType should be preserved after refill');
      expect(retrieved.fastingDurationMinutes, 120, reason: 'fastingDurationMinutes should be preserved after refill');
      expect(retrieved.notifyFasting, true, reason: 'notifyFasting should be preserved after refill');

      // Also verify stock was refilled
      expect(retrieved.stockQuantity, 35.0);
      expect(retrieved.lastRefillAmount, 30.0);
    });
  });

  group('Fasting Field Preservation - Editing Schedule', () {
    test('should preserve fasting fields when editing dose schedule', () async {
      final medication = MedicationBuilder()
          .withId('test-fasting-4')
          .withName('Test Med Schedule Edit')
          .withDoseSchedule({'08:00': 1.0, '20:00': 1.0})
          .withFasting(type: 'before', duration: 30, notify: false)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate editing schedule (what happens in edit_schedule_screen.dart)
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: 6, // Changed
        durationType: medication.durationType,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        doseSchedule: {'06:00': 1.0, '12:00': 1.0, '18:00': 1.5}, // Changed
        stockQuantity: medication.stockQuantity,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should be preserved when editing schedule');
      expect(retrieved.fastingType, 'before', reason: 'fastingType should be preserved when editing schedule');
      expect(retrieved.fastingDurationMinutes, 30, reason: 'fastingDurationMinutes should be preserved when editing schedule');
      expect(retrieved.notifyFasting, false, reason: 'notifyFasting should be preserved when editing schedule');

      // Verify schedule was updated
      expect(retrieved.doseSchedule.length, 3);
      expect(retrieved.doseSchedule['06:00'], 1.0);
    });
  });

  group('Fasting Field Preservation - Editing Frequency', () {
    test('should preserve fasting fields when editing frequency', () async {
      final medication = MedicationBuilder()
          .withId('test-fasting-5')
          .withName('Test Med Frequency Edit')
          .withDurationType(TreatmentDurationType.everyday)
          .withDoseSchedule({'08:00': 1.0})
          .withFasting(type: 'after', duration: 240, notify: true)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate editing frequency (what happens in edit_frequency_screen.dart)
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: TreatmentDurationType.weeklyPattern, // Changed
        selectedDates: null,
        weeklyDays: [1, 3, 5], // Changed - Monday, Wednesday, Friday
        dayInterval: null,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should be preserved when editing frequency');
      expect(retrieved.fastingType, 'after', reason: 'fastingType should be preserved when editing frequency');
      expect(retrieved.fastingDurationMinutes, 240, reason: 'fastingDurationMinutes should be preserved when editing frequency');
      expect(retrieved.notifyFasting, true, reason: 'notifyFasting should be preserved when editing frequency');

      // Verify frequency was updated
      expect(retrieved.durationType, TreatmentDurationType.weeklyPattern);
      expect(retrieved.weeklyDays, [1, 3, 5]);
    });
  });

  group('Fasting Field Preservation - Editing Duration', () {
    test('should preserve fasting fields when editing treatment duration', () async {
      final medication = MedicationBuilder()
          .withId('test-fasting-6')
          .withName('Test Med Duration Edit')
          .withDoseSchedule({'08:00': 1.0})
          .withDateRange(DateTime(2025, 10, 1), DateTime(2025, 10, 31))
          .withFasting(type: 'before', duration: 480, notify: true)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate editing duration (what happens in edit_duration_screen.dart)
      final newStartDate = DateTime(2025, 11, 1);
      final newEndDate = DateTime(2025, 11, 30);

      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        startDate: newStartDate, // Changed
        endDate: newEndDate, // Changed
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should be preserved when editing duration');
      expect(retrieved.fastingType, 'before', reason: 'fastingType should be preserved when editing duration');
      expect(retrieved.fastingDurationMinutes, 480, reason: 'fastingDurationMinutes should be preserved when editing duration');
      expect(retrieved.notifyFasting, true, reason: 'notifyFasting should be preserved when editing duration');

      // Verify duration was updated
      expect(retrieved.startDate, newStartDate);
      expect(retrieved.endDate, newEndDate);
    });
  });

  group('Fasting Field Preservation - Editing Quantity', () {
    test('should preserve fasting fields when editing stock quantity', () async {
      final medication = MedicationBuilder()
          .withId('test-fasting-7')
          .withName('Test Med Quantity Edit')
          .withDoseSchedule({'08:00': 1.0})
          .withStock(20.0)
          .withLowStockThreshold(3)
          .withFasting(type: 'after', duration: 90, notify: false)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate editing quantity (what happens in edit_quantity_screen.dart)
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        doseSchedule: medication.doseSchedule,
        stockQuantity: 50.0, // Changed
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: 5, // Changed
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should be preserved when editing quantity');
      expect(retrieved.fastingType, 'after', reason: 'fastingType should be preserved when editing quantity');
      expect(retrieved.fastingDurationMinutes, 90, reason: 'fastingDurationMinutes should be preserved when editing quantity');
      expect(retrieved.notifyFasting, false, reason: 'notifyFasting should be preserved when editing quantity');

      // Verify quantity was updated
      expect(retrieved.stockQuantity, 50.0);
      expect(retrieved.lowStockThresholdDays, 5);
    });
  });

  group('Fasting Field Preservation - Editing Basic Info', () {
    test('should preserve fasting fields when editing basic info', () async {
      final medication = MedicationBuilder()
          .withId('test-fasting-8')
          .withName('Original Name')
          .withType(MedicationType.pill)
          .withDoseSchedule({'08:00': 1.0})
          .withFasting(type: 'before', duration: 120, notify: true)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Simulate editing basic info (what happens in edit_basic_info_screen.dart)
      final updatedMedication = Medication(
        id: medication.id,
        name: 'Updated Name', // Changed
        type: MedicationType.capsule, // Changed
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      final retrieved = await DatabaseHelper.instance.getMedication(medication.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should be preserved when editing basic info');
      expect(retrieved.fastingType, 'before', reason: 'fastingType should be preserved when editing basic info');
      expect(retrieved.fastingDurationMinutes, 120, reason: 'fastingDurationMinutes should be preserved when editing basic info');
      expect(retrieved.notifyFasting, true, reason: 'notifyFasting should be preserved when editing basic info');

      // Verify basic info was updated
      expect(retrieved.name, 'Updated Name');
      expect(retrieved.type, MedicationType.capsule);
    });
  });

  group('Fasting Field Preservation - Complex Scenarios', () {
    test('should preserve all fasting configurations across multiple operations', () async {
      // Create a medication with full fasting configuration
      final medication = MedicationBuilder()
          .withId('test-fasting-9')
          .withName('Complex Test Med')
          .withType(MedicationType.pill)
          .withDoseSchedule({'08:00': 1.0, '20:00': 1.0})
          .withStock(50.0)
          .withLowStockThreshold(5)
          .withDateRange(DateTime(2025, 10, 1), DateTime(2025, 10, 31))
          .withFasting(type: 'before', duration: 60, notify: true)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Operation 1: Take a dose
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      var updated = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - 1.0,
        takenDosesToday: ['08:00'],
        skippedDosesToday: [],
        takenDosesDate: todayString,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );
      await DatabaseHelper.instance.updateMedication(updated);

      // Verify after dose
      var retrieved = await DatabaseHelper.instance.getMedication(medication.id);
      expect(retrieved!.requiresFasting, true);
      expect(retrieved.fastingType, 'before');
      expect(retrieved.fastingDurationMinutes, 60);
      expect(retrieved.notifyFasting, true);

      // Operation 2: Refill stock
      updated = Medication(
        id: retrieved.id,
        name: retrieved.name,
        type: retrieved.type,
        dosageIntervalHours: retrieved.dosageIntervalHours,
        durationType: retrieved.durationType,
        doseSchedule: retrieved.doseSchedule,
        stockQuantity: retrieved.stockQuantity + 20.0,
        takenDosesToday: retrieved.takenDosesToday,
        skippedDosesToday: retrieved.skippedDosesToday,
        takenDosesDate: retrieved.takenDosesDate,
        lastRefillAmount: 20.0,
        lowStockThresholdDays: retrieved.lowStockThresholdDays,
        selectedDates: retrieved.selectedDates,
        weeklyDays: retrieved.weeklyDays,
        dayInterval: retrieved.dayInterval,
        startDate: retrieved.startDate,
        endDate: retrieved.endDate,
        requiresFasting: retrieved.requiresFasting,
        fastingType: retrieved.fastingType,
        fastingDurationMinutes: retrieved.fastingDurationMinutes,
        notifyFasting: retrieved.notifyFasting,
        isSuspended: retrieved.isSuspended,
        lastDailyConsumption: retrieved.lastDailyConsumption,
      );
      await DatabaseHelper.instance.updateMedication(updated);

      // Verify after refill
      retrieved = await DatabaseHelper.instance.getMedication(medication.id);
      expect(retrieved!.requiresFasting, true);
      expect(retrieved.fastingType, 'before');
      expect(retrieved.fastingDurationMinutes, 60);
      expect(retrieved.notifyFasting, true);

      // Operation 3: Edit schedule
      updated = Medication(
        id: retrieved.id,
        name: retrieved.name,
        type: retrieved.type,
        dosageIntervalHours: 6,
        durationType: retrieved.durationType,
        selectedDates: retrieved.selectedDates,
        weeklyDays: retrieved.weeklyDays,
        dayInterval: retrieved.dayInterval,
        doseSchedule: {'06:00': 1.0, '12:00': 1.0, '18:00': 1.0},
        stockQuantity: retrieved.stockQuantity,
        takenDosesToday: retrieved.takenDosesToday,
        skippedDosesToday: retrieved.skippedDosesToday,
        takenDosesDate: retrieved.takenDosesDate,
        lastRefillAmount: retrieved.lastRefillAmount,
        lowStockThresholdDays: retrieved.lowStockThresholdDays,
        startDate: retrieved.startDate,
        endDate: retrieved.endDate,
        requiresFasting: retrieved.requiresFasting,
        fastingType: retrieved.fastingType,
        fastingDurationMinutes: retrieved.fastingDurationMinutes,
        notifyFasting: retrieved.notifyFasting,
        isSuspended: retrieved.isSuspended,
        lastDailyConsumption: retrieved.lastDailyConsumption,
      );
      await DatabaseHelper.instance.updateMedication(updated);

      // Final verification - fasting should still be intact
      retrieved = await DatabaseHelper.instance.getMedication(medication.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.requiresFasting, true, reason: 'requiresFasting should survive multiple operations');
      expect(retrieved.fastingType, 'before', reason: 'fastingType should survive multiple operations');
      expect(retrieved.fastingDurationMinutes, 60, reason: 'fastingDurationMinutes should survive multiple operations');
      expect(retrieved.notifyFasting, true, reason: 'notifyFasting should survive multiple operations');

      // Verify all operations were applied
      expect(retrieved.stockQuantity, 69.0); // 50 - 1 + 20
      expect(retrieved.lastRefillAmount, 20.0);
      expect(retrieved.doseSchedule.length, 3);
    });
  });
}
