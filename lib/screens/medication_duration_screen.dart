import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'specific_dates_selector_screen.dart';
import 'medication_dates_screen.dart';
import 'medication_quantity_screen.dart';
import 'medication_duration/widgets/duration_option_card.dart';
import 'medication_duration/widgets/specific_dates_selector_card.dart';

/// Pantalla 2: Tipo de duración del tratamiento
class MedicationDurationScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;

  const MedicationDurationScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
  });

  @override
  State<MedicationDurationScreen> createState() => _MedicationDurationScreenState();
}

class _MedicationDurationScreenState extends State<MedicationDurationScreen> {
  TreatmentDurationType _selectedDurationType = TreatmentDurationType.everyday;
  List<String>? _specificDates;

  Future<void> _selectSpecificDates() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificDatesSelectorScreen(
          initialSelectedDates: _specificDates,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _specificDates = result;
      });
    }
  }

  void _continueToNextStep() async {
    final l10n = AppLocalizations.of(context)!;

    // Si es medicamento ocasional, ir directamente a la pantalla de cantidad
    if (_selectedDurationType == TreatmentDurationType.asNeeded) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationQuantityScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: _selectedDurationType,
            dosageIntervalHours: 0,
            doseSchedule: {},
            requiresFasting: false,
            notifyFasting: false,
          ),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
      return;
    }

    // Si se seleccionaron fechas específicas, validar
    if (_selectedDurationType == TreatmentDurationType.specificDates) {
      if (_specificDates == null || _specificDates!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationSelectDates),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Ir a la pantalla de fechas (inicio/fin) - solo si NO es fechas específicas
    if (_selectedDurationType != TreatmentDurationType.specificDates) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationDatesScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: _selectedDurationType,
          ),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    } else {
      // Para fechas específicas, ir directamente a la siguiente pantalla con las fechas
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationDatesScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: _selectedDurationType,
            specificDates: _specificDates,
          ),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationDurationTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                l10n.stepIndicator(2, 7),
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
                value: 2 / 7,
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
                        l10n.medicationDurationTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.medicationDurationSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Opciones de tipo de duración
                      DurationOptionCard(
                        type: TreatmentDurationType.everyday,
                        title: l10n.durationContinuousTitle,
                        subtitle: l10n.durationContinuousDesc,
                        isSelected: _selectedDurationType == TreatmentDurationType.everyday,
                        onTap: () {
                          setState(() {
                            _selectedDurationType = TreatmentDurationType.everyday;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DurationOptionCard(
                        type: TreatmentDurationType.untilFinished,
                        title: l10n.durationUntilEmptyTitle,
                        subtitle: l10n.durationUntilEmptyDesc,
                        isSelected: _selectedDurationType == TreatmentDurationType.untilFinished,
                        onTap: () {
                          setState(() {
                            _selectedDurationType = TreatmentDurationType.untilFinished;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DurationOptionCard(
                        type: TreatmentDurationType.specificDates,
                        title: l10n.durationSpecificDatesTitle,
                        subtitle: l10n.durationSpecificDatesDesc,
                        isSelected: _selectedDurationType == TreatmentDurationType.specificDates,
                        onTap: () {
                          setState(() {
                            _selectedDurationType = TreatmentDurationType.specificDates;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DurationOptionCard(
                        type: TreatmentDurationType.asNeeded,
                        title: l10n.durationAsNeededTitle,
                        subtitle: l10n.durationAsNeededDesc,
                        isSelected: _selectedDurationType == TreatmentDurationType.asNeeded,
                        onTap: () {
                          setState(() {
                            _selectedDurationType = TreatmentDurationType.asNeeded;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Selector de fechas específicas si está seleccionado
              if (_selectedDurationType == TreatmentDurationType.specificDates) ...[
                const SizedBox(height: 16),
                SpecificDatesSelectorCard(
                  specificDates: _specificDates,
                  onSelectDates: _selectSpecificDates,
                ),
              ],

              const SizedBox(height: 24),

              // Botón continuar
              FilledButton.icon(
                onPressed: _continueToNextStep,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.btnContinue),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),

              // Botón atrás
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.btnBack),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
