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

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dosageIntervalHours,
    required this.durationType,
    this.customDays,
    this.doseTimes = const [],
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
}
