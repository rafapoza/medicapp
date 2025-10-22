import 'package:flutter/material.dart';

enum MedicationType {
  pill,
  capsule,
  injection,
  syrup,
  ovule,
  suppository,
  inhaler,
  sachet,
  spray,
  ointment,
  lotion;

  String get displayName {
    switch (this) {
      case MedicationType.pill:
        return 'Pastilla';
      case MedicationType.capsule:
        return 'Cápsula';
      case MedicationType.injection:
        return 'Inyección';
      case MedicationType.syrup:
        return 'Jarabe';
      case MedicationType.ovule:
        return 'Óvulo';
      case MedicationType.suppository:
        return 'Supositorio';
      case MedicationType.inhaler:
        return 'Inhalador';
      case MedicationType.sachet:
        return 'Sobre';
      case MedicationType.spray:
        return 'Spray';
      case MedicationType.ointment:
        return 'Pomada';
      case MedicationType.lotion:
        return 'Loción';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicationType.pill:
        return Icons.circle;
      case MedicationType.capsule:
        return Icons.medication;
      case MedicationType.injection:
        return Icons.vaccines;
      case MedicationType.syrup:
        return Icons.local_drink;
      case MedicationType.ovule:
        return Icons.egg;
      case MedicationType.suppository:
        return Icons.toggle_off;
      case MedicationType.inhaler:
        return Icons.air;
      case MedicationType.sachet:
        return Icons.inventory_2;
      case MedicationType.spray:
        return Icons.water_drop;
      case MedicationType.ointment:
        return Icons.opacity;
      case MedicationType.lotion:
        return Icons.water;
    }
  }

  Color getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (this) {
      case MedicationType.pill:
        return Colors.blue;
      case MedicationType.capsule:
        return Colors.purple;
      case MedicationType.injection:
        return Colors.red;
      case MedicationType.syrup:
        return Colors.orange;
      case MedicationType.ovule:
        return Colors.pink;
      case MedicationType.suppository:
        return Colors.teal;
      case MedicationType.inhaler:
        return Colors.cyan;
      case MedicationType.sachet:
        return Colors.brown;
      case MedicationType.spray:
        return Colors.lightBlue;
      case MedicationType.ointment:
        return Colors.green;
      case MedicationType.lotion:
        return Colors.indigo;
    }
  }

  /// Get the unit of measurement for the medication type
  String get stockUnit {
    switch (this) {
      case MedicationType.pill:
        return 'pastillas';
      case MedicationType.capsule:
        return 'cápsulas';
      case MedicationType.injection:
        return 'inyecciones';
      case MedicationType.syrup:
        return 'ml';
      case MedicationType.ovule:
        return 'óvulos';
      case MedicationType.suppository:
        return 'supositorios';
      case MedicationType.inhaler:
        return 'inhalaciones';
      case MedicationType.sachet:
        return 'sobres';
      case MedicationType.spray:
        return 'ml';
      case MedicationType.ointment:
        return 'gramos';
      case MedicationType.lotion:
        return 'ml';
    }
  }

  /// Get the singular unit of measurement for the medication type
  String get stockUnitSingular {
    switch (this) {
      case MedicationType.pill:
        return 'pastilla';
      case MedicationType.capsule:
        return 'cápsula';
      case MedicationType.injection:
        return 'inyección';
      case MedicationType.syrup:
        return 'ml';
      case MedicationType.ovule:
        return 'óvulo';
      case MedicationType.suppository:
        return 'supositorio';
      case MedicationType.inhaler:
        return 'inhalación';
      case MedicationType.sachet:
        return 'sobre';
      case MedicationType.spray:
        return 'ml';
      case MedicationType.ointment:
        return 'gramo';
      case MedicationType.lotion:
        return 'ml';
    }
  }
}
