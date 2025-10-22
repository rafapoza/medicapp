import 'package:flutter/material.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import '../widgets/forms/dose_schedule_editor.dart';
import 'medication_fasting_screen.dart';

/// Pantalla 5: Horas de las dosis (establecer el horario de cada dosis)
class MedicationTimesScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? specificDates;
  final List<int>? weeklyDays;
  final int? dayInterval;
  final int dosageIntervalHours;
  final int dosesPerDay;
  final bool isCustomDosage;

  const MedicationTimesScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.startDate,
    this.endDate,
    this.specificDates,
    this.weeklyDays,
    this.dayInterval,
    required this.dosageIntervalHours,
    required this.dosesPerDay,
    this.isCustomDosage = false,
  });

  @override
  State<MedicationTimesScreen> createState() => _MedicationTimesScreenState();
}

class _MedicationTimesScreenState extends State<MedicationTimesScreen> {
  final _editorKey = GlobalKey<DoseScheduleEditorState>();

  void _continueToNextStep() {
    final editorState = _editorKey.currentState;
    if (editorState == null) return;

    if (!editorState.allTimesSelected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona todas las horas de las tomas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!editorState.allQuantitiesValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa cantidades válidas (mayores a 0)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editorState.hasDuplicateTimes()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las horas de las tomas no pueden repetirse'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final doseSchedule = editorState.getDoseSchedule();

    // Continuar a la pantalla de ayuno
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationFastingScreen(
          medicationName: widget.medicationName,
          medicationType: widget.medicationType,
          durationType: widget.durationType,
          startDate: widget.startDate,
          endDate: widget.endDate,
          specificDates: widget.specificDates,
          weeklyDays: widget.weeklyDays,
          dayInterval: widget.dayInterval,
          dosageIntervalHours: widget.dosageIntervalHours,
          doseSchedule: doseSchedule,
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
    final stepNumber = widget.durationType == TreatmentDurationType.specificDates ? '5 de 7' : '6 de 8';
    final progressValue = widget.durationType == TreatmentDurationType.specificDates ? 5 / 7 : 6 / 8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario de Tomas'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Paso $stepNumber',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de progreso
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Dose schedule editor
          Expanded(
            child: DoseScheduleEditor(
              key: _editorKey,
              initialDoseCount: widget.dosesPerDay,
              medicationType: widget.medicationType,
              allowAddRemove: false,
              headerText: widget.isCustomDosage
                  ? 'Tomas al día: ${widget.dosesPerDay}'
                  : 'Frecuencia: Cada ${widget.dosageIntervalHours} horas',
              subtitleText: 'Selecciona la hora y cantidad de cada toma',
            ),
          ),

          // Botones de navegación
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _continueToNextStep,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Atrás'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
