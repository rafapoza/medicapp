import 'medication_type.dart';

class Medication {
  final String id;
  final String name;
  final MedicationType type;
  final int dosageIntervalHours;

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dosageIntervalHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'dosageIntervalHours': dosageIntervalHours,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MedicationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MedicationType.pastilla,
      ),
      dosageIntervalHours: json['dosageIntervalHours'] as int? ?? 8,
    );
  }
}
