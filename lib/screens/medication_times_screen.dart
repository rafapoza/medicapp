import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'medication_fasting_screen.dart';

/// Helper class to hold time and quantity for each dose
class _DoseEntry {
  TimeOfDay? time;
  double quantity;

  _DoseEntry({this.time, this.quantity = 1.0});
}

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
  late List<_DoseEntry> _doseEntries;
  late List<TextEditingController> _quantityControllers;

  @override
  void initState() {
    super.initState();

    // Initialize dose entries array
    _doseEntries = List.generate(widget.dosesPerDay, (_) => _DoseEntry());
    _quantityControllers = List.generate(
      widget.dosesPerDay,
      (_) => TextEditingController(text: '1.0'),
    );

    // Auto-fill times based on interval (only for non-custom dosage)
    if (!widget.isCustomDosage) {
      for (int i = 0; i < widget.dosesPerDay; i++) {
        final hour = i * widget.dosageIntervalHours;
        _doseEntries[i].time = TimeOfDay(hour: hour, minute: 0);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _doseEntries[index].time ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _doseEntries[index].time = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _allTimesSelected() {
    return _doseEntries.every((entry) => entry.time != null);
  }

  bool _allQuantitiesValid() {
    for (int i = 0; i < _doseEntries.length; i++) {
      final text = _quantityControllers[i].text.trim();
      final quantity = double.tryParse(text);
      if (quantity == null || quantity <= 0) {
        return false;
      }
    }
    return true;
  }

  bool _hasDuplicateTimes() {
    final timeStrings = _doseEntries
        .where((entry) => entry.time != null)
        .map((entry) => _formatTime(entry.time!))
        .toList();

    return timeStrings.length != timeStrings.toSet().length;
  }

  bool _isTimeDuplicated(int currentIndex) {
    final currentTime = _doseEntries[currentIndex].time;
    if (currentTime == null) return false;

    final currentTimeString = _formatTime(currentTime);

    for (int i = 0; i < _doseEntries.length; i++) {
      if (i != currentIndex && _doseEntries[i].time != null) {
        if (_formatTime(_doseEntries[i].time!) == currentTimeString) {
          return true;
        }
      }
    }
    return false;
  }

  void _continueToNextStep() {
    if (!_allTimesSelected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona todas las horas de las tomas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_allQuantitiesValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa cantidades válidas (mayores a 0)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hasDuplicateTimes()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las horas de las tomas no pueden repetirse'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update dose entry quantities from controllers
    for (int i = 0; i < _doseEntries.length; i++) {
      final quantity = double.parse(_quantityControllers[i].text.trim());
      _doseEntries[i].quantity = quantity;
    }

    // Convert to Map<String, double> (time -> quantity)
    final doseSchedule = <String, double>{};
    for (var entry in _doseEntries) {
      if (entry.time != null) {
        final timeString = _formatTime(entry.time!);
        doseSchedule[timeString] = entry.quantity;
      }
    }

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

          // Header with info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCustomDosage
                      ? 'Tomas al día: ${widget.dosesPerDay}'
                      : 'Frecuencia: Cada ${widget.dosageIntervalHours} horas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona la hora y cantidad de cada toma',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),

          // List of time pickers with dose quantities
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.dosesPerDay,
              itemBuilder: (context, index) {
                final doseNumber = index + 1;
                final entry = _doseEntries[index];
                final time = entry.time;
                final isDuplicated = _isTimeDuplicated(index);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDuplicated ? Colors.orange.withOpacity(0.1) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with dose number
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isDuplicated
                                  ? Colors.orange
                                  : time != null
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Text(
                                '$doseNumber',
                                style: TextStyle(
                                  color: isDuplicated
                                      ? Colors.white
                                      : time != null
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Toma $doseNumber',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (isDuplicated) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.warning,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Time selection button (full width)
                        OutlinedButton.icon(
                          onPressed: () => _selectTime(index),
                          icon: Icon(
                            Icons.access_time,
                            size: 20,
                            color: isDuplicated ? Colors.orange : null,
                          ),
                          label: Text(
                            time != null ? _formatTime(time) : 'Seleccionar hora',
                            style: TextStyle(
                              color: isDuplicated
                                  ? Colors.orange
                                  : time != null
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDuplicated
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quantity input section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label for quantity
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Cantidad por toma',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${widget.medicationType.stockUnitSingular})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity input field (number only)
                            TextField(
                              controller: _quantityControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Ej: 1, 0.5, 2',
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              onChanged: (value) {
                                final quantity = double.tryParse(value);
                                if (quantity != null && quantity > 0) {
                                  entry.quantity = quantity;
                                }
                              },
                            ),
                          ],
                        ),
                        if (isDuplicated)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Hora duplicada',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
          ),
        ],
      ),
    );
  }
}
