import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import '../widgets/forms/frequency_option_card.dart';
import 'weekly_days_selector_screen.dart';
import 'medication_dosage_screen.dart';

/// Pantalla 3: Frecuencia (cada cuántos días tomar el medicamento)
/// Se salta si se seleccionaron fechas específicas
class MedicationFrequencyScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? specificDates;
  final bool skipFrequencyScreen;

  const MedicationFrequencyScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.startDate,
    this.endDate,
    this.specificDates,
    this.skipFrequencyScreen = false,
  });

  @override
  State<MedicationFrequencyScreen> createState() => _MedicationFrequencyScreenState();
}

enum FrequencyMode {
  everyday,
  alternateDays,
  weeklyDays,
}

class _MedicationFrequencyScreenState extends State<MedicationFrequencyScreen> {
  FrequencyMode _selectedMode = FrequencyMode.everyday;
  List<int>? _weeklyDays;

  @override
  void initState() {
    super.initState();

    // Si debemos saltar esta pantalla, ir directamente a la siguiente
    if (widget.skipFrequencyScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNextScreen(
          durationType: widget.durationType,
          weeklyDays: null,
          dayInterval: null,
        );
      });
    }
  }

  Future<void> _selectWeeklyDays() async {
    final result = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyDaysSelectorScreen(
          initialSelectedDays: _weeklyDays,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _weeklyDays = result;
      });
    }
  }

  void _continueToNextStep() async {
    final l10n = AppLocalizations.of(context)!;

    // Validar según el modo seleccionado
    if (_selectedMode == FrequencyMode.weeklyDays) {
      if (_weeklyDays == null || _weeklyDays!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationSelectWeekdays),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Determinar el tipo de duración basado en la frecuencia
    TreatmentDurationType durationType;
    List<int>? weeklyDays;
    int? dayInterval;

    switch (_selectedMode) {
      case FrequencyMode.everyday:
        durationType = TreatmentDurationType.everyday;
        weeklyDays = null;
        dayInterval = null;
        break;
      case FrequencyMode.alternateDays:
        // Días alternos: cada 2 días desde la fecha de inicio
        durationType = TreatmentDurationType.intervalDays;
        weeklyDays = null;
        dayInterval = 2;
        break;
      case FrequencyMode.weeklyDays:
        durationType = TreatmentDurationType.weeklyPattern;
        weeklyDays = _weeklyDays;
        dayInterval = null;
        break;
    }

    // Si originalmente era "hasta acabar", mantenerlo
    if (widget.durationType == TreatmentDurationType.untilFinished) {
      durationType = TreatmentDurationType.untilFinished;
    }

    _navigateToNextScreen(
      durationType: durationType,
      weeklyDays: weeklyDays,
      dayInterval: dayInterval,
    );
  }

  void _navigateToNextScreen({
    required TreatmentDurationType durationType,
    required List<int>? weeklyDays,
    required int? dayInterval,
  }) async {
    // Continuar a la pantalla de dosis
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDosageScreen(
          medicationName: widget.medicationName,
          medicationType: widget.medicationType,
          durationType: durationType,
          startDate: widget.startDate,
          endDate: widget.endDate,
          specificDates: widget.specificDates,
          weeklyDays: weeklyDays,
          dayInterval: dayInterval,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si debemos saltar esta pantalla, mostrar un loading
    if (widget.skipFrequencyScreen) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationFrequencyTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                l10n.stepIndicator(4, 7),
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
                value: 4 / 7,
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
                        l10n.medicationFrequencyTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.medicationFrequencySubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Opciones de frecuencia
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.everyday,
                        selectedValue: _selectedMode,
                        icon: Icons.calendar_today,
                        title: l10n.frequencyDailyTitle,
                        subtitle: l10n.frequencyDailyDesc,
                        color: Colors.blue,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                      const SizedBox(height: 12),
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.alternateDays,
                        selectedValue: _selectedMode,
                        icon: Icons.repeat,
                        title: l10n.frequencyAlternateTitle,
                        subtitle: l10n.frequencyAlternateDesc,
                        color: Colors.orange,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                      const SizedBox(height: 12),
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.weeklyDays,
                        selectedValue: _selectedMode,
                        icon: Icons.date_range,
                        title: l10n.frequencyWeeklyTitle,
                        subtitle: l10n.frequencyWeeklyDesc,
                        color: Colors.teal,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                    ],
                  ),
                ),
              ),

              // Selector de días si se eligió "weeklyDays"
              if (_selectedMode == FrequencyMode.weeklyDays) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.selectWeeklyDaysTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.selectWeeklyDaysSubtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _selectWeeklyDays,
                          icon: const Icon(Icons.date_range),
                          label: Text(_weeklyDays == null || _weeklyDays!.isEmpty
                              ? l10n.selectWeeklyDaysButton
                              : l10n.daySelected(_weeklyDays!.length)),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
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
