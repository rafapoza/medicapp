/// Modelo que representa la relación muchos-a-muchos entre personas y medicamentos.
///
/// Permite que múltiples personas compartan el mismo medicamento, facilitando
/// el seguimiento individual de consumo mientras se mantiene un stock compartido.
class PersonMedication {
  final String id;
  final String personId;
  final String medicationId;
  final String assignedDate; // Fecha en que se asignó el medicamento a la persona

  PersonMedication({
    required this.id,
    required this.personId,
    required this.medicationId,
    required this.assignedDate,
  });

  /// Convierte el objeto a un Map para guardar en la base de datos
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'medicationId': medicationId,
      'assignedDate': assignedDate,
    };
  }

  /// Crea un objeto PersonMedication desde un Map de la base de datos
  factory PersonMedication.fromJson(Map<String, dynamic> json) {
    return PersonMedication(
      id: json['id'] as String,
      personId: json['personId'] as String,
      medicationId: json['medicationId'] as String,
      assignedDate: json['assignedDate'] as String,
    );
  }

  /// Crea una copia del objeto con valores opcionales modificados
  PersonMedication copyWith({
    String? id,
    String? personId,
    String? medicationId,
    String? assignedDate,
  }) {
    return PersonMedication(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      medicationId: medicationId ?? this.medicationId,
      assignedDate: assignedDate ?? this.assignedDate,
    );
  }

  @override
  String toString() {
    return 'PersonMedication(id: $id, personId: $personId, medicationId: $medicationId, assignedDate: $assignedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonMedication &&
        other.id == id &&
        other.personId == personId &&
        other.medicationId == medicationId &&
        other.assignedDate == assignedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        personId.hashCode ^
        medicationId.hashCode ^
        assignedDate.hashCode;
  }
}
