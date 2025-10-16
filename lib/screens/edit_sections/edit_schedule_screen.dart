import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/medication.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';

/// Helper class to hold time and quantity for each dose
class _DoseEntry {
  TimeOfDay time;
  double quantity;

  _DoseEntry({required this.time, required this.quantity});
}

/// Pantalla para editar horarios y cantidades de las tomas
class EditScheduleScreen extends StatefulWidget {
  final Medication medication;

  const EditScheduleScreen({
    super.key,
    required this.medication,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late List<_DoseEntry> _doseEntries;
  late List<TextEditingController> _quantityControllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize dose entries from existing medication schedule
    _doseEntries = [];
    _quantityControllers = [];

    widget.medication.doseSchedule.forEach((timeString, quantity) {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      _doseEntries.add(_DoseEntry(
        time: TimeOfDay(hour: hour, minute: minute),
        quantity: quantity,
      ));

      _quantityControllers.add(TextEditingController(text: quantity.toString()));
    });

    // Sort by time
    _doseEntries.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
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
      initialTime: _doseEntries[index].time,
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
        .map((entry) => _formatTime(entry.time))
        .toList();

    return timeStrings.length != timeStrings.toSet().length;
  }

  bool _isTimeDuplicated(int currentIndex) {
    final currentTime = _doseEntries[currentIndex].time;
    final currentTimeString = _formatTime(currentTime);

    for (int i = 0; i < _doseEntries.length; i++) {
      if (i != currentIndex) {
        if (_formatTime(_doseEntries[i].time) == currentTimeString) {
          return true;
        }
      }
    }
    return false;
  }

  void _addDose() {
    setState(() {
      _doseEntries.add(_DoseEntry(
        time: TimeOfDay.now(),
        quantity: 1.0,
      ));
      _quantityControllers.add(TextEditingController(text: '1.0'));
    });
  }

  void _removeDose(int index) {
    if (_doseEntries.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe haber al menos una toma al día'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _doseEntries.removeAt(index);
      _quantityControllers[index].dispose();
      _quantityControllers.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
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

    setState(() {
      _isSaving = true;
    });

    try {
      // Update dose entry quantities from controllers
      for (int i = 0; i < _doseEntries.length; i++) {
        final quantity = double.parse(_quantityControllers[i].text.trim());
        _doseEntries[i].quantity = quantity;
      }

      // Convert to Map<String, double> (time -> quantity)
      final doseSchedule = <String, double>{};
      for (var entry in _doseEntries) {
        final timeString = _formatTime(entry.time);
        doseSchedule[timeString] = entry.quantity;
      }

      // Calculate new dosage interval (for compatibility)
      final dosageIntervalHours = _doseEntries.length > 0
          ? (24 / _doseEntries.length).round()
          : widget.medication.dosageIntervalHours;

      final updatedMedication = Medication(
        id: widget.medication.id,
        name: widget.medication.name,
        type: widget.medication.type,
        dosageIntervalHours: dosageIntervalHours,
        durationType: widget.medication.durationType,
        selectedDates: widget.medication.selectedDates,
        weeklyDays: widget.medication.weeklyDays,
        dayInterval: widget.medication.dayInterval,
        doseSchedule: doseSchedule,
        stockQuantity: widget.medication.stockQuantity,
        takenDosesToday: widget.medication.takenDosesToday,
        skippedDosesToday: widget.medication.skippedDosesToday,
        takenDosesDate: widget.medication.takenDosesDate,
        lastRefillAmount: widget.medication.lastRefillAmount,
        lowStockThresholdDays: widget.medication.lowStockThresholdDays,
        startDate: widget.medication.startDate,
        endDate: widget.medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reschedule notifications with new times
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horarios actualizados correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, updatedMedication);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar cambios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Horarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addDose,
            tooltip: 'Añadir toma',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tomas al día: ${_doseEntries.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajusta la hora y cantidad de cada toma',
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
              itemCount: _doseEntries.length,
              itemBuilder: (context, index) {
                final doseNumber = index + 1;
                final entry = _doseEntries[index];
                final isDuplicated = _isTimeDuplicated(index);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDuplicated ? Colors.orange.withOpacity(0.1) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with dose number and delete button
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isDuplicated
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                '$doseNumber',
                                style: TextStyle(
                                  color: isDuplicated
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Toma $doseNumber',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            if (_doseEntries.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeDose(index),
                                tooltip: 'Eliminar toma',
                              ),
                            if (isDuplicated) ...[
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
                            _formatTime(entry.time),
                            style: TextStyle(
                              color: isDuplicated
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.primary,
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
                                    '(${widget.medication.type.stockUnitSingular})',
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
                    onPressed: _isSaving ? null : _saveChanges,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
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
