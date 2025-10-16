import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
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

              // Card principal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ayuno',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Algunos medicamentos requieren ayuno antes o después de la toma',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Question: ¿Requiere ayuno?
                      Text(
                        '¿Este medicamento requiere ayuno?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Yes/No buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _requiresFasting = false;
                                  _fastingType = null;
                                  _notifyFasting = false;
                                });
                              },
                              icon: Icon(
                                _requiresFasting ? Icons.radio_button_off : Icons.radio_button_checked,
                                color: !_requiresFasting ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('No'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: !_requiresFasting
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: !_requiresFasting ? 2 : 1,
                                ),
                                backgroundColor: !_requiresFasting
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _requiresFasting = true;
                                });
                              },
                              icon: Icon(
                                _requiresFasting ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _requiresFasting ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('Sí'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: _requiresFasting
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: _requiresFasting ? 2 : 1,
                                ),
                                backgroundColor: _requiresFasting
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Show additional fields if fasting is required
                      if (_requiresFasting) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Question: ¿Cuándo es el ayuno?
                        Text(
                          '¿Cuándo es el ayuno?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Before/After buttons
                        Column(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _fastingType = 'before';
                                });
                              },
                              icon: Icon(
                                _fastingType == 'before' ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _fastingType == 'before' ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('Antes de la toma'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 48),
                                alignment: Alignment.centerLeft,
                                side: BorderSide(
                                  color: _fastingType == 'before'
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: _fastingType == 'before' ? 2 : 1,
                                ),
                                backgroundColor: _fastingType == 'before'
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _fastingType = 'after';
                                });
                              },
                              icon: Icon(
                                _fastingType == 'after' ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _fastingType == 'after' ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('Después de la toma'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 48),
                                alignment: Alignment.centerLeft,
                                side: BorderSide(
                                  color: _fastingType == 'after'
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: _fastingType == 'after' ? 2 : 1,
                                ),
                                backgroundColor: _fastingType == 'after'
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Question: ¿Cuánto tiempo de ayuno?
                        Text(
                          '¿Cuánto tiempo de ayuno?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Hours and Minutes input
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      'Horas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _hoursController,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      'Minutos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _minutesController,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Question: ¿Deseas recibir notificaciones?
                        Text(
                          '¿Deseas recibir notificaciones de ayuno?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fastingType == 'before'
                              ? 'Te notificaremos cuándo debes dejar de comer antes de la toma'
                              : 'Te notificaremos cuándo puedes volver a comer después de la toma',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Notification switch
                        SwitchListTile(
                          value: _notifyFasting,
                          onChanged: (value) {
                            setState(() {
                              _notifyFasting = value;
                            });
                          },
                          title: Text(
                            _notifyFasting ? 'Notificaciones activadas' : 'Notificaciones desactivadas',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ],
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
