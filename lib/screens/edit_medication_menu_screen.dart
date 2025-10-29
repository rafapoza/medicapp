import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../models/medication.dart';
import '../models/treatment_duration_type.dart';
import 'edit_sections/edit_basic_info_screen.dart';
import 'edit_sections/edit_duration_screen.dart';
import 'edit_sections/edit_frequency_screen.dart';
import 'edit_sections/edit_schedule_screen.dart';
import 'edit_sections/edit_quantity_screen.dart';
import 'edit_sections/edit_fasting_screen.dart';
import 'edit_medication_menu/widgets/medication_header_card.dart';
import 'edit_medication_menu/widgets/edit_menu_option.dart';

/// Pantalla de menú para editar diferentes aspectos de un medicamento
class EditMedicationMenuScreen extends StatelessWidget {
  final Medication medication;
  final List<Medication> existingMedications;

  const EditMedicationMenuScreen({
    super.key,
    required this.medication,
    required this.existingMedications,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editMedicationMenuTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con información del medicamento
              MedicationHeaderCard(medication: medication),
              const SizedBox(height: 24),

              // Descripción
              Text(
                l10n.editMedicationMenuWhatToEdit,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.editMedicationMenuSelectSection,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 16),

              // Opciones de edición
              EditMenuOption(
                icon: Icons.medication,
                title: l10n.editMedicationMenuBasicInfo,
                subtitle: l10n.editMedicationMenuBasicInfoDesc,
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBasicInfoScreen(
                        medication: medication,
                        existingMedications: existingMedications,
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
              ),
              const SizedBox(height: 12),

              EditMenuOption(
                icon: Icons.calendar_today,
                title: l10n.editMedicationMenuDuration,
                subtitle: medication.durationDisplayText,
                color: Colors.green,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDurationScreen(
                        medication: medication,
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
              ),
              const SizedBox(height: 12),

              EditMenuOption(
                icon: Icons.repeat,
                title: l10n.editMedicationMenuFrequency,
                subtitle: _getFrequencyDescription(context),
                color: Colors.orange,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFrequencyScreen(
                        medication: medication,
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
              ),
              const SizedBox(height: 12),

              EditMenuOption(
                icon: Icons.access_time,
                title: l10n.editMedicationMenuSchedules,
                subtitle: l10n.editMedicationMenuSchedulesDesc(medication.doseSchedule.length),
                color: Colors.purple,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScheduleScreen(
                        medication: medication,
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
              ),
              const SizedBox(height: 12),

              EditMenuOption(
                icon: Icons.restaurant_outlined,
                title: l10n.editMedicationMenuFasting,
                subtitle: _getFastingDescription(context),
                color: Colors.red,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFastingScreen(
                        medication: medication,
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
              ),
              const SizedBox(height: 12),

              EditMenuOption(
                icon: Icons.inventory_2,
                title: l10n.editMedicationMenuQuantity,
                subtitle: l10n.editMedicationMenuQuantityDesc(
                  medication.stockQuantity.toString(),
                  medication.type.stockUnit,
                ),
                color: Colors.teal,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditQuantityScreen(
                        medication: medication,
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFrequencyDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (medication.durationType == TreatmentDurationType.everyday) {
      return l10n.editMedicationMenuFreqEveryday;
    } else if (medication.durationType == TreatmentDurationType.untilFinished) {
      return l10n.editMedicationMenuFreqUntilFinished;
    } else if (medication.durationType == TreatmentDurationType.specificDates) {
      return l10n.editMedicationMenuFreqSpecificDates(medication.selectedDates?.length ?? 0);
    } else if (medication.durationType == TreatmentDurationType.weeklyPattern) {
      return l10n.editMedicationMenuFreqWeeklyDays(medication.weeklyDays?.length ?? 0);
    } else if (medication.durationType == TreatmentDurationType.intervalDays) {
      final interval = medication.dayInterval ?? 2;
      return l10n.editMedicationMenuFreqInterval(interval);
    }
    return l10n.editMedicationMenuFreqNotDefined;
  }

  String _getFastingDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!medication.requiresFasting) {
      return l10n.editMedicationMenuFastingNone;
    }

    final duration = medication.fastingDurationMinutes ?? 0;
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    String durationText;
    if (hours > 0 && minutes > 0) {
      durationText = '$hours h $minutes min';
    } else if (hours > 0) {
      durationText = '$hours h';
    } else {
      durationText = '$minutes min';
    }

    final typeText = medication.fastingType == 'before'
        ? l10n.editMedicationMenuFastingBefore
        : l10n.editMedicationMenuFastingAfter;
    return l10n.editMedicationMenuFastingDuration(durationText, typeText);
  }
}
