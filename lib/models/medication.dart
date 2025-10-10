import 'medication_type.dart';
import 'treatment_duration_type.dart';

class Medication {
  final String id;
  final String name;
  final MedicationType type;
  final int dosageIntervalHours;
  final TreatmentDurationType durationType;
  final int? customDays; // Only used when durationType is custom
  final List<String> doseTimes; // List of dose times in "HH:mm" format
  final double stockQuantity; // Quantity of medication in stock

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dosageIntervalHours,
    required this.durationType,
    this.customDays,
    this.doseTimes = const [],
    this.stockQuantity = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'dosageIntervalHours': dosageIntervalHours,
      'durationType': durationType.name,
      'customDays': customDays,
      'doseTimes': doseTimes.join(','), // Store as comma-separated string
      'stockQuantity': stockQuantity,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    // Parse dose times from comma-separated string
    final doseTimesString = json['doseTimes'] as String?;
    final doseTimes = doseTimesString != null && doseTimesString.isNotEmpty
        ? doseTimesString.split(',')
        : <String>[];

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
      doseTimes: doseTimes,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0,
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

  /// Check if stock is low (less than 3 days worth of medication)
  bool get isStockLow {
    if (doseTimes.isEmpty) return false;

    // Calculate how many doses per day
    final dosesPerDay = doseTimes.length;

    // Consider stock low if less than 3 days worth
    final threeDaysWorth = dosesPerDay * 3;

    return stockQuantity > 0 && stockQuantity < threeDaysWorth;
  }

  /// Check if stock is empty
  bool get isStockEmpty {
    return stockQuantity <= 0;
  }
}
