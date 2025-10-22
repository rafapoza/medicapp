import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import '../widgets/forms/fasting_configuration_form.dart';
import 'medication_quantity_screen.dart';

/// Pantalla 6: Configuración de ayuno (opcional)
class MedicationFastingScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? specificDates;
  final List<int>? weeklyDays;
  final int? dayInterval;
  final int dosageIntervalHours;
  final Map<String, double> doseSchedule;

  const MedicationFastingScreen({
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
    required this.doseSchedule,
  });

  @override
  State<MedicationFastingScreen> createState() => _MedicationFastingScreenState();
}

class _MedicationFastingScreenState extends State<MedicationFastingScreen> {
  bool _requiresFasting = false;
  String? _fastingType; // 'before' or 'after'
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '0');
  bool _notifyFasting = false;

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  int? get _fastingDurationMinutes {
    if (!_requiresFasting) return null;

    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    return (hours * 60) + minutes;
  }

  bool _isValid() {
    if (!_requiresFasting) return true;

    // Check if fasting type is selected
    if (_fastingType == null) return false;

    // Check if duration is valid (at least 1 minute)
    final duration = _fastingDurationMinutes;
    if (duration == null || duration < 1) return false;

    return true;
  }

  void _continueToNextStep() {
    if (!_isValid()) {
      String message = 'Por favor, completa todos los campos';
      if (_fastingType == null) {
        message = 'Por favor, selecciona cuándo es el ayuno';
      } else if (_fastingDurationMinutes == null || _fastingDurationMinutes! < 1) {
        message = 'La duración del ayuno debe ser al menos 1 minuto';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to quantity screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationQuantityScreen(
          medicationName: widget.medicationName,
          medicationType: widget.medicationType,
          durationType: widget.durationType,
          startDate: widget.startDate,
          endDate: widget.endDate,
          specificDates: widget.specificDates,
          weeklyDays: widget.weeklyDays,
          dayInterval: widget.dayInterval,
          dosageIntervalHours: widget.dosageIntervalHours,
          doseSchedule: widget.doseSchedule,
          requiresFasting: _requiresFasting,
          fastingType: _fastingType,
          fastingDurationMinutes: _fastingDurationMinutes,
          notifyFasting: _notifyFasting,
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
    final stepNumber = widget.durationType == TreatmentDurationType.specificDates ? '6 de 7' : '7 de 8';
    final progressValue = widget.durationType == TreatmentDurationType.specificDates ? 6 / 7 : 7 / 8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Ayuno'),
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

              // Card con formulario
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FastingConfigurationForm(
                    requiresFasting: _requiresFasting,
                    fastingType: _fastingType,
                    hoursController: _hoursController,
                    minutesController: _minutesController,
                    notifyFasting: _notifyFasting,
                    onRequiresFastingChanged: (value) {
                      setState(() {
                        _requiresFasting = value;
                        if (!value) {
                          _fastingType = null;
                          _notifyFasting = false;
                        }
                      });
                    },
                    onFastingTypeChanged: (value) {
                      setState(() {
                        _fastingType = value;
                      });
                    },
                    onNotifyFastingChanged: (value) {
                      setState(() {
                        _notifyFasting = value;
                      });
                    },
                    showDescription: true,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón continuar
              FilledButton.icon(
                onPressed: _continueToNextStep,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),

              // Botón atrás
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
      ),
    );
  }
}
