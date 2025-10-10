import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medication_type.dart';

// Helper class to hold time and quantity for each dose
class _DoseEntry {
  TimeOfDay? time;
  double quantity;

  _DoseEntry({this.time, this.quantity = 1.0});
}

class MedicationScheduleScreen extends StatefulWidget {
  final int dosageIntervalHours;
  final MedicationType medicationType; // To show the correct unit
  final Map<String, double>? initialDoseSchedule; // Optional for editing
  final List<String>? initialDoseTimes; // Legacy support for editing (deprecated)
  final bool autoFillForTesting; // Auto-fill times for testing

  const MedicationScheduleScreen({
    super.key,
    required this.dosageIntervalHours,
    required this.medicationType,
    this.initialDoseSchedule,
    this.initialDoseTimes,
    this.autoFillForTesting = false,
  });

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  late List<_DoseEntry> _doseEntries;
  late List<TextEditingController> _quantityControllers;
  late int _numberOfDoses;

  @override
  void initState() {
    super.initState();

    // Calculate number of doses per day
    _numberOfDoses = 24 ~/ widget.dosageIntervalHours;

    // Initialize dose entries array
    _doseEntries = List.generate(_numberOfDoses, (_) => _DoseEntry());
    _quantityControllers = List.generate(
      _numberOfDoses,
      (_) => TextEditingController(text: '1.0'),
    );

    // If editing with new format, parse initial dose schedule
    if (widget.initialDoseSchedule != null && widget.initialDoseSchedule!.isNotEmpty) {
      final sortedTimes = widget.initialDoseSchedule!.keys.toList()..sort();
      for (int i = 0; i < sortedTimes.length && i < _numberOfDoses; i++) {
        final time = sortedTimes[i];
        final quantity = widget.initialDoseSchedule![time]!;
        final timeParts = time.split(':');
        if (timeParts.length == 2) {
          _doseEntries[i].time = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          _doseEntries[i].quantity = quantity;
          _quantityControllers[i].text = quantity == quantity.toInt()
              ? quantity.toInt().toString()
              : quantity.toString();
        }
      }
    }
    // Legacy: If editing with old format, parse initial dose times (default quantity 1.0)
    else if (widget.initialDoseTimes != null && widget.initialDoseTimes!.isNotEmpty) {
      for (int i = 0; i < widget.initialDoseTimes!.length && i < _numberOfDoses; i++) {
        final timeParts = widget.initialDoseTimes![i].split(':');
        if (timeParts.length == 2) {
          _doseEntries[i].time = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          // Keep default quantity of 1.0
        }
      }
    }

    // Auto-fill for testing mode
    if (widget.autoFillForTesting && _doseEntries.every((e) => e.time == null)) {
      for (int i = 0; i < _numberOfDoses; i++) {
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

    // Check if there are duplicates by comparing list length with set length
    return timeStrings.length != timeStrings.toSet().length;
  }

  bool _isTimeDuplicated(int currentIndex) {
    final currentTime = _doseEntries[currentIndex].time;
    if (currentTime == null) return false;

    final currentTimeString = _formatTime(currentTime);

    // Check if any other dose has the same time
    for (int i = 0; i < _doseEntries.length; i++) {
      if (i != currentIndex && _doseEntries[i].time != null) {
        if (_formatTime(_doseEntries[i].time!) == currentTimeString) {
          return true;
        }
      }
    }
    return false;
  }

  void _saveSchedule() {
    if (!_allTimesSelected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona todas las horas de las tomas'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_allQuantitiesValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa cantidades válidas (mayores a 0)'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_hasDuplicateTimes()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las horas de las tomas no pueden repetirse'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
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

    Navigator.pop(context, doseSchedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario de tomas'),
      ),
      body: Column(
        children: [
          // Header with info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frecuencia: Cada ${widget.dosageIntervalHours} horas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tomas al día: $_numberOfDoses',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 8),
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
              itemCount: _numberOfDoses,
              itemBuilder: (context, index) {
                final doseNumber = index + 1;
                final entry = _doseEntries[index];
                final time = entry.time;
                final isDuplicated = _isTimeDuplicated(index);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDuplicated
                      ? Colors.orange.withOpacity(0.1)
                      : null,
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
                        // Time and quantity inputs
                        Row(
                          children: [
                            // Time selection
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(index),
                                icon: Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: isDuplicated
                                      ? Colors.orange
                                      : null,
                                ),
                                label: Text(
                                  time != null
                                      ? _formatTime(time)
                                      : 'Seleccionar hora',
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
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Quantity input
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _quantityControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Cantidad',
                                  suffixText: widget.medicationType.stockUnitSingular,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                onChanged: (value) {
                                  // Update quantity in real-time
                                  final quantity = double.tryParse(value);
                                  if (quantity != null && quantity > 0) {
                                    entry.quantity = quantity;
                                  }
                                },
                              ),
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

          // Bottom button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveSchedule,
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar horario'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
