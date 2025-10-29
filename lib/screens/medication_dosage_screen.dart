import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'medication_times_screen.dart';
import 'medication_dosage/widgets/dosage_mode_option_card.dart';
import 'medication_dosage/widgets/interval_input_card.dart';
import 'medication_dosage/widgets/custom_doses_input_card.dart';
import 'medication_dosage/widgets/dose_summary_info.dart';
import 'medication_frequency/widgets/continue_back_buttons.dart';

/// Pantalla 4: Dosis (todos los días igual o cada día diferente)
class MedicationDosageScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? specificDates;
  final List<int>? weeklyDays;
  final int? dayInterval;

  const MedicationDosageScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.startDate,
    this.endDate,
    this.specificDates,
    this.weeklyDays,
    this.dayInterval,
  });

  @override
  State<MedicationDosageScreen> createState() => _MedicationDosageScreenState();
}

enum DosageMode {
  sameEveryDay,
  custom,
}

class _MedicationDosageScreenState extends State<MedicationDosageScreen> {
  DosageMode _selectedMode = DosageMode.sameEveryDay;
  final _intervalController = TextEditingController(text: '8');
  final _customDosesController = TextEditingController(text: '3');

  @override
  void dispose() {
    _intervalController.dispose();
    _customDosesController.dispose();
    super.dispose();
  }

  int _calculateDosesFromInterval() {
    final interval = int.tryParse(_intervalController.text) ?? 8;
    if (interval > 0 && 24 % interval == 0) {
      return 24 ~/ interval;
    }
    return 3; // Default
  }

  int _getDosesPerDay() {
    if (_selectedMode == DosageMode.sameEveryDay) {
      return _calculateDosesFromInterval();
    } else {
      return int.tryParse(_customDosesController.text) ?? 3;
    }
  }

  void _continueToNextStep() {
    final l10n = AppLocalizations.of(context)!;
    int dosageIntervalHours;
    int dosesPerDay;

    if (_selectedMode == DosageMode.sameEveryDay) {
      // Validar que el intervalo divida 24 exactamente
      final interval = int.tryParse(_intervalController.text);

      if (interval == null || interval <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationInvalidInterval),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (interval > 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationIntervalTooLarge),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (24 % interval != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationIntervalNotDivisor),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      dosageIntervalHours = interval;
      dosesPerDay = 24 ~/ interval;
    } else {
      // Modo personalizado
      final doses = int.tryParse(_customDosesController.text);

      if (doses == null || doses <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationInvalidDoseCount),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (doses > 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationTooManyDoses),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Para modo personalizado, usamos un intervalo ficticio
      // Esto es solo para compatibilidad con el modelo existente
      dosageIntervalHours = 24 ~/ doses;
      dosesPerDay = doses;
    }

    // Continuar a la pantalla de horarios
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationTimesScreen(
          medicationName: widget.medicationName,
          medicationType: widget.medicationType,
          durationType: widget.durationType,
          startDate: widget.startDate,
          endDate: widget.endDate,
          specificDates: widget.specificDates,
          weeklyDays: widget.weeklyDays,
          dayInterval: widget.dayInterval,
          dosageIntervalHours: dosageIntervalHours,
          dosesPerDay: dosesPerDay,
          isCustomDosage: _selectedMode == DosageMode.custom,
        ),
      ),
    ).then((result) {
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dosesPerDay = _getDosesPerDay();
    final currentStep = widget.durationType == TreatmentDurationType.specificDates ? 4 : 5;
    final totalSteps = widget.durationType == TreatmentDurationType.specificDates ? 6 : 7;
    final progressValue = widget.durationType == TreatmentDurationType.specificDates ? 4 / 6 : 5 / 7;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationDosageTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                l10n.stepIndicator(currentStep, totalSteps),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicador de progreso
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),

              // Card con información
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.medicationDosageTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.medicationDosageSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Opciones de modo
                      DosageModeOptionCard(
                        mode: DosageMode.sameEveryDay,
                        selectedMode: _selectedMode,
                        icon: Icons.schedule,
                        title: l10n.dosageFixedTitle,
                        subtitle: l10n.dosageFixedDesc,
                        color: Colors.blue,
                        onTap: (mode) => setState(() => _selectedMode = mode),
                      ),
                      const SizedBox(height: 12),
                      DosageModeOptionCard(
                        mode: DosageMode.custom,
                        selectedMode: _selectedMode,
                        icon: Icons.tune,
                        title: l10n.dosageCustomTitle,
                        subtitle: l10n.dosageCustomDesc,
                        color: Colors.purple,
                        onTap: (mode) => setState(() => _selectedMode = mode),
                      ),
                    ],
                  ),
                ),
              ),

              // Controles según el modo seleccionado
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedMode == DosageMode.sameEveryDay) ...[
                        IntervalInputCard(
                          controller: _intervalController,
                          onChanged: () => setState(() {}),
                        ),
                      ] else ...[
                        CustomDosesInputCard(
                          controller: _customDosesController,
                          onChanged: () => setState(() {}),
                        ),
                      ],

                      // Resumen de dosis
                      const SizedBox(height: 16),
                      DoseSummaryInfo(dosesPerDay: dosesPerDay),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ContinueBackButtons(
                onContinue: _continueToNextStep,
                onBack: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
