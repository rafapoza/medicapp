import '../models/medication.dart';
import '../models/dose_history_entry.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

/// Service for handling dose registration actions (taken, skipped, manual)
/// This centralizes the logic to avoid duplication across multiple screens
class DoseActionService {
  /// Register a taken dose for a scheduled medication
  static Future<Medication> registerTakenDose({
    required Medication medication,
    required String doseTime,
  }) async {
    final doseQuantity = medication.getDoseQuantity(doseTime);

    // Validate stock
    if (medication.stockQuantity < doseQuantity) {
      throw InsufficientStockException(
        doseQuantity: doseQuantity,
        availableStock: medication.stockQuantity,
        unit: medication.type.stockUnit,
      );
    }

    final today = DateTime.now();
    final todayString = _getTodayString(today);

    // Update taken doses for today
    List<String> updatedTakenDoses;
    List<String> updatedSkippedDoses = List.from(medication.skippedDosesToday);

    if (medication.takenDosesDate == todayString) {
      updatedTakenDoses = List.from(medication.takenDosesToday);
      updatedTakenDoses.add(doseTime);
    } else {
      updatedTakenDoses = [doseTime];
      updatedSkippedDoses = [];
    }

    // Create updated medication
    final updatedMedication = Medication(
      id: medication.id,
      name: medication.name,
      type: medication.type,
      dosageIntervalHours: medication.dosageIntervalHours,
      durationType: medication.durationType,
      doseSchedule: medication.doseSchedule,
      stockQuantity: medication.stockQuantity - doseQuantity,
      takenDosesToday: updatedTakenDoses,
      skippedDosesToday: updatedSkippedDoses,
      takenDosesDate: todayString,
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // Save to history
    final scheduledDateTime = _parseDoseDateTime(today, doseTime);
    final historyEntry = DoseHistoryEntry(
      id: '${medication.id}_${DateTime.now().millisecondsSinceEpoch}',
      medicationId: medication.id,
      medicationName: medication.name,
      medicationType: medication.type,
      scheduledDateTime: scheduledDateTime,
      registeredDateTime: DateTime.now(),
      status: DoseStatus.taken,
      quantity: doseQuantity,
    );

    await DatabaseHelper.instance.insertDoseHistory(historyEntry);

    // Handle notifications
    await _handleTakenDoseNotifications(updatedMedication, doseTime, DateTime.now());

    return updatedMedication;
  }

  /// Register a skipped dose for a scheduled medication
  static Future<Medication> registerSkippedDose({
    required Medication medication,
    required String doseTime,
  }) async {
    final today = DateTime.now();
    final todayString = _getTodayString(today);
    final doseQuantity = medication.getDoseQuantity(doseTime);

    // Update skipped doses for today
    List<String> updatedSkippedDoses;
    List<String> updatedTakenDoses = List.from(medication.takenDosesToday);

    if (medication.takenDosesDate == todayString) {
      updatedSkippedDoses = List.from(medication.skippedDosesToday);
      updatedSkippedDoses.add(doseTime);
    } else {
      updatedSkippedDoses = [doseTime];
      updatedTakenDoses = [];
    }

    // Create updated medication
    final updatedMedication = Medication(
      id: medication.id,
      name: medication.name,
      type: medication.type,
      dosageIntervalHours: medication.dosageIntervalHours,
      durationType: medication.durationType,
      doseSchedule: medication.doseSchedule,
      stockQuantity: medication.stockQuantity,
      takenDosesToday: updatedTakenDoses,
      skippedDosesToday: updatedSkippedDoses,
      takenDosesDate: todayString,
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // Save to history
    final scheduledDateTime = _parseDoseDateTime(today, doseTime);
    final historyEntry = DoseHistoryEntry(
      id: '${medication.id}_${DateTime.now().millisecondsSinceEpoch}',
      medicationId: medication.id,
      medicationName: medication.name,
      medicationType: medication.type,
      scheduledDateTime: scheduledDateTime,
      registeredDateTime: DateTime.now(),
      status: DoseStatus.skipped,
      quantity: doseQuantity,
    );

    await DatabaseHelper.instance.insertDoseHistory(historyEntry);

    // Handle notifications
    await _handleSkippedDoseNotifications(updatedMedication, doseTime);

    return updatedMedication;
  }

  /// Register a manual dose for "as needed" medications
  static Future<Medication> registerManualDose({
    required Medication medication,
    required double quantity,
    double? lastDailyConsumption,
  }) async {
    // Validate stock
    if (medication.stockQuantity < quantity) {
      throw InsufficientStockException(
        doseQuantity: quantity,
        availableStock: medication.stockQuantity,
        unit: medication.type.stockUnit,
      );
    }

    // Create updated medication with reduced stock
    final updatedMedication = Medication(
      id: medication.id,
      name: medication.name,
      type: medication.type,
      dosageIntervalHours: medication.dosageIntervalHours,
      durationType: medication.durationType,
      doseSchedule: medication.doseSchedule,
      stockQuantity: medication.stockQuantity - quantity,
      takenDosesToday: medication.takenDosesToday,
      skippedDosesToday: medication.skippedDosesToday,
      takenDosesDate: medication.takenDosesDate,
      lastDailyConsumption: lastDailyConsumption,
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
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // Save to history
    final now = DateTime.now();
    final historyEntry = DoseHistoryEntry(
      id: '${medication.id}_${now.millisecondsSinceEpoch}',
      medicationId: medication.id,
      medicationName: medication.name,
      medicationType: medication.type,
      scheduledDateTime: now,
      registeredDateTime: now,
      status: DoseStatus.taken,
      quantity: quantity,
    );

    await DatabaseHelper.instance.insertDoseHistory(historyEntry);

    // Handle fasting notifications
    if (updatedMedication.requiresFasting &&
        updatedMedication.fastingType == 'after' &&
        updatedMedication.notifyFasting) {
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: updatedMedication,
        actualDoseTime: now,
      );
    }

    return updatedMedication;
  }

  /// Register an extra dose for scheduled medications (outside of regular schedule)
  static Future<Medication> registerExtraDose({
    required Medication medication,
    required double quantity,
  }) async {
    // Validate stock
    if (medication.stockQuantity < quantity) {
      throw InsufficientStockException(
        doseQuantity: quantity,
        availableStock: medication.stockQuantity,
        unit: medication.type.stockUnit,
      );
    }

    final now = DateTime.now();
    final todayString = _getTodayString(now);
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Update extra doses for today
    List<String> updatedExtraDoses;
    List<String> updatedTakenDoses = List.from(medication.takenDosesToday);
    List<String> updatedSkippedDoses = List.from(medication.skippedDosesToday);

    if (medication.takenDosesDate == todayString) {
      updatedExtraDoses = List.from(medication.extraDosesToday);
      updatedExtraDoses.add(currentTime);
    } else {
      // New day, reset all lists
      updatedExtraDoses = [currentTime];
      updatedTakenDoses = [];
      updatedSkippedDoses = [];
    }

    // Create updated medication with reduced stock
    final updatedMedication = Medication(
      id: medication.id,
      name: medication.name,
      type: medication.type,
      dosageIntervalHours: medication.dosageIntervalHours,
      durationType: medication.durationType,
      doseSchedule: medication.doseSchedule,
      stockQuantity: medication.stockQuantity - quantity,
      takenDosesToday: updatedTakenDoses,
      skippedDosesToday: updatedSkippedDoses,
      extraDosesToday: updatedExtraDoses,
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

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // Save to history with isExtraDose=true
    final historyEntry = DoseHistoryEntry(
      id: '${medication.id}_${now.millisecondsSinceEpoch}',
      medicationId: medication.id,
      medicationName: medication.name,
      medicationType: medication.type,
      scheduledDateTime: now, // For extra doses, scheduled time = actual time
      registeredDateTime: now,
      status: DoseStatus.taken,
      quantity: quantity,
      isExtraDose: true,
    );

    await DatabaseHelper.instance.insertDoseHistory(historyEntry);

    // Handle fasting notifications for "after" type
    if (updatedMedication.requiresFasting &&
        updatedMedication.fastingType == 'after' &&
        updatedMedication.notifyFasting) {
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: updatedMedication,
        actualDoseTime: now,
      );
    }

    return updatedMedication;
  }

  // Private helper methods

  static String _getTodayString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _parseDoseDateTime(DateTime date, String timeString) {
    final parts = timeString.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static Future<void> _handleTakenDoseNotifications(
    Medication medication,
    String doseTime,
    DateTime actualDoseTime,
  ) async {
    // Cancel today's notification for this specific dose
    await NotificationService.instance.cancelTodaysDoseNotification(
      medication: medication,
      doseTime: doseTime,
    );

    // Reschedule medication notifications to restore future notifications
    // Use excludeToday: true to prevent rescheduling for today (dose already taken)
    await NotificationService.instance.scheduleMedicationNotifications(
      medication,
      excludeToday: true,
    );

    // Cancel today's fasting notification if needed
    await NotificationService.instance.cancelTodaysFastingNotification(
      medication: medication,
      doseTime: doseTime,
    );

    // Schedule dynamic fasting notification if required
    if (medication.requiresFasting &&
        medication.fastingType == 'after' &&
        medication.notifyFasting) {
      await NotificationService.instance.scheduleDynamicFastingNotification(
        medication: medication,
        actualDoseTime: actualDoseTime,
      );
    }
  }

  static Future<void> _handleSkippedDoseNotifications(
    Medication medication,
    String doseTime,
  ) async {
    // Cancel today's notification for this specific dose
    await NotificationService.instance.cancelTodaysDoseNotification(
      medication: medication,
      doseTime: doseTime,
    );

    // Reschedule medication notifications
    // Use excludeToday: true to prevent rescheduling for today (dose already skipped)
    await NotificationService.instance.scheduleMedicationNotifications(
      medication,
      excludeToday: true,
    );

    // Cancel today's fasting notification
    await NotificationService.instance.cancelTodaysFastingNotification(
      medication: medication,
      doseTime: doseTime,
    );
  }
}

/// Exception thrown when there's insufficient stock for a dose
class InsufficientStockException implements Exception {
  final double doseQuantity;
  final double availableStock;
  final String unit;

  InsufficientStockException({
    required this.doseQuantity,
    required this.availableStock,
    required this.unit,
  });

  @override
  String toString() =>
      'Insufficient stock: need $doseQuantity $unit, but only $availableStock $unit available';
}
