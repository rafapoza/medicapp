import 'package:flutter/material.dart';

enum TreatmentDurationType {
  everyday('Todos los días'),
  untilFinished('Hasta acabar la medicación'),
  specificDates('Fechas específicas'),
  weeklyPattern('Días de la semana');

  final String displayName;

  const TreatmentDurationType(this.displayName);

  IconData get icon {
    switch (this) {
      case TreatmentDurationType.everyday:
        return Icons.event_repeat;
      case TreatmentDurationType.untilFinished:
        return Icons.medical_services;
      case TreatmentDurationType.specificDates:
        return Icons.calendar_today;
      case TreatmentDurationType.weeklyPattern:
        return Icons.date_range;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case TreatmentDurationType.everyday:
        return Theme.of(context).colorScheme.primary;
      case TreatmentDurationType.untilFinished:
        return Theme.of(context).colorScheme.tertiary;
      case TreatmentDurationType.specificDates:
        return Colors.deepPurple;
      case TreatmentDurationType.weeklyPattern:
        return Colors.teal;
    }
  }
}
