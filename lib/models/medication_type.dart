import 'package:flutter/material.dart';

enum MedicationType {
  pastilla,
  capsula,
  inyeccion,
  jarabe,
  ovulo,
  supositorio,
  inhalador,
  sobre,
  spray,
  pomada,
  locion;

  String get displayName {
    switch (this) {
      case MedicationType.pastilla:
        return 'Pastilla';
      case MedicationType.capsula:
        return 'Cápsula';
      case MedicationType.inyeccion:
        return 'Inyección';
      case MedicationType.jarabe:
        return 'Jarabe';
      case MedicationType.ovulo:
        return 'Óvulo';
      case MedicationType.supositorio:
        return 'Supositorio';
      case MedicationType.inhalador:
        return 'Inhalador';
      case MedicationType.sobre:
        return 'Sobre';
      case MedicationType.spray:
        return 'Spray';
      case MedicationType.pomada:
        return 'Pomada';
      case MedicationType.locion:
        return 'Loción';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicationType.pastilla:
        return Icons.circle;
      case MedicationType.capsula:
        return Icons.medication;
      case MedicationType.inyeccion:
        return Icons.vaccines;
      case MedicationType.jarabe:
        return Icons.local_drink;
      case MedicationType.ovulo:
        return Icons.egg;
      case MedicationType.supositorio:
        return Icons.toggle_off;
      case MedicationType.inhalador:
        return Icons.air;
      case MedicationType.sobre:
        return Icons.inventory_2;
      case MedicationType.spray:
        return Icons.water_drop;
      case MedicationType.pomada:
        return Icons.opacity;
      case MedicationType.locion:
        return Icons.water;
    }
  }

  Color getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (this) {
      case MedicationType.pastilla:
        return Colors.blue;
      case MedicationType.capsula:
        return Colors.purple;
      case MedicationType.inyeccion:
        return Colors.red;
      case MedicationType.jarabe:
        return Colors.orange;
      case MedicationType.ovulo:
        return Colors.pink;
      case MedicationType.supositorio:
        return Colors.teal;
      case MedicationType.inhalador:
        return Colors.cyan;
      case MedicationType.sobre:
        return Colors.brown;
      case MedicationType.spray:
        return Colors.lightBlue;
      case MedicationType.pomada:
        return Colors.green;
      case MedicationType.locion:
        return Colors.indigo;
    }
  }
}
