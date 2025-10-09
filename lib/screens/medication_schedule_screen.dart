import 'package:flutter/material.dart';

class MedicationScheduleScreen extends StatefulWidget {
  final int dosageIntervalHours;
  final List<String>? initialDoseTimes; // Optional for editing
  final bool autoFillForTesting; // Auto-fill times for testing

  const MedicationScheduleScreen({
    super.key,
    required this.dosageIntervalHours,
    this.initialDoseTimes,
    this.autoFillForTesting = false,
  });

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  late List<TimeOfDay?> _doseTimes;
  late int _numberOfDoses;

  @override
  void initState() {
    super.initState();

    // Calculate number of doses per day
    _numberOfDoses = 24 ~/ widget.dosageIntervalHours;

    // Initialize dose times array
    _doseTimes = List.filled(_numberOfDoses, null);

    // If editing, parse initial dose times
    if (widget.initialDoseTimes != null && widget.initialDoseTimes!.isNotEmpty) {
      for (int i = 0; i < widget.initialDoseTimes!.length && i < _numberOfDoses; i++) {
        final timeParts = widget.initialDoseTimes![i].split(':');
        if (timeParts.length == 2) {
          _doseTimes[i] = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }
    }

    // Auto-fill for testing mode
    if (widget.autoFillForTesting && _doseTimes.every((t) => t == null)) {
      for (int i = 0; i < _numberOfDoses; i++) {
        final hour = i * widget.dosageIntervalHours;
        _doseTimes[i] = TimeOfDay(hour: hour, minute: 0);
      }
    }
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _doseTimes[index] ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _doseTimes[index] = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _allTimesSelected() {
    return _doseTimes.every((time) => time != null);
  }

  bool _hasDuplicateTimes() {
    final timeStrings = _doseTimes
        .where((time) => time != null)
        .map((time) => _formatTime(time!))
        .toList();

    // Check if there are duplicates by comparing list length with set length
    return timeStrings.length != timeStrings.toSet().length;
  }

  bool _isTimeDuplicated(int currentIndex) {
    final currentTime = _doseTimes[currentIndex];
    if (currentTime == null) return false;

    final currentTimeString = _formatTime(currentTime);

    // Check if any other dose has the same time
    for (int i = 0; i < _doseTimes.length; i++) {
      if (i != currentIndex && _doseTimes[i] != null) {
        if (_formatTime(_doseTimes[i]!) == currentTimeString) {
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

    // Convert TimeOfDay to "HH:mm" strings
    final doseTimesStrings = _doseTimes.map((time) => _formatTime(time!)).toList();
    Navigator.pop(context, doseTimesStrings);
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
                  'Selecciona la hora de cada toma',
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

          // List of time pickers
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _numberOfDoses,
              itemBuilder: (context, index) {
                final doseNumber = index + 1;
                final time = _doseTimes[index];
                final isDuplicated = _isTimeDuplicated(index);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDuplicated
                      ? Colors.orange.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
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
                    title: Row(
                      children: [
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
                    subtitle: Text(
                      time != null
                          ? isDuplicated
                              ? '${_formatTime(time)} - Hora duplicada'
                              : _formatTime(time)
                          : 'Selecciona la hora',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDuplicated
                                ? Colors.orange
                                : time != null
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    trailing: Icon(
                      Icons.access_time,
                      color: isDuplicated
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => _selectTime(index),
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
