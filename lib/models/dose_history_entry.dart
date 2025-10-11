import '../models/medication_type.dart';

/// Represents a single dose history entry
class DoseHistoryEntry {
  final String id;
  final String medicationId;
  final String medicationName;
  final MedicationType medicationType;
  final DateTime scheduledDateTime; // When it was supposed to be taken
  final DateTime registeredDateTime; // When it was actually registered
  final DoseStatus status; // taken or skipped
  final double quantity; // Amount taken
  final String? notes; // Optional notes

  DoseHistoryEntry({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.medicationType,
    required this.scheduledDateTime,
    required this.registeredDateTime,
    required this.status,
    required this.quantity,
    this.notes,
  });

  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'medicationType': medicationType.name,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'registeredDateTime': registeredDateTime.toIso8601String(),
      'status': status.name,
      'quantity': quantity,
      'notes': notes,
    };
  }

  /// Create from database map
  factory DoseHistoryEntry.fromMap(Map<String, dynamic> map) {
    return DoseHistoryEntry(
      id: map['id'] as String,
      medicationId: map['medicationId'] as String,
      medicationName: map['medicationName'] as String,
      medicationType: MedicationType.values.firstWhere(
        (e) => e.name == map['medicationType'],
        orElse: () => MedicationType.pastilla,
      ),
      scheduledDateTime: DateTime.parse(map['scheduledDateTime'] as String),
      registeredDateTime: DateTime.parse(map['registeredDateTime'] as String),
      status: DoseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DoseStatus.taken,
      ),
      quantity: map['quantity'] as double,
      notes: map['notes'] as String?,
    );
  }

  /// Copy with method for creating modified copies
  DoseHistoryEntry copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    MedicationType? medicationType,
    DateTime? scheduledDateTime,
    DateTime? registeredDateTime,
    DoseStatus? status,
    double? quantity,
    String? notes,
  }) {
    return DoseHistoryEntry(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      medicationType: medicationType ?? this.medicationType,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      registeredDateTime: registeredDateTime ?? this.registeredDateTime,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  /// Format scheduled time as HH:mm
  String get scheduledTimeFormatted {
    return '${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format scheduled date as dd/MM/yyyy
  String get scheduledDateFormatted {
    return '${scheduledDateTime.day.toString().padLeft(2, '0')}/${scheduledDateTime.month.toString().padLeft(2, '0')}/${scheduledDateTime.year}';
  }

  /// Format registered time as HH:mm
  String get registeredTimeFormatted {
    return '${registeredDateTime.hour.toString().padLeft(2, '0')}:${registeredDateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get delay between scheduled and registered (in minutes)
  /// Positive = late, Negative = early
  int get delayInMinutes {
    return registeredDateTime.difference(scheduledDateTime).inMinutes;
  }

  /// Check if the dose was taken on time (within 30 minutes of scheduled)
  bool get wasOnTime {
    return delayInMinutes.abs() <= 30;
  }
}

/// Status of a dose (taken or skipped)
enum DoseStatus {
  taken,
  skipped;

  String get displayName {
    switch (this) {
      case DoseStatus.taken:
        return 'Tomada';
      case DoseStatus.skipped:
        return 'Omitida';
    }
  }
}
