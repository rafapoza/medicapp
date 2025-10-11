import 'dart:convert';
import 'medication_type.dart';
import 'treatment_duration_type.dart';

class Medication {
  final String id;
  final String name;
  final MedicationType type;
  final int dosageIntervalHours;
  final TreatmentDurationType durationType;
  final int? customDays; // Only used when durationType is custom
  final Map<String, double> doseSchedule; // Map of time -> dose quantity in "HH:mm" -> quantity format
  final double stockQuantity; // Quantity of medication in stock
  final List<String> takenDosesToday; // List of doses taken today in "HH:mm" format (reduces stock)
  final List<String> skippedDosesToday; // List of doses skipped today in "HH:mm" format (doesn't reduce stock)
  final String? takenDosesDate; // Date when doses were taken/skipped in "yyyy-MM-dd" format
  final double? lastRefillAmount; // Last refill amount (used as suggestion for future refills)
  final int lowStockThresholdDays; // Days before running out to show low stock warning
  final List<String>? selectedDates; // Specific dates for specificDates type in "yyyy-MM-dd" format
  final List<int>? weeklyDays; // Days of week (1=Mon, 7=Sun) for weeklyPattern type

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dosageIntervalHours,
    required this.durationType,
    this.customDays,
    Map<String, double>? doseSchedule,
    this.stockQuantity = 0,
    this.takenDosesToday = const [],
    this.skippedDosesToday = const [],
    this.takenDosesDate,
    this.lastRefillAmount,
    this.lowStockThresholdDays = 3, // Default to 3 days
    this.selectedDates, // Specific dates for specificDates type
    this.weeklyDays, // Days of week for weeklyPattern type
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
      'customDays': customDays,
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
      customDays: json['customDays'] as int?,
      doseSchedule: doseSchedule,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0,
      takenDosesToday: takenDosesToday,
      skippedDosesToday: skippedDosesToday,
      takenDosesDate: json['takenDosesDate'] as String?,
      lastRefillAmount: (json['lastRefillAmount'] as num?)?.toDouble(),
      lowStockThresholdDays: json['lowStockThresholdDays'] as int? ?? 3, // Default to 3 days for backward compatibility
      selectedDates: selectedDates,
      weeklyDays: weeklyDays,
    );
  }

  String get durationDisplayText {
    switch (durationType) {
      case TreatmentDurationType.everyday:
        return 'Todos los días';
      case TreatmentDurationType.untilFinished:
        return 'Hasta acabar';
      case TreatmentDurationType.custom:
        return '$customDays días';
      case TreatmentDurationType.specificDates:
        final count = selectedDates?.length ?? 0;
        return '$count fecha${count != 1 ? 's' : ''} específica${count != 1 ? 's' : ''}';
      case TreatmentDurationType.weeklyPattern:
        final count = weeklyDays?.length ?? 0;
        return '$count día${count != 1 ? 's' : ''} por semana';
    }
  }

  /// Check if medication should be taken today based on duration type
  bool shouldTakeToday() {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    switch (durationType) {
      case TreatmentDurationType.everyday:
        return true;
      case TreatmentDurationType.untilFinished:
        return stockQuantity > 0;
      case TreatmentDurationType.custom:
        // This would need to track start date - for now assume it should be taken
        return true;
      case TreatmentDurationType.specificDates:
        return selectedDates?.contains(todayString) ?? false;
      case TreatmentDurationType.weeklyPattern:
        // Monday = 1, Sunday = 7
        final weekday = today.weekday;
        return weeklyDays?.contains(weekday) ?? false;
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
}
