import '../models/medication.dart';
import '../models/dose_history_entry.dart';
import '../database/database_helper.dart';

/// Service for managing dose history entries
/// This centralizes history-related operations to avoid duplication across screens
class DoseHistoryService {
  /// Delete a dose history entry and update medication if needed
  ///
  /// If the entry is from today, this method will:
  /// - Remove the dose from taken/skipped lists
  /// - Restore stock if the dose was taken
  /// - Update the medication in the database
  ///
  /// Throws [MedicationNotFoundException] if medication doesn't exist
  static Future<void> deleteHistoryEntry(DoseHistoryEntry entry) async {
    // Get the medication
    final medication = await DatabaseHelper.instance.getMedication(entry.medicationId);

    if (medication == null) {
      throw MedicationNotFoundException(entry.medicationId);
    }

    // Check if entry is from today
    final now = DateTime.now();
    final isToday = entry.scheduledDateTime.year == now.year &&
        entry.scheduledDateTime.month == now.month &&
        entry.scheduledDateTime.day == now.day;

    if (isToday) {
      // Remove from taken or skipped doses
      final doseTime = entry.scheduledTimeFormatted;
      List<String> takenDoses = List.from(medication.takenDosesToday);
      List<String> skippedDoses = List.from(medication.skippedDosesToday);

      takenDoses.remove(doseTime);
      skippedDoses.remove(doseTime);

      // Restore stock if it was taken
      double newStock = medication.stockQuantity;
      if (entry.status == DoseStatus.taken) {
        newStock += entry.quantity;
      }

      // Update medication
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: newStock,
        takenDosesToday: takenDoses,
        skippedDosesToday: skippedDoses,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);
    }

    // Delete history entry
    await DatabaseHelper.instance.deleteDoseHistory(entry.id);
  }

  /// Change the status of a dose history entry (taken ↔ skipped)
  ///
  /// Creates a new entry with updated status and current timestamp
  /// Returns the updated entry
  static Future<DoseHistoryEntry> changeEntryStatus(
    DoseHistoryEntry entry,
    DoseStatus newStatus,
  ) async {
    // Create updated entry
    final updatedEntry = entry.copyWith(
      status: newStatus,
      registeredDateTime: DateTime.now(), // Update registered time
    );

    // Update in database
    await DatabaseHelper.instance.insertDoseHistory(updatedEntry);

    return updatedEntry;
  }
}

/// Exception thrown when a medication is not found in the database
class MedicationNotFoundException implements Exception {
  final String medicationId;

  MedicationNotFoundException(this.medicationId);

  @override
  String toString() => 'Medication not found: $medicationId';
}
