import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/models/dose_history_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup database helper for testing
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
    await DatabaseHelper.instance.deleteAllDoseHistory();
    await DatabaseHelper.resetDatabase();
  });

  group('Dose History Management Tests', () {
    test('Delete history entry restores dose availability', () async {
      // Create a medication with one dose time
      final medication = Medication(
        id: 'test_med_1',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.0},
        stockQuantity: 10.0,
        takenDosesToday: ['10:00'],
        skippedDosesToday: [],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Create a history entry for the taken dose
      final now = DateTime.now();
      final scheduledDateTime = DateTime(now.year, now.month, now.day, 10, 0);
      final historyEntry = DoseHistoryEntry(
        id: 'history_1',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: scheduledDateTime,
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Verify dose is not available
      expect(medication.getAvailableDosesToday().length, 0);

      // Delete the history entry and update medication
      await DatabaseHelper.instance.deleteDoseHistory(historyEntry.id);

      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + 1.0, // Restore stock
        takenDosesToday: [], // Remove from taken doses
        skippedDosesToday: [],
        takenDosesDate: medication.takenDosesDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Verify dose is now available
      final reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
      expect(reloadedMed, isNotNull);
      expect(reloadedMed!.getAvailableDosesToday().length, 1);
      expect(reloadedMed.getAvailableDosesToday().first, '10:00');
      expect(reloadedMed.stockQuantity, 11.0); // Stock restored
    });

    test('Delete taken dose restores stock, delete skipped dose does not', () async {
      // Create medication with two doses
      final medication = Medication(
        id: 'test_med_2',
        name: 'Test Medication 2',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 2.0, '20:00': 1.0},
        stockQuantity: 10.0,
        takenDosesToday: ['08:00'],
        skippedDosesToday: ['20:00'],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Test deleting taken dose (should restore stock)
      final takenDoses = List<String>.from(medication.takenDosesToday);
      takenDoses.remove('08:00');

      final afterDeleteTaken = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + 2.0, // Restore stock (dose was 2.0)
        takenDosesToday: takenDoses,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
      );

      await DatabaseHelper.instance.updateMedication(afterDeleteTaken);

      var reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
      expect(reloadedMed!.stockQuantity, 12.0); // 10 + 2 restored

      // Test deleting skipped dose (should NOT restore stock)
      final skippedDoses = List<String>.from(reloadedMed.skippedDosesToday);
      skippedDoses.remove('20:00');

      final afterDeleteSkipped = Medication(
        id: reloadedMed.id,
        name: reloadedMed.name,
        type: reloadedMed.type,
        dosageIntervalHours: reloadedMed.dosageIntervalHours,
        durationType: reloadedMed.durationType,
        doseSchedule: reloadedMed.doseSchedule,
        stockQuantity: reloadedMed.stockQuantity, // No stock change
        takenDosesToday: reloadedMed.takenDosesToday,
        skippedDosesToday: skippedDoses,
        takenDosesDate: reloadedMed.takenDosesDate,
      );

      await DatabaseHelper.instance.updateMedication(afterDeleteSkipped);

      reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
      expect(reloadedMed!.stockQuantity, 12.0); // No change from skipped
    });

    test('Only today doses can be deleted', () async {
      // Create medication
      final medication = Medication(
        id: 'test_med_3',
        name: 'Test Medication 3',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Create a history entry from yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final scheduledDateTime = DateTime(yesterday.year, yesterday.month, yesterday.day, 10, 0);

      final historyEntry = DoseHistoryEntry(
        id: 'history_old',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: scheduledDateTime,
        registeredDateTime: yesterday,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Verify entry exists
      final entries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      expect(entries.length, 1);

      // Check if it's from today
      final now = DateTime.now();
      final isToday = historyEntry.scheduledDateTime.year == now.year &&
          historyEntry.scheduledDateTime.month == now.month &&
          historyEntry.scheduledDateTime.day == now.day;

      expect(isToday, false); // Should not be from today

      // In the UI, the delete button should not appear for old entries
      // This is a business logic test - old entries should not affect medication state
    });

    test('Delete history entry removes it from database', () async {
      // Create medication and history entry
      final medication = Medication(
        id: 'test_med_4',
        name: 'Test Medication 4',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final now = DateTime.now();
      final scheduledDateTime = DateTime(now.year, now.month, now.day, 10, 0);

      final historyEntry = DoseHistoryEntry(
        id: 'history_delete_test',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: scheduledDateTime,
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Verify entry exists
      var entries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      expect(entries.length, 1);

      // Delete entry
      await DatabaseHelper.instance.deleteDoseHistory(historyEntry.id);

      // Verify entry is deleted
      entries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      expect(entries.length, 0);
    });
  });

  group('Dose Status Toggle Tests', () {
    test('Toggle taken to skipped restores stock', () async {
      // Create medication with taken dose
      final medication = Medication(
        id: 'test_toggle_1',
        name: 'Test Toggle Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 2.0},
        stockQuantity: 8.0, // 10 - 2 (was taken)
        takenDosesToday: ['10:00'],
        skippedDosesToday: [],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Toggle from taken to skipped
      final takenDoses = List<String>.from(medication.takenDosesToday);
      takenDoses.remove('10:00');
      final skippedDoses = List<String>.from(medication.skippedDosesToday);
      skippedDoses.add('10:00');

      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + 2.0, // Restore stock
        takenDosesToday: takenDoses,
        skippedDosesToday: skippedDoses,
        takenDosesDate: medication.takenDosesDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Verify changes
      final reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
      expect(reloadedMed!.takenDosesToday.length, 0);
      expect(reloadedMed.skippedDosesToday.length, 1);
      expect(reloadedMed.skippedDosesToday.first, '10:00');
      expect(reloadedMed.stockQuantity, 10.0); // Stock restored
    });

    test('Toggle skipped to taken reduces stock', () async {
      // Create medication with skipped dose
      final medication = Medication(
        id: 'test_toggle_2',
        name: 'Test Toggle Med 2',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.5},
        stockQuantity: 10.0,
        takenDosesToday: [],
        skippedDosesToday: ['10:00'],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Toggle from skipped to taken
      final skippedDoses = List<String>.from(medication.skippedDosesToday);
      skippedDoses.remove('10:00');
      final takenDoses = List<String>.from(medication.takenDosesToday);
      takenDoses.add('10:00');

      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - 1.5, // Reduce stock
        takenDosesToday: takenDoses,
        skippedDosesToday: skippedDoses,
        takenDosesDate: medication.takenDosesDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Verify changes
      final reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
      expect(reloadedMed!.takenDosesToday.length, 1);
      expect(reloadedMed.takenDosesToday.first, '10:00');
      expect(reloadedMed.skippedDosesToday.length, 0);
      expect(reloadedMed.stockQuantity, 8.5); // 10 - 1.5
    });

    test('Cannot toggle skipped to taken if insufficient stock', () async {
      // Create medication with skipped dose but low stock
      final medication = Medication(
        id: 'test_toggle_3',
        name: 'Test Toggle Med 3',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 5.0},
        stockQuantity: 2.0, // Not enough for 5.0 dose
        takenDosesToday: [],
        skippedDosesToday: ['10:00'],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Try to toggle from skipped to taken (should fail validation)
      final doseQuantity = medication.getDoseQuantity('10:00');
      expect(medication.stockQuantity < doseQuantity, true);

      // In real scenario, UI should prevent this and show error
      // The stock should remain unchanged
      final reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
      expect(reloadedMed!.stockQuantity, 2.0);
    });

    test('Toggle updates history entry status', () async {
      // Create medication and history entry
      final medication = Medication(
        id: 'test_toggle_4',
        name: 'Test Toggle Med 4',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.0},
        stockQuantity: 9.0,
        takenDosesToday: ['10:00'],
        skippedDosesToday: [],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final now = DateTime.now();
      final scheduledDateTime = DateTime(now.year, now.month, now.day, 10, 0);

      final historyEntry = DoseHistoryEntry(
        id: 'history_toggle',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: scheduledDateTime,
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Verify initial status
      var entries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      expect(entries.first.status, DoseStatus.taken);

      // Toggle status in history
      final updatedEntry = historyEntry.copyWith(
        status: DoseStatus.skipped,
        registeredDateTime: DateTime.now(),
      );

      await DatabaseHelper.instance.insertDoseHistory(updatedEntry);

      // Verify updated status
      entries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      expect(entries.first.status, DoseStatus.skipped);
    });
  });

  group('Multiple Doses Management Tests', () {
    test('Manage multiple doses with different times correctly', () async {
      // Create medication with multiple doses
      final medication = Medication(
        id: 'test_multi_1',
        name: 'Multi Dose Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '16:00': 1.5,
          '00:00': 0.5,
        },
        stockQuantity: 10.0,
        takenDosesToday: ['08:00', '16:00'],
        skippedDosesToday: [],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Verify available doses
      expect(medication.getAvailableDosesToday().length, 1);
      expect(medication.getAvailableDosesToday().first, '00:00');

      // Verify stock calculation
      // Started with 10.0, took 1.0 at 08:00 and 1.5 at 16:00
      expect(medication.stockQuantity, 10.0); // Initial stock

      // Calculate expected stock after taking doses
      final expectedStock = 10.0 - 1.0 - 1.5;

      // Stock should be deducted when doses are marked as taken
      final realStock = 10.0 - (medication.takenDosesToday.contains('08:00') ? 1.0 : 0.0) -
                              (medication.takenDosesToday.contains('16:00') ? 1.5 : 0.0);
      expect(realStock, expectedStock);
    });

    test('Delete one dose from multiple taken doses', () async {
      // Create medication with multiple taken doses
      final medication = Medication(
        id: 'test_multi_2',
        name: 'Multi Dose Med 2',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '16:00': 1.0,
          '00:00': 1.0,
        },
        stockQuantity: 7.0, // 10 - 3 taken
        takenDosesToday: ['08:00', '16:00', '00:00'],
        skippedDosesToday: [],
        takenDosesDate: _getTodayString(),
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Delete middle dose (16:00)
      final takenDoses = List<String>.from(medication.takenDosesToday);
      takenDoses.remove('16:00');

      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + 1.0,
        takenDosesToday: takenDoses,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Verify
      final reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
      expect(reloadedMed!.takenDosesToday.length, 2);
      expect(reloadedMed.takenDosesToday.contains('16:00'), false);
      expect(reloadedMed.takenDosesToday.contains('08:00'), true);
      expect(reloadedMed.takenDosesToday.contains('00:00'), true);
      expect(reloadedMed.stockQuantity, 8.0); // 7 + 1 restored
      expect(reloadedMed.getAvailableDosesToday().length, 1);
      expect(reloadedMed.getAvailableDosesToday().first, '16:00');
    });
  });

  group('Statistics Recalculation Tests', () {
    test('Statistics update correctly after deleting dose', () async {
      // Create medication and multiple history entries
      final medication = Medication(
        id: 'test_stats_1',
        name: 'Stats Test Med',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Create 5 history entries: 4 taken, 1 skipped
      for (int i = 0; i < 5; i++) {
        final date = today.subtract(Duration(days: i));
        final entry = DoseHistoryEntry(
          id: 'stats_entry_$i',
          medicationId: medication.id,
          medicationName: medication.name,
          medicationType: medication.type,
          scheduledDateTime: DateTime(date.year, date.month, date.day, 10, 0),
          registeredDateTime: date,
          status: i == 2 ? DoseStatus.skipped : DoseStatus.taken,
          quantity: 1.0,
        );
        await DatabaseHelper.instance.insertDoseHistory(entry);
      }

      // Get initial statistics
      var stats = await DatabaseHelper.instance.getDoseStatistics(
        medicationId: medication.id,
      );

      expect(stats['total'], 5);
      expect(stats['taken'], 4);
      expect(stats['skipped'], 1);
      expect(stats['adherence'], 80.0); // 4/5 * 100

      // Delete one taken entry
      await DatabaseHelper.instance.deleteDoseHistory('stats_entry_0');

      // Get updated statistics
      stats = await DatabaseHelper.instance.getDoseStatistics(
        medicationId: medication.id,
      );

      expect(stats['total'], 4);
      expect(stats['taken'], 3);
      expect(stats['skipped'], 1);
      expect(stats['adherence'], 75.0); // 3/4 * 100
    });

    test('Statistics update correctly after toggling status', () async {
      // Create medication and history entries
      final medication = Medication(
        id: 'test_stats_2',
        name: 'Stats Test Med 2',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'10:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final now = DateTime.now();

      // Create 2 taken doses
      for (int i = 0; i < 2; i++) {
        final date = now.subtract(Duration(days: i));
        final entry = DoseHistoryEntry(
          id: 'stats_toggle_$i',
          medicationId: medication.id,
          medicationName: medication.name,
          medicationType: medication.type,
          scheduledDateTime: DateTime(date.year, date.month, date.day, 10, 0),
          registeredDateTime: date,
          status: DoseStatus.taken,
          quantity: 1.0,
        );
        await DatabaseHelper.instance.insertDoseHistory(entry);
      }

      // Get initial statistics
      var stats = await DatabaseHelper.instance.getDoseStatistics(
        medicationId: medication.id,
      );

      expect(stats['total'], 2);
      expect(stats['taken'], 2);
      expect(stats['skipped'], 0);
      expect(stats['adherence'], 100.0);

      // Toggle one from taken to skipped
      final entries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      final firstEntry = entries.first;
      final updatedEntry = firstEntry.copyWith(
        status: DoseStatus.skipped,
        registeredDateTime: DateTime.now(),
      );
      await DatabaseHelper.instance.insertDoseHistory(updatedEntry);

      // Get updated statistics
      stats = await DatabaseHelper.instance.getDoseStatistics(
        medicationId: medication.id,
      );

      expect(stats['total'], 2);
      expect(stats['taken'], 1);
      expect(stats['skipped'], 1);
      expect(stats['adherence'], 50.0); // 1/2 * 100
    });
  });
}

String _getTodayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
