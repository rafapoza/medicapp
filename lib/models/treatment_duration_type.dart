import 'package:flutter/material.dart';

enum TreatmentDurationType {
  everyday('Todos los días'),
  untilFinished('Hasta acabar la medicación'),
  custom('Personalizado');

  final String displayName;

  const TreatmentDurationType(this.displayName);

  IconData get icon {
    switch (this) {
      case TreatmentDurationType.everyday:
        return Icons.event_repeat;
      case TreatmentDurationType.untilFinished:
        return Icons.medical_services;
      case TreatmentDurationType.custom:
        return Icons.edit_calendar;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case TreatmentDurationType.everyday:
        return Theme.of(context).colorScheme.primary;
      case TreatmentDurationType.untilFinished:
        return Theme.of(context).colorScheme.tertiary;
      case TreatmentDurationType.custom:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}
