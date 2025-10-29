import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'medication_frequency_screen.dart';
import 'medication_dates/widgets/date_selector_card.dart';
import 'medication_dates/widgets/clear_date_button.dart';
import 'medication_dates/widgets/duration_summary.dart';
import 'medication_dates/widgets/dates_help_info.dart';
import 'medication_frequency/widgets/continue_back_buttons.dart';

/// Pantalla 3: Fechas de inicio y fin del tratamiento (opcional)
class MedicationDatesScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final List<String>? specificDates;

  const MedicationDatesScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.specificDates,
  });

  @override
  State<MedicationDatesScreen> createState() => _MedicationDatesScreenState();
}

class _MedicationDatesScreenState extends State<MedicationDatesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Por defecto, no establecemos fecha de inicio (empieza hoy)
  }

  Future<void> _selectStartDate() async {
    final l10n = AppLocalizations.of(context)!;

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: l10n.startDatePickerTitle,
      cancelText: l10n.btnCancel,
      confirmText: l10n.btnAccept,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Si la fecha de fin es anterior a la nueva fecha de inicio, ajustarla
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final l10n = AppLocalizations.of(context)!;

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 7)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: l10n.endDatePickerTitle,
      cancelText: l10n.btnCancel,
      confirmText: l10n.btnAccept,
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _continueToNextStep() async {
    // Para fechas específicas, ir directamente a dosis (saltando frecuencia)
    if (widget.durationType == TreatmentDurationType.specificDates) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationFrequencyScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: widget.durationType,
            startDate: _startDate,
            endDate: _endDate,
            specificDates: widget.specificDates,
            skipFrequencyScreen: true,
          ),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    } else {
      // Para otros tipos, ir a la pantalla de frecuencia
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationFrequencyScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: widget.durationType,
            startDate: _startDate,
            endDate: _endDate,
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
    final currentStep = widget.durationType == TreatmentDurationType.specificDates ? 3 : 3;
    final totalSteps = widget.durationType == TreatmentDurationType.specificDates ? 6 : 7;
    final progressValue = widget.durationType == TreatmentDurationType.specificDates ? 3 / 6 : 3 / 7;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationDatesTitle),
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
                        l10n.medicationDatesTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.medicationDatesSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 8),
                      DatesHelpInfo(message: l10n.medicationDatesHelp),
                      const SizedBox(height: 24),

                      // Fecha de inicio
                      DateSelectorCard(
                        selectedDate: _startDate,
                        onTap: _selectStartDate,
                        icon: Icons.play_arrow,
                        label: l10n.startDateLabel,
                        optionalLabel: l10n.startDateOptional,
                        defaultText: l10n.startDateDefault,
                        selectedColor: Colors.green,
                      ),

                      // Botón para limpiar fecha de inicio
                      if (_startDate != null) ...[
                        const SizedBox(height: 8),
                        ClearDateButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          label: l10n.startTodayButton,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Fecha de fin (opcional)
                      DateSelectorCard(
                        selectedDate: _endDate,
                        onTap: _selectEndDate,
                        icon: Icons.stop,
                        label: l10n.endDateLabel,
                        optionalLabel: l10n.startDateOptional,
                        defaultText: l10n.endDateDefault,
                        selectedColor: Colors.deepOrange,
                      ),

                      // Botón para limpiar fecha de fin
                      if (_endDate != null) ...[
                        const SizedBox(height: 8),
                        ClearDateButton(
                          onPressed: () => setState(() => _endDate = null),
                          label: l10n.noEndDateButton,
                        ),
                      ],

                      // Resumen de duración si ambas fechas están seleccionadas
                      if (_startDate != null && _endDate != null) ...[
                        const SizedBox(height: 16),
                        DurationSummary(
                          startDate: _startDate!,
                          endDate: _endDate!,
                        ),
                      ],
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
