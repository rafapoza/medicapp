import '../models/medication.dart';
import '../models/treatment_duration_type.dart';

class MedicationSorter {
  /// Get the absolute DateTime for the next dose of a medication
  /// Returns null if there's no next dose
  static DateTime? getNextDoseDateTime(Medication medication, DateTime now) {
    final nextDoseInfo = _getNextDoseInfo(medication, now);
    if (nextDoseInfo == null) return null;

    final date = nextDoseInfo['date'] as DateTime;
    final timeString = nextDoseInfo['time'] as String;

    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Sort medications by proximity of next dose
  /// Priority: 1) Pending doses (overdue), 2) Future doses (by proximity), 3) No dose
  static void sortByNextDose(List<Medication> medications, {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();

    medications.sort((a, b) {
      final aNextDose = getNextDoseDateTime(a, now);
      final bNextDose = getNextDoseDateTime(b, now);

      // Medications without next dose go to the end
      if (aNextDose == null && bNextDose == null) return 0;
      if (aNextDose == null) return 1;
      if (bNextDose == null) return -1;

      final aDiff = aNextDose.difference(now).inMinutes;
      final bDiff = bNextDose.difference(now).inMinutes;

      // Both are pending (overdue) - sort by most overdue first (more negative = more overdue)
      if (aDiff < 0 && bDiff < 0) {
        return aDiff.compareTo(bDiff);
      }

      // Both are future - sort by closest first
      if (aDiff >= 0 && bDiff >= 0) {
        return aDiff.compareTo(bDiff);
      }

      // One is pending, one is future - pending comes first
      if (aDiff < 0) return -1;
      return 1;
    });
  }

  // Private helper methods similar to medication_list_screen.dart

  static Map<String, dynamic>? _getNextDoseInfo(Medication medication, DateTime now) {
    if (medication.doseTimes.isEmpty) return null;

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
            'isPending': true,
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
        final nextDate = _findNextValidDate(medication, now);
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
      final nextDate = _findNextValidDate(medication, now);
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
      final nextDate = _findNextValidDate(medication, now);
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

  static DateTime? _findNextValidDate(Medication medication, DateTime from) {
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
}
