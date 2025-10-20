import 'dart:convert';
import 'package:intl/intl.dart';
import 'medication_type.dart';
import 'treatment_duration_type.dart';

class Medication {
  final String id;
  final String name;
  final MedicationType type;
  final int dosageIntervalHours;
  final TreatmentDurationType durationType;
  final Map<String, double> doseSchedule; // Map of time -> dose quantity in "HH:mm" -> quantity format
  final double stockQuantity; // Quantity of medication in stock
  final List<String> takenDosesToday; // List of doses taken today in "HH:mm" format (reduces stock)
  final List<String> skippedDosesToday; // List of doses skipped today in "HH:mm" format (doesn't reduce stock)
  final String? takenDosesDate; // Date when doses were taken/skipped in "yyyy-MM-dd" format
  final double? lastRefillAmount; // Last refill amount (used as suggestion for future refills)
  final int lowStockThresholdDays; // Days before running out to show low stock warning
  final List<String>? selectedDates; // Specific dates for specificDates type in "yyyy-MM-dd" format
  final List<int>? weeklyDays; // Days of week (1=Mon, 7=Sun) for weeklyPattern type
  final int? dayInterval; // Interval in days for intervalDays type (e.g., 2 for every 2 days)
  final DateTime? startDate; // When the treatment starts
  final DateTime? endDate; // When the treatment ends

  // Fasting configuration
  final bool requiresFasting; // Whether medication requires fasting
  final String? fastingType; // 'before' or 'after' - when fasting is required
  final int? fastingDurationMinutes; // Duration of fasting period in minutes
  final bool notifyFasting; // Whether to send fasting notifications

  // Suspension status
  final bool isSuspended; // Whether medication is temporarily suspended (no notifications, but kept in inventory)

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dosageIntervalHours,
    required this.durationType,
    Map<String, double>? doseSchedule,
    this.stockQuantity = 0,
    this.takenDosesToday = const [],
    this.skippedDosesToday = const [],
    this.takenDosesDate,
    this.lastRefillAmount,
    this.lowStockThresholdDays = 3, // Default to 3 days
    this.selectedDates, // Specific dates for specificDates type
    this.weeklyDays, // Days of week for weeklyPattern type
    this.dayInterval, // Interval in days for intervalDays type
    this.startDate, // Treatment start date
    this.endDate, // Treatment end date
    this.requiresFasting = false, // Default to no fasting
    this.fastingType, // 'before' or 'after'
    this.fastingDurationMinutes, // Duration in minutes
    this.notifyFasting = false, // Default to no notifications
    this.isSuspended = false, // Default to not suspended
  }) : doseSchedule = doseSchedule ?? {};

  /// Legacy compatibility: get list of dose times (keys from doseSchedule)
  List<String> get doseTimes => doseSchedule.keys.toList()..sort();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'dosageIntervalHours': dosageIntervalHours,
      'durationType': durationType.name,
      'doseTimes': doseTimes.join(','), // Legacy format (kept for database compatibility)
      'doseSchedule': jsonEncode(doseSchedule), // Store as JSON string
      'stockQuantity': stockQuantity,
      'takenDosesToday': takenDosesToday.join(','), // Store as comma-separated string
      'skippedDosesToday': skippedDosesToday.join(','), // Store as comma-separated string
      'takenDosesDate': takenDosesDate,
      'lastRefillAmount': lastRefillAmount,
      'lowStockThresholdDays': lowStockThresholdDays,
      'selectedDates': selectedDates?.join(','), // Store as comma-separated string
      'weeklyDays': weeklyDays?.join(','), // Store as comma-separated string
      'dayInterval': dayInterval, // Interval in days for intervalDays type
      'startDate': startDate?.toIso8601String(), // Phase 2: Store as ISO8601 string
      'endDate': endDate?.toIso8601String(), // Phase 2: Store as ISO8601 string
      'requiresFasting': requiresFasting ? 1 : 0, // Store as integer (SQLite doesn't have boolean)
      'fastingType': fastingType, // 'before' or 'after'
      'fastingDurationMinutes': fastingDurationMinutes,
      'notifyFasting': notifyFasting ? 1 : 0, // Store as integer
      'isSuspended': isSuspended ? 1 : 0, // Store as integer
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    // Parse dose schedule
    Map<String, double> doseSchedule = {};

    // Try to parse from new doseSchedule field (JSON format)
    final doseScheduleString = json['doseSchedule'] as String?;
    if (doseScheduleString != null && doseScheduleString.isNotEmpty) {
      try {
        final decoded = jsonDecode(doseScheduleString) as Map<String, dynamic>;
        doseSchedule = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } catch (e) {
        print('Error parsing doseSchedule: $e');
      }
    } else {
      // Legacy: migrate from old doseTimes format (comma-separated string)
      // Assume 1.0 dose quantity for each time
      final doseTimesString = json['doseTimes'] as String?;
      if (doseTimesString != null && doseTimesString.isNotEmpty) {
        final doseTimes = doseTimesString.split(',');
        for (final time in doseTimes) {
          if (time.isNotEmpty) {
            doseSchedule[time] = 1.0; // Default dose quantity
          }
        }
      }
    }

    // Parse taken doses today from comma-separated string
    final takenDosesTodayString = json['takenDosesToday'] as String?;
    final takenDosesToday = takenDosesTodayString != null && takenDosesTodayString.isNotEmpty
        ? takenDosesTodayString.split(',').where((s) => s.isNotEmpty).toList()
        : <String>[];

    // Parse skipped doses today from comma-separated string
    final skippedDosesTodayString = json['skippedDosesToday'] as String?;
    final skippedDosesToday = skippedDosesTodayString != null && skippedDosesTodayString.isNotEmpty
        ? skippedDosesTodayString.split(',').where((s) => s.isNotEmpty).toList()
        : <String>[];

    // Parse selected dates from comma-separated string
    final selectedDatesString = json['selectedDates'] as String?;
    final selectedDates = selectedDatesString != null && selectedDatesString.isNotEmpty
        ? selectedDatesString.split(',').where((s) => s.isNotEmpty).toList()
        : null;

    // Parse weekly days from comma-separated string
    final weeklyDaysString = json['weeklyDays'] as String?;
    final weeklyDays = weeklyDaysString != null && weeklyDaysString.isNotEmpty
        ? weeklyDaysString.split(',').where((s) => s.isNotEmpty).map((s) => int.parse(s)).toList()
        : null;

    // Parse day interval (for intervalDays type)
    final dayInterval = json['dayInterval'] as int?;

    // Parse start and end dates (Phase 2)
    final startDateString = json['startDate'] as String?;
    final startDate = startDateString != null && startDateString.isNotEmpty
        ? DateTime.parse(startDateString)
        : null;

    final endDateString = json['endDate'] as String?;
    final endDate = endDateString != null && endDateString.isNotEmpty
        ? DateTime.parse(endDateString)
        : null;

    // Parse fasting fields
    final requiresFasting = (json['requiresFasting'] as int?) == 1;
    final fastingType = json['fastingType'] as String?;
    final fastingDurationMinutes = json['fastingDurationMinutes'] as int?;
    final notifyFasting = (json['notifyFasting'] as int?) == 1;

    // Parse suspension status
    final isSuspended = (json['isSuspended'] as int?) == 1;

    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MedicationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MedicationType.pastilla,
      ),
      dosageIntervalHours: json['dosageIntervalHours'] as int? ?? 8,
      durationType: TreatmentDurationType.values.firstWhere(
        (e) => e.name == json['durationType'],
        orElse: () => TreatmentDurationType.everyday,
      ),
      doseSchedule: doseSchedule,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0,
      takenDosesToday: takenDosesToday,
      skippedDosesToday: skippedDosesToday,
      takenDosesDate: json['takenDosesDate'] as String?,
      lastRefillAmount: (json['lastRefillAmount'] as num?)?.toDouble(),
      lowStockThresholdDays: json['lowStockThresholdDays'] as int? ?? 3, // Default to 3 days for backward compatibility
      selectedDates: selectedDates,
      weeklyDays: weeklyDays,
      dayInterval: dayInterval,
      startDate: startDate, // Phase 2
      endDate: endDate, // Phase 2
      requiresFasting: requiresFasting,
      fastingType: fastingType,
      fastingDurationMinutes: fastingDurationMinutes,
      notifyFasting: notifyFasting,
      isSuspended: isSuspended,
    );
  }

  String get durationDisplayText {
    switch (durationType) {
      case TreatmentDurationType.everyday:
        return 'Todos los días';
      case TreatmentDurationType.untilFinished:
        return 'Hasta acabar';
      case TreatmentDurationType.specificDates:
        final count = selectedDates?.length ?? 0;
        return '$count fecha${count != 1 ? 's' : ''} específica${count != 1 ? 's' : ''}';
      case TreatmentDurationType.weeklyPattern:
        final count = weeklyDays?.length ?? 0;
        return '$count día${count != 1 ? 's' : ''} por semana';
      case TreatmentDurationType.intervalDays:
        final interval = dayInterval ?? 2;
        return 'Cada $interval días';
    }
  }

  /// Check if medication should be taken today based on duration type
  bool shouldTakeToday() {
    // Phase 2: Check if treatment is active (not pending or finished)
    if (!isActive) return false;

    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    switch (durationType) {
      case TreatmentDurationType.everyday:
        return true;
      case TreatmentDurationType.untilFinished:
        return stockQuantity > 0;
      case TreatmentDurationType.specificDates:
        return selectedDates?.contains(todayString) ?? false;
      case TreatmentDurationType.weeklyPattern:
        // Monday = 1, Sunday = 7
        final weekday = today.weekday;
        return weeklyDays?.contains(weekday) ?? false;
      case TreatmentDurationType.intervalDays:
        // Calculate days since start date
        final interval = dayInterval ?? 2;
        final start = startDate ?? DateTime(today.year, today.month, today.day);
        final startDay = DateTime(start.year, start.month, start.day);
        final todayDay = DateTime(today.year, today.month, today.day);
        final daysSinceStart = todayDay.difference(startDay).inDays;
        // Take medication if days since start is divisible by interval
        return daysSinceStart % interval == 0;
    }
  }

  /// Get the stock display text with proper units
  String get stockDisplayText {
    if (stockQuantity == 0) {
      return 'Sin stock';
    }

    // Format the number without unnecessary decimals
    final formattedQuantity = stockQuantity == stockQuantity.toInt()
        ? stockQuantity.toInt().toString()
        : stockQuantity.toStringAsFixed(1);

    final unit = stockQuantity == 1 ? type.stockUnitSingular : type.stockUnit;
    return '$formattedQuantity $unit';
  }

  /// Get total daily dose quantity
  double get totalDailyDose {
    if (doseSchedule.isEmpty) return 0;
    return doseSchedule.values.fold(0.0, (sum, dose) => sum + dose);
  }

  /// Check if stock is low (less than the configured threshold days worth of medication)
  bool get isStockLow {
    if (doseSchedule.isEmpty) return false;

    final dailyDose = totalDailyDose;
    if (dailyDose == 0) return false;

    // Consider stock low if less than threshold days worth
    final thresholdDaysWorth = dailyDose * lowStockThresholdDays;

    return stockQuantity > 0 && stockQuantity < thresholdDaysWorth;
  }

  /// Check if stock is empty
  bool get isStockEmpty {
    return stockQuantity <= 0;
  }

  /// Get the dose quantity for a specific time
  double getDoseQuantity(String time) {
    return doseSchedule[time] ?? 1.0; // Default to 1.0 if not found
  }

  /// Get available doses (doses that haven't been taken or skipped today)
  List<String> getAvailableDosesToday() {
    // First check if medication should be taken today
    if (!shouldTakeToday()) {
      return []; // No doses available if medication shouldn't be taken today
    }

    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // If the taken doses date is not today, all doses are available
    if (takenDosesDate != todayString) {
      return List.from(doseTimes);
    }

    // Filter out the doses that have been taken or skipped today
    return doseTimes.where((doseTime) =>
      !takenDosesToday.contains(doseTime) && !skippedDosesToday.contains(doseTime)
    ).toList();
  }

  /// Check if the taken doses date is today
  bool get isTakenDosesDateToday {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return takenDosesDate == todayString;
  }

  // ==================== Phase 2: Treatment Status and Progress ====================

  /// Check if treatment hasn't started yet (startDate is in the future)
  bool get isPending {
    if (startDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    return today.isBefore(start);
  }

  /// Check if treatment has finished (endDate is in the past)
  bool get isFinished {
    if (endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return today.isAfter(end);
  }

  /// Check if treatment is currently active (between startDate and endDate, or no dates set)
  bool get isActive => !isPending && !isFinished;

  /// Get total days of treatment (if both startDate and endDate are set)
  int? get totalDays {
    if (startDate == null || endDate == null) return null;
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return end.difference(start).inDays + 1; // +1 to include both start and end days
  }

  /// Get current day of treatment (1-indexed)
  int? get currentDay {
    if (startDate == null || !isActive) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    return today.difference(start).inDays + 1; // +1 to start from day 1
  }

  /// Get remaining days of treatment
  int? get remainingDays {
    if (endDate == null || !isActive) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    final remaining = end.difference(today).inDays + 1; // +1 to include end day
    return remaining > 0 ? remaining : 0;
  }

  /// Get treatment progress as a percentage (0.0 to 1.0)
  double? get progress {
    if (totalDays == null || currentDay == null) return null;
    if (totalDays == 0) return 1.0;
    return (currentDay! / totalDays!).clamp(0.0, 1.0);
  }

  /// Check if medication allows manual dose registration (for "as needed" medications)
  /// Returns true if medication doesn't have active scheduled doses
  bool get allowsManualDoseRegistration {
    // Suspended medications can register manual doses
    if (isSuspended) return true;

    // Pending or finished medications can register manual doses
    if (isPending || isFinished) return true;

    // Medications without configured dose times can register manual doses
    if (doseTimes.isEmpty) return true;

    // Medications that shouldn't be taken today can register manual doses
    if (!shouldTakeToday()) return true;

    // Otherwise, use regular dose registration
    return false;
  }

  /// Get status description for UI
  String get statusDescription {
    if (isPending) {
      final formatter = DateFormat('d MMM yyyy', 'es_ES');
      return 'Empieza el ${formatter.format(startDate!)}';
    }
    if (isFinished) {
      final formatter = DateFormat('d MMM yyyy', 'es_ES');
      return 'Finalizado el ${formatter.format(endDate!)}';
    }
    if (isActive && currentDay != null && totalDays != null) {
      return 'Día $currentDay de $totalDays';
    }
    return ''; // No special status
  }
}
