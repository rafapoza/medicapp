import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/dose_history_entry.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class DoseActionScreen extends StatefulWidget {
  final String medicationId;
  final String doseTime;

  const DoseActionScreen({
    super.key,
    required this.medicationId,
    required this.doseTime,
  });

  @override
  State<DoseActionScreen> createState() => _DoseActionScreenState();
}

class _DoseActionScreenState extends State<DoseActionScreen> {
  Medication? _medication;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedication();
  }

  Future<void> _loadMedication() async {
    final medication = await DatabaseHelper.instance.getMedication(widget.medicationId);

    if (mounted) {
      setState(() {
        _medication = medication;
        _isLoading = false;
      });
    }
  }

  Future<void> _registerTaken() async {
    if (_medication == null) return;

    // Cancel any postponed notification for this dose
    await NotificationService.instance.cancelPostponedNotification(
      _medication!.id,
      widget.doseTime,
    );

    // Get the dose quantity for this specific time
    final doseQuantity = _medication!.getDoseQuantity(widget.doseTime);

    // Check if there's enough stock for this dose
    if (_medication!.stockQuantity < doseQuantity) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente para esta toma\n'
            'Necesitas: $doseQuantity ${_medication!.type.stockUnit}\n'
            'Disponible: ${_medication!.stockDisplayText}'
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Get today's date
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Update taken doses for today
    List<String> updatedTakenDoses;
    List<String> updatedSkippedDoses = List.from(_medication!.skippedDosesToday);

    if (_medication!.takenDosesDate == todayString) {
      // Same day, add to existing list
      updatedTakenDoses = List.from(_medication!.takenDosesToday);
      updatedTakenDoses.add(widget.doseTime);
    } else {
      // New day, reset list
      updatedTakenDoses = [widget.doseTime];
      updatedSkippedDoses = []; // Reset skipped doses for new day
    }

    // Decrease stock by the dose quantity and update taken doses
    final updatedMedication = Medication(
      id: _medication!.id,
      name: _medication!.name,
      type: _medication!.type,
      dosageIntervalHours: _medication!.dosageIntervalHours,
      durationType: _medication!.durationType,
      doseSchedule: _medication!.doseSchedule,
      stockQuantity: _medication!.stockQuantity - doseQuantity,
      takenDosesToday: updatedTakenDoses,
      skippedDosesToday: updatedSkippedDoses,
      takenDosesDate: todayString,
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // Save to history
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      today.year,
      today.month,
      today.day,
      int.parse(widget.doseTime.split(':')[0]),
      int.parse(widget.doseTime.split(':')[1]),
    );

    final historyEntry = DoseHistoryEntry(
      id: '${_medication!.id}_${now.millisecondsSinceEpoch}',
      medicationId: _medication!.id,
      medicationName: _medication!.name,
      medicationType: _medication!.type,
      scheduledDateTime: scheduledDateTime,
      registeredDateTime: now,
      status: DoseStatus.taken,
      quantity: doseQuantity,
    );

    await DatabaseHelper.instance.insertDoseHistory(historyEntry);

    // Reschedule notifications
    await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

    if (!mounted) return;

    // Show confirmation and go back
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Toma de ${_medication!.name} registrada a las ${widget.doseTime}\n'
          'Stock restante: ${updatedMedication.stockDisplayText}'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _registerSkipped() async {
    if (_medication == null) return;

    // Cancel any postponed notification for this dose
    await NotificationService.instance.cancelPostponedNotification(
      _medication!.id,
      widget.doseTime,
    );

    // Get today's date
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Update skipped doses for today (no stock change)
    List<String> updatedSkippedDoses;
    List<String> updatedTakenDoses = List.from(_medication!.takenDosesToday);

    if (_medication!.takenDosesDate == todayString) {
      // Same day, add to existing list
      updatedSkippedDoses = List.from(_medication!.skippedDosesToday);
      updatedSkippedDoses.add(widget.doseTime);
    } else {
      // New day, reset lists
      updatedSkippedDoses = [widget.doseTime];
      updatedTakenDoses = []; // Reset taken doses for new day
    }

    // Update medication (no stock change)
    final updatedMedication = Medication(
      id: _medication!.id,
      name: _medication!.name,
      type: _medication!.type,
      dosageIntervalHours: _medication!.dosageIntervalHours,
      durationType: _medication!.durationType,
      doseSchedule: _medication!.doseSchedule,
      stockQuantity: _medication!.stockQuantity, // No change
      takenDosesToday: updatedTakenDoses,
      skippedDosesToday: updatedSkippedDoses,
      takenDosesDate: todayString,
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // Save to history
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      today.year,
      today.month,
      today.day,
      int.parse(widget.doseTime.split(':')[0]),
      int.parse(widget.doseTime.split(':')[1]),
    );

    final historyEntry = DoseHistoryEntry(
      id: '${_medication!.id}_${now.millisecondsSinceEpoch}',
      medicationId: _medication!.id,
      medicationName: _medication!.name,
      medicationType: _medication!.type,
      scheduledDateTime: scheduledDateTime,
      registeredDateTime: now,
      status: DoseStatus.skipped,
      quantity: 0, // No quantity for skipped doses
    );

    await DatabaseHelper.instance.insertDoseHistory(historyEntry);

    if (!mounted) return;

    // Show confirmation and go back
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Toma de ${_medication!.name} marcada como no tomada a las ${widget.doseTime}\n'
          'Stock: ${_medication!.stockDisplayText} (sin cambios)'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _postponeDose() async {
    if (_medication == null) return;

    // Show time picker to select new time
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (newTime == null) return;

    // Format the new time
    final newTimeString = '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';

    // Schedule a one-time notification for this dose
    await NotificationService.instance.schedulePostponedDoseNotification(
      medication: _medication!,
      originalDoseTime: widget.doseTime,
      newTime: newTime,
    );

    if (!mounted) return;

    // Show confirmation and go back
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Toma de ${_medication!.name} pospuesta\n'
          'Nueva hora: $newTimeString'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _postpone15Minutes() async {
    if (_medication == null) return;

    // Calculate time 15 minutes from now
    final now = DateTime.now();
    final newDateTime = now.add(const Duration(minutes: 15));
    final newTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);

    // Format the new time
    final newTimeString = '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';

    // Schedule a one-time notification for this dose
    await NotificationService.instance.schedulePostponedDoseNotification(
      medication: _medication!,
      originalDoseTime: widget.doseTime,
      newTime: newTime,
    );

    if (!mounted) return;

    // Show confirmation and go back
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Toma de ${_medication!.name} pospuesta 15 minutos\n'
          'Nueva hora: $newTimeString'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_medication == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Medicamento no encontrado'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acción de Toma'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Medication header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _medication!.type.icon,
                      size: 48,
                      color: _medication!.type.getColor(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _medication!.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _medication!.type.displayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _medication!.type.getColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Hora programada: ${widget.doseTime}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.medication, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Dosis: ${_medication!.getDoseQuantity(widget.doseTime)} ${_medication!.type.stockUnitSingular}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              '¿Qué deseas hacer?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Option 1: Register taken
            SizedBox(
              height: 100,
              child: FilledButton(
                onPressed: _registerTaken,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Registrar toma',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Descontará del stock',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Option 2: Register skipped
            SizedBox(
              height: 100,
              child: FilledButton.tonal(
                onPressed: _registerSkipped,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Marcar como no tomada',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No descontará del stock',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Option 3: Postpone 15 minutes (quick action)
            SizedBox(
              height: 80,
              child: FilledButton.tonal(
                onPressed: _postpone15Minutes,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.snooze, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Posponer 15 minutos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Recordatorio rápido',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Option 4: Postpone custom time
            SizedBox(
              height: 60,
              child: OutlinedButton(
                onPressed: _postponeDose,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Posponer (elegir hora)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
