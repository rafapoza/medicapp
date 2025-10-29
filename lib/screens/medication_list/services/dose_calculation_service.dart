import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';
import '../../../models/treatment_duration_type.dart';
import '../../../models/dose_history_entry.dart';
import '../../../database/database_helper.dart';

/// Service for calculating dose-related information
class DoseCalculationService {
  /// Get information about doses taken today for "as needed" medications
  static Future<Map<String, dynamic>?> getAsNeededDosesInfo(Medication medication) async {
    if (medication.durationType != TreatmentDurationType.asNeeded) return null;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final doses = await DatabaseHelper.instance.getDoseHistoryForDateRange(
      startDate: todayStart,
      endDate: todayEnd,
      medicationId: medication.id,
    );

    // Filter to only taken doses (not skipped) registered today
    final takenDosesToday = doses.where((dose) =>
      dose.status == DoseStatus.taken &&
      dose.registeredDateTime.year == now.year &&
      dose.registeredDateTime.month == now.month &&
      dose.registeredDateTime.day == now.day
    ).toList();

    if (takenDosesToday.isEmpty) return null;

    // Sort by registered time (most recent first)
    takenDosesToday.sort((a, b) => b.registeredDateTime.compareTo(a.registeredDateTime));

    final totalQuantity = takenDosesToday.fold<double>(
      0.0,
      (sum, dose) => sum + dose.quantity,
    );

    return {
      'count': takenDosesToday.length,
      'totalQuantity': totalQuantity,
      'lastDoseTime': takenDosesToday.first.registeredDateTime,
      'unit': medication.type.stockUnit,
    };
  }

  /// Get information about the next dose for a medication
  static Map<String, dynamic>? getNextDoseInfo(Medication medication) {
    if (medication.doseTimes.isEmpty) return null;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // If medication should be taken today, find next dose today
    if (medication.shouldTakeToday()) {
      // Get available doses that haven't been taken yet
      final availableDoses = medication.getAvailableDosesToday();

      if (availableDoses.isNotEmpty) {
        // Convert available doses to minutes and sort them
        final availableDosesInMinutes = availableDoses.map((timeString) {
          final parts = timeString.split(':');
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          return {'time': timeString, 'minutes': hours * 60 + minutes};
        }).toList()..sort((a, b) => (a['minutes'] as int).compareTo(b['minutes'] as int));

        // Check if there are pending doses (past time but not taken)
        final pendingDoses = availableDosesInMinutes.where((dose) =>
          (dose['minutes'] as int) <= currentMinutes
        ).toList();

        if (pendingDoses.isNotEmpty) {
          // There's a pending dose - show it in red/orange
          return {
            'date': now,
            'time': pendingDoses.first['time'],
            'isToday': true,
            'isPending': true, // Mark as pending (past due)
          };
        }

        // Find the next available dose time in the future
        for (final dose in availableDosesInMinutes) {
          if ((dose['minutes'] as int) > currentMinutes) {
            return {
              'date': now,
              'time': dose['time'],
              'isToday': true,
              'isPending': false,
            };
          }
        }

        // If all available doses are in the past, find next valid day
        final nextDate = findNextValidDate(medication, now);
        if (nextDate != null) {
          return {
            'date': nextDate,
            'time': medication.doseTimes.first,
            'isToday': false,
            'isPending': false,
          };
        }
        return null;
      }

      // If no available doses today, find next valid day
      final nextDate = findNextValidDate(medication, now);
      if (nextDate != null) {
        return {
          'date': nextDate,
          'time': medication.doseTimes.first,
          'isToday': false,
          'isPending': false,
        };
      }
    } else {
      // Medication shouldn't be taken today, find next valid day
      final nextDate = findNextValidDate(medication, now);
      if (nextDate != null) {
        return {
          'date': nextDate,
          'time': medication.doseTimes.first,
          'isToday': false,
          'isPending': false,
        };
      }
    }

    return null;
  }

  /// Find the next valid date for a medication based on its schedule
  static DateTime? findNextValidDate(Medication medication, DateTime from) {
    switch (medication.durationType) {
      case TreatmentDurationType.specificDates:
        if (medication.selectedDates == null || medication.selectedDates!.isEmpty) {
          return null;
        }

        // Find the next date in the list
        final sortedDates = medication.selectedDates!.toList()..sort();
        for (final dateString in sortedDates) {
          final parts = dateString.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );

          // If date is after today (or today but we have time left)
          if (date.isAfter(DateTime(from.year, from.month, from.day))) {
            return date;
          }
        }
        return null;

      case TreatmentDurationType.weeklyPattern:
        if (medication.weeklyDays == null || medication.weeklyDays!.isEmpty) {
          return null;
        }

        // Find the next occurrence of one of the selected weekdays
        for (int i = 1; i <= 7; i++) {
          final nextDate = from.add(Duration(days: i));
          if (medication.weeklyDays!.contains(nextDate.weekday)) {
            return nextDate;
          }
        }
        return null;

      default:
        // For everyday, untilFinished, custom - always tomorrow if not today
        return from.add(const Duration(days: 1));
    }
  }

  /// Format the next dose information as a user-friendly string
  static String formatNextDose(Map<String, dynamic>? nextDoseInfo, BuildContext context) {
    if (nextDoseInfo == null) return '';

    final l10n = AppLocalizations.of(context)!;
    final date = nextDoseInfo['date'] as DateTime;
    final time = nextDoseInfo['time'] as String;
    final isToday = nextDoseInfo['isToday'] as bool;
    final isPending = nextDoseInfo['isPending'] as bool? ?? false;

    if (isToday) {
      if (isPending) {
        return l10n.pendingDose(time);
      } else {
        return l10n.nextDoseAt(time);
      }
    } else {
      // Format date
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == DateTime(tomorrow.year, tomorrow.month, tomorrow.day)) {
        return l10n.nextDoseTomorrow(time);
      } else {
        // Show day name
        final dayNames = ['', l10n.dayNameMon, l10n.dayNameTue, l10n.dayNameWed, l10n.dayNameThu, l10n.dayNameFri, l10n.dayNameSat, l10n.dayNameSun];
        final dayName = dayNames[date.weekday];
        return l10n.nextDoseOnDay(dayName, date.day, date.month, time);
      }
    }
  }

  /// Calculate total daily consumption for "as needed" medications
  ///
  /// Returns the total quantity consumed today plus any additional quantity.
  /// This is useful for tracking lastDailyConsumption when registering manual doses.
  ///
  /// Returns null if the medication is not "as needed" type.
  static Future<double?> calculateDailyConsumption(
    Medication medication, {
    double additionalQuantity = 0.0,
  }) async {
    if (medication.durationType != TreatmentDurationType.asNeeded) {
      return null;
    }

    final now = DateTime.now();
    final todayHistory = await DatabaseHelper.instance.getDoseHistoryForDateRange(
      medicationId: medication.id,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    // Calculate total consumption for today (including the additional quantity)
    final existingConsumption = todayHistory
        .where((entry) => entry.status == DoseStatus.taken)
        .fold(0.0, (sum, entry) => sum + entry.quantity);

    return existingConsumption + additionalQuantity;
  }
}
