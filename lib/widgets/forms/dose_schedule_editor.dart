import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../models/medication_type.dart';

/// Helper class to hold time and quantity for each dose
class DoseEntry {
  TimeOfDay? time;
  double quantity;

  DoseEntry({this.time, this.quantity = 1.0});
}

/// Widget reutilizable para editar el horario y cantidades de las dosis
/// Usado tanto en creación como en edición de medicamentos
class DoseScheduleEditor extends StatefulWidget {
  final int initialDoseCount;
  final Map<String, double>? initialSchedule;
  final MedicationType medicationType;
  final bool allowAddRemove;
  final String? headerText;
  final String? subtitleText;

  const DoseScheduleEditor({
    super.key,
    required this.initialDoseCount,
    this.initialSchedule,
    required this.medicationType,
    this.allowAddRemove = false,
    this.headerText,
    this.subtitleText,
  });

  @override
  State<DoseScheduleEditor> createState() => DoseScheduleEditorState();
}

class DoseScheduleEditorState extends State<DoseScheduleEditor> {
  late List<DoseEntry> _doseEntries;
  late List<TextEditingController> _quantityControllers;

  @override
  void initState() {
    super.initState();

    _doseEntries = [];
    _quantityControllers = [];

    if (widget.initialSchedule != null && widget.initialSchedule!.isNotEmpty) {
      // Initialize from existing schedule
      widget.initialSchedule!.forEach((timeString, quantity) {
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        _doseEntries.add(DoseEntry(
          time: TimeOfDay(hour: hour, minute: minute),
          quantity: quantity,
        ));

        _quantityControllers.add(TextEditingController(text: quantity.toString()));
      });

      // Sort by time
      _sortDoses();
    } else {
      // Initialize entries with default times distributed throughout the day
      // This helps with testing and provides a better initial UX
      _doseEntries = List.generate(widget.initialDoseCount, (index) {
        final defaultTime = _calculateDefaultTime(index, widget.initialDoseCount);
        return DoseEntry(time: defaultTime, quantity: 1.0);
      });
      _quantityControllers = List.generate(
        widget.initialDoseCount,
        (_) => TextEditingController(text: '1.0'),
      );
    }
  }

  /// Calculate a default time for a dose, distributed throughout the day
  TimeOfDay _calculateDefaultTime(int index, int totalDoses) {
    if (totalDoses == 1) {
      // Single dose at 8:00 AM
      return const TimeOfDay(hour: 8, minute: 0);
    } else if (totalDoses == 2) {
      // Two doses: 8:00 AM and 8:00 PM
      return index == 0
          ? const TimeOfDay(hour: 8, minute: 0)
          : const TimeOfDay(hour: 20, minute: 0);
    } else if (totalDoses == 3) {
      // Three doses: 8:00 AM, 2:00 PM, 8:00 PM
      return [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 14, minute: 0),
        const TimeOfDay(hour: 20, minute: 0),
      ][index];
    } else if (totalDoses == 4) {
      // Four doses: 8:00 AM, 12:00 PM, 4:00 PM, 8:00 PM
      return [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 16, minute: 0),
        const TimeOfDay(hour: 20, minute: 0),
      ][index];
    } else {
      // For more doses, distribute evenly across waking hours (8 AM to 10 PM = 14 hours)
      const startHour = 8;
      const endHour = 22;
      const totalHours = endHour - startHour;

      final interval = totalHours / (totalDoses - 1);
      final hour = startHour + (interval * index);

      return TimeOfDay(hour: hour.floor(), minute: 0);
    }
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _sortDoses() {
    // Create combined list of entries and controllers
    final combined = List.generate(
      _doseEntries.length,
      (i) => {'entry': _doseEntries[i], 'controller': _quantityControllers[i]},
    );

    // Sort by time
    combined.sort((a, b) {
      final aEntry = a['entry'] as DoseEntry;
      final bEntry = b['entry'] as DoseEntry;
      if (aEntry.time == null) return 1;
      if (bEntry.time == null) return -1;
      final aMinutes = aEntry.time!.hour * 60 + aEntry.time!.minute;
      final bMinutes = bEntry.time!.hour * 60 + bEntry.time!.minute;
      return aMinutes.compareTo(bMinutes);
    });

    // Update lists
    _doseEntries = combined.map((e) => e['entry'] as DoseEntry).toList();
    _quantityControllers = combined.map((e) => e['controller'] as TextEditingController).toList();
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

  /// Public method to add a new dose (used by parent widget)
  void addDose() {
    setState(() {
      _doseEntries.add(DoseEntry(time: TimeOfDay.now(), quantity: 1.0));
      _quantityControllers.add(TextEditingController(text: '1.0'));
    });
  }

  void _removeDose(int index) {
    final l10n = AppLocalizations.of(context)!;
    if (_doseEntries.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.validationAtLeastOneDose),
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

  /// Returns true if all times are selected
  bool allTimesSelected() {
    return _doseEntries.every((entry) => entry.time != null);
  }

  /// Returns true if all quantities are valid
  bool allQuantitiesValid() {
    for (int i = 0; i < _doseEntries.length; i++) {
      final text = _quantityControllers[i].text.trim();
      final quantity = double.tryParse(text);
      if (quantity == null || quantity <= 0) {
        return false;
      }
    }
    return true;
  }

  /// Returns true if there are duplicate times
  bool hasDuplicateTimes() {
    final timeStrings = _doseEntries
        .where((entry) => entry.time != null)
        .map((entry) => _formatTime(entry.time!))
        .toList();

    return timeStrings.length != timeStrings.toSet().length;
  }

  /// Returns the dose schedule as Map<String, double>
  /// Updates quantities from controllers before returning
  Map<String, double> getDoseSchedule() {
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

    return doseSchedule;
  }

  /// Returns the dosage interval hours (calculated from times)
  int getDosageIntervalHours() {
    if (_doseEntries.length < 2) return 24;

    final times = _doseEntries
        .where((e) => e.time != null)
        .map((e) => e.time!.hour * 60 + e.time!.minute)
        .toList()
      ..sort();

    if (times.length < 2) return 24;

    final intervals = <int>[];
    for (int i = 1; i < times.length; i++) {
      intervals.add(times[i] - times[i - 1]);
    }
    intervals.add((24 * 60) - times.last + times.first);

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    return (avgInterval / 60).round();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with info
        if (widget.headerText != null || widget.subtitleText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.headerText != null)
                  Text(
                    widget.headerText!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                if (widget.headerText != null && widget.subtitleText != null)
                  const SizedBox(height: 4),
                if (widget.subtitleText != null)
                  Text(
                    widget.subtitleText!,
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
                            AppLocalizations.of(context)!.doseNumber(doseNumber),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (widget.allowAddRemove && _doseEntries.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeDose(index),
                              tooltip: AppLocalizations.of(context)!.removeDoseButton,
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
                      // Time selection button
                      OutlinedButton.icon(
                        onPressed: () => _selectTime(index),
                        icon: Icon(
                          Icons.access_time,
                          size: 20,
                          color: isDuplicated ? Colors.orange : null,
                        ),
                        label: Text(
                          time != null ? _formatTime(time) : AppLocalizations.of(context)!.selectTimeButton,
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
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.amountPerDose,
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
                          TextField(
                            controller: _quantityControllers[index],
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.amountHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
