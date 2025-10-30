import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/models/dose_history_entry.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/dose_history_service.dart';
import 'helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DatabaseTestHelper.setup();

  group('DoseHistoryService - deleteHistoryEntry', () {
    test('should delete history entry from today and restore stock for taken dose', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Create medication with taken dose today
      final medication = Medication(
        id: 'med1',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 9.0, // Stock was reduced when dose was taken
        takenDosesToday: ['08:00'],
        takenDosesDate: todayString,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Create history entry for today's taken dose
      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);
      final historyEntry = DoseHistoryEntry(
        id: 'entry1',
        medicationId: 'med1',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Delete the entry
      await DoseHistoryService.deleteHistoryEntry(historyEntry);

      // Verify entry was deleted from history
      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med1');
      expect(history.length, 0);

      // Verify medication was updated
      final updatedMed = await DatabaseHelper.instance.getMedication('med1');
      expect(updatedMed, isNotNull);
      expect(updatedMed!.stockQuantity, 10.0); // Stock restored
      expect(updatedMed.takenDosesToday, isEmpty); // Removed from taken list
    });

    test('should delete history entry from today and NOT restore stock for skipped dose', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'med2',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0, // Stock unchanged because dose was skipped
        skippedDosesToday: ['08:00'],
        takenDosesDate: todayString,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);
      final historyEntry = DoseHistoryEntry(
        id: 'entry2',
        medicationId: 'med2',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.skipped,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      await DoseHistoryService.deleteHistoryEntry(historyEntry);

      final updatedMed = await DatabaseHelper.instance.getMedication('med2');
      expect(updatedMed!.stockQuantity, 10.0); // Stock unchanged
      expect(updatedMed.skippedDosesToday, isEmpty); // Removed from skipped list
    });

    test('should delete history entry from past without updating medication', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'med3',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 9.0,
        takenDosesToday: ['08:00'], // Today's dose
        takenDosesDate: todayString,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Create history entry for yesterday
      final scheduledTime = DateTime(yesterday.year, yesterday.month, yesterday.day, 8, 0);
      final historyEntry = DoseHistoryEntry(
        id: 'entry3',
        medicationId: 'med3',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      await DoseHistoryService.deleteHistoryEntry(historyEntry);

      // Entry should be deleted
      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med3');
      expect(history.length, 0);

      // Medication should remain unchanged (no stock restoration, lists unchanged)
      final updatedMed = await DatabaseHelper.instance.getMedication('med3');
      expect(updatedMed!.stockQuantity, 9.0); // Stock NOT restored
      expect(updatedMed.takenDosesToday, ['08:00']); // Today's list unchanged
    });

    test('should throw MedicationNotFoundException when medication does not exist', () async {
      final today = DateTime.now();
      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);

      final historyEntry = DoseHistoryEntry(
        id: 'entry4',
        medicationId: 'nonexistent',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      expect(
        () => DoseHistoryService.deleteHistoryEntry(historyEntry),
        throwsA(isA<MedicationNotFoundException>()),
      );
    });

    test('should handle multiple doses in taken list when deleting one', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'med5',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0, '22:00': 1.0},
        stockQuantity: 7.0,
        takenDosesToday: ['08:00', '16:00', '22:00'],
        takenDosesDate: todayString,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final scheduledTime = DateTime(today.year, today.month, today.day, 16, 0);
      final historyEntry = DoseHistoryEntry(
        id: 'entry5',
        medicationId: 'med5',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);
      await DoseHistoryService.deleteHistoryEntry(historyEntry);

      final updatedMed = await DatabaseHelper.instance.getMedication('med5');
      expect(updatedMed!.stockQuantity, 8.0);
      expect(updatedMed.takenDosesToday, ['08:00', '22:00']); // Only 16:00 removed
      expect(updatedMed.takenDosesToday.length, 2);
    });

    test('should handle fractional dose quantities when restoring stock', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'med6',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 0.5},
        stockQuantity: 9.5,
        takenDosesToday: ['08:00'],
        takenDosesDate: todayString,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);
      final historyEntry = DoseHistoryEntry(
        id: 'entry6',
        medicationId: 'med6',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.taken,
        quantity: 0.5,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);
      await DoseHistoryService.deleteHistoryEntry(historyEntry);

      final updatedMed = await DatabaseHelper.instance.getMedication('med6');
      expect(updatedMed!.stockQuantity, 10.0); // 9.5 + 0.5 = 10.0
    });
  });

  group('DoseHistoryService - changeEntryStatus', () {
    test('should change status from taken to skipped', () async {
      final today = DateTime.now();
      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);

      final originalEntry = DoseHistoryEntry(
        id: 'entry7',
        medicationId: 'med7',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(originalEntry);

      // Change status
      final updatedEntry = await DoseHistoryService.changeEntryStatus(
        originalEntry,
        DoseStatus.skipped,
      );

      // Verify updated entry
      expect(updatedEntry.id, originalEntry.id);
      expect(updatedEntry.status, DoseStatus.skipped);
      expect(updatedEntry.scheduledDateTime, scheduledTime);
      expect(
        updatedEntry.registeredDateTime.isAfter(scheduledTime) ||
            updatedEntry.registeredDateTime.isAtSameMomentAs(scheduledTime),
        true,
      );

      // Verify it was saved to database
      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med7');
      expect(history.length, 1);
      expect(history.first.status, DoseStatus.skipped);
    });

    test('should change status from skipped to taken', () async {
      final today = DateTime.now();
      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);

      final originalEntry = DoseHistoryEntry(
        id: 'entry8',
        medicationId: 'med8',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.skipped,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(originalEntry);

      final updatedEntry = await DoseHistoryService.changeEntryStatus(
        originalEntry,
        DoseStatus.taken,
      );

      expect(updatedEntry.status, DoseStatus.taken);

      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med8');
      expect(history.first.status, DoseStatus.taken);
    });

    test('should update registeredDateTime when changing status', () async {
      final today = DateTime.now();
      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);
      final originalRegisteredTime = today.subtract(const Duration(minutes: 30));

      final originalEntry = DoseHistoryEntry(
        id: 'entry9',
        medicationId: 'med9',
        medicationName: 'Test Med',
        medicationType: MedicationType.pill,
        scheduledDateTime: scheduledTime,
        registeredDateTime: originalRegisteredTime,
        status: DoseStatus.taken,
        quantity: 1.0,
      );

      await DatabaseHelper.instance.insertDoseHistory(originalEntry);

      // Small delay to ensure time difference
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedEntry = await DoseHistoryService.changeEntryStatus(
        originalEntry,
        DoseStatus.skipped,
      );

      // Registered time should be updated (later than original)
      expect(updatedEntry.registeredDateTime.isAfter(originalRegisteredTime), true);
    });

    test('should preserve all other fields when changing status', () async {
      final today = DateTime.now();
      final scheduledTime = DateTime(today.year, today.month, today.day, 8, 0);

      final originalEntry = DoseHistoryEntry(
        id: 'entry10',
        medicationId: 'med10',
        medicationName: 'Special Med',
        medicationType: MedicationType.injection,
        scheduledDateTime: scheduledTime,
        registeredDateTime: scheduledTime,
        status: DoseStatus.taken,
        quantity: 2.5,
        notes: 'Test notes',
      );

      await DatabaseHelper.instance.insertDoseHistory(originalEntry);

      final updatedEntry = await DoseHistoryService.changeEntryStatus(
        originalEntry,
        DoseStatus.skipped,
      );

      // Verify all fields except status and registeredDateTime are preserved
      expect(updatedEntry.id, originalEntry.id);
      expect(updatedEntry.medicationId, originalEntry.medicationId);
      expect(updatedEntry.medicationName, originalEntry.medicationName);
      expect(updatedEntry.medicationType, originalEntry.medicationType);
      expect(updatedEntry.scheduledDateTime, originalEntry.scheduledDateTime);
      expect(updatedEntry.quantity, originalEntry.quantity);
      expect(updatedEntry.notes, originalEntry.notes);
      expect(updatedEntry.status, DoseStatus.skipped); // Changed
    });
  });

  group('MedicationNotFoundException', () {
    test('should contain medication ID in exception', () {
      final exception = MedicationNotFoundException('test-id-123');
      expect(exception.medicationId, 'test-id-123');
    });

    test('should have descriptive toString', () {
      final exception = MedicationNotFoundException('test-id-123');
      expect(exception.toString(), contains('test-id-123'));
      expect(exception.toString(), contains('Medication not found'));
    });
  });
}
