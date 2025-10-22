import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';
import '../models/treatment_duration_type.dart';
import '../models/dose_history_entry.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../utils/medication_sorter.dart';
import 'medication_info_screen.dart';
import 'edit_medication_menu_screen.dart';
import 'medication_stock_screen.dart';
import 'medicine_cabinet_screen.dart';
import 'dose_history_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> with WidgetsBindingObserver {
  final List<Medication> _medications = [];
  bool _isLoading = true;
  bool _debugMenuVisible = false;
  int _titleTapCount = 0;
  DateTime? _lastTapTime;
  bool _batteryBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    _loadBatteryBannerPreference();
    _loadMedications();
    _checkNotificationPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload medications when app resumes (e.g., after handling a notification)
    if (state == AppLifecycleState.resumed) {
      _loadMedications();
    }
  }

  /// Load battery banner dismissal preference
  Future<void> _loadBatteryBannerPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _batteryBannerDismissed = prefs.getBool('battery_banner_dismissed') ?? false;
        });
      }
    } catch (e) {
      // SharedPreferences not available (e.g., in tests)
      print('Could not load battery banner preference: $e');
    }
  }

  /// Dismiss battery banner and save preference
  Future<void> _dismissBatteryBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('battery_banner_dismissed', true);
      if (mounted) {
        setState(() {
          _batteryBannerDismissed = true;
        });
      }
    } catch (e) {
      // SharedPreferences not available (e.g., in tests)
      print('Could not save battery banner preference: $e');
      // Still hide the banner in the current session
      if (mounted) {
        setState(() {
          _batteryBannerDismissed = true;
        });
      }
    }
  }

  /// Check notification permissions and show warning if needed
  Future<void> _checkNotificationPermissions() async {
    // Skip permission checks in test mode to avoid timer issues
    if (NotificationService.instance.isTestMode) {
      return;
    }

    // Wait a bit for the screen to load
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // First, request basic notification permissions (this shows Android's system dialog)
    await NotificationService.instance.requestPermissions();

    // Wait for the system dialog to close
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Now check if exact alarms are allowed (critical for Android 12+)
    final canScheduleExact = await NotificationService.instance.canScheduleExactAlarms();

    print('🔔 Checking permissions - canScheduleExact: $canScheduleExact');

    if (!canScheduleExact && _medications.isNotEmpty) {
      // Show warning dialog for exact alarms only
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Flexible(child: Text('Permiso necesario')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Las notificaciones NO funcionarán sin este permiso.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alarm, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Activar "Alarmas y recordatorios"',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Este permiso permite que las notificaciones salten exactamente a la hora configurada.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Ahora no'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await NotificationService.instance.openExactAlarmSettings();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, size: 16),
                  SizedBox(width: 6),
                  Text('Abrir ajustes'),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  void _onTitleTap() {
    final now = DateTime.now();

    // Reset counter if more than 2 seconds have passed since last tap
    if (_lastTapTime == null || now.difference(_lastTapTime!).inSeconds > 2) {
      _titleTapCount = 1;
    } else {
      _titleTapCount++;
    }

    _lastTapTime = now;

    // Toggle debug menu visibility after 5 taps
    if (_titleTapCount >= 5) {
      setState(() {
        _debugMenuVisible = !_debugMenuVisible;
        _titleTapCount = 0;
        _lastTapTime = null;
      });

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_debugMenuVisible
              ? 'Menú de depuración activado'
              : 'Menú de depuración desactivado'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadMedications() async {
    print('Loading medications from database...');
    final allMedications = await DatabaseHelper.instance.getAllMedications();
    print('Loaded ${allMedications.length} medications');

    // Filter out "as needed" medications and suspended medications - they only appear in Botiquín
    final medications = allMedications.where((m) =>
      m.durationType != TreatmentDurationType.asNeeded &&
      !m.isSuspended
    ).toList();
    print('Filtered to ${medications.length} medications (excluded ${allMedications.length - medications.length} "as needed" or suspended)');

    for (var med in medications) {
      print('- ${med.name}: ${med.doseTimes.length} dose times');
    }

    // Sort medications by next dose proximity
    MedicationSorter.sortByNextDose(medications);

    if (!mounted) return; // Check if widget is still mounted

    // Update UI immediately
    setState(() {
      _medications.clear();
      _medications.addAll(medications);
      _isLoading = false;
    });

    print('UI updated with ${_medications.length} medications');

    // Schedule notifications in background without blocking UI
    _scheduleNotificationsInBackground(medications);
  }

  void _scheduleNotificationsInBackground(List<Medication> medications) {
    // Run notification scheduling in background without awaiting
    Future.microtask(() async {
      for (final medication in medications) {
        try {
          await NotificationService.instance.scheduleMedicationNotifications(medication);
        } catch (e) {
          // Log error but don't block the UI
          print('Error scheduling notifications for ${medication.name}: $e');
        }
      }
    });
  }

  void _navigateToAddMedication() async {
    final newMedication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationInfoScreen(
          existingMedications: _medications,
        ),
      ),
    );

    print('Returned from add screen: $newMedication');

    if (newMedication != null) {
      print('Adding new medication: ${newMedication.name}');
      print('Dose times: ${newMedication.doseTimes}');

      // Reload medications from database
      final reloadedMeds = await DatabaseHelper.instance.getAllMedications();
      print('Reloaded ${reloadedMeds.length} medications from DB after insert');

      // Sort by next dose proximity
      MedicationSorter.sortByNextDose(reloadedMeds);

      // Update UI immediately
      if (mounted) {
        setState(() {
          _medications.clear();
          _medications.addAll(reloadedMeds);
        });
      }
    } else {
      print('newMedication is null - user cancelled or error occurred');
    }
  }

  void _navigateToEditMedication(Medication medication) async {
    // Close the modal first
    Navigator.pop(context);

    // Then navigate to edit screen
    final updatedMedication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationMenuScreen(
          medication: medication,
          existingMedications: _medications,
        ),
      ),
    );

    if (updatedMedication != null) {
      print('Updating medication: ${updatedMedication.name}');
      print('Dose times: ${updatedMedication.doseTimes}');

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reload medications from database to ensure we have fresh data
      final reloadedMeds = await DatabaseHelper.instance.getAllMedications();
      print('Reloaded ${reloadedMeds.length} medications from DB');

      // Sort by next dose proximity
      MedicationSorter.sortByNextDose(reloadedMeds);

      // Update UI immediately
      if (mounted) {
        setState(() {
          _medications.clear();
          _medications.addAll(reloadedMeds);
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedMedication.name} actualizado'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Reschedule notifications in background (non-blocking)
      Future.microtask(() async {
        try {
          await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);
          print('Notifications rescheduled for ${updatedMedication.name}');
        } catch (e) {
          print('Error rescheduling notifications for ${updatedMedication.name}: $e');
        }
      });
    }
  }

  Map<String, dynamic>? _getNextDoseInfo(Medication medication) {
    if (medication.doseTimes.isEmpty) return null;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // If medication should be taken today, find next dose today
    if (medication.shouldTakeToday()) {
      // Get available doses that haven't been taken yet
      final availableDoses = medication.getAvailableDosesToday();

      if (availableDoses.isNotEmpty) {
        // Convert available doses to minutes and sort them
        final availableDosesInMinutes = availableDoses.map((timeString) {
          final parts = timeString.split(':');
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          return {'time': timeString, 'minutes': hours * 60 + minutes};
        }).toList()..sort((a, b) => (a['minutes'] as int).compareTo(b['minutes'] as int));

        // Check if there are pending doses (past time but not taken)
        final pendingDoses = availableDosesInMinutes.where((dose) =>
          (dose['minutes'] as int) <= currentMinutes
        ).toList();

        if (pendingDoses.isNotEmpty) {
          // There's a pending dose - show it in red/orange
          return {
            'date': now,
            'time': pendingDoses.first['time'],
            'isToday': true,
            'isPending': true, // Mark as pending (past due)
          };
        }

        // Find the next available dose time in the future
        for (final dose in availableDosesInMinutes) {
          if ((dose['minutes'] as int) > currentMinutes) {
            return {
              'date': now,
              'time': dose['time'],
              'isToday': true,
              'isPending': false,
            };
          }
        }

        // If all available doses are in the past, find next valid day
        final nextDate = _findNextValidDate(medication, now);
        if (nextDate != null) {
          return {
            'date': nextDate,
            'time': medication.doseTimes.first,
            'isToday': false,
            'isPending': false,
          };
        }
        return null;
      }

      // If no available doses today, find next valid day
      final nextDate = _findNextValidDate(medication, now);
      if (nextDate != null) {
        return {
          'date': nextDate,
          'time': medication.doseTimes.first,
          'isToday': false,
          'isPending': false,
        };
      }
    } else {
      // Medication shouldn't be taken today, find next valid day
      final nextDate = _findNextValidDate(medication, now);
      if (nextDate != null) {
        return {
          'date': nextDate,
          'time': medication.doseTimes.first,
          'isToday': false,
          'isPending': false,
        };
      }
    }

    return null;
  }

  DateTime? _findNextValidDate(Medication medication, DateTime from) {
    switch (medication.durationType) {
      case TreatmentDurationType.specificDates:
        if (medication.selectedDates == null || medication.selectedDates!.isEmpty) {
          return null;
        }

        // Find the next date in the list
        final sortedDates = medication.selectedDates!.toList()..sort();
        for (final dateString in sortedDates) {
          final parts = dateString.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );

          // If date is after today (or today but we have time left)
          if (date.isAfter(DateTime(from.year, from.month, from.day))) {
            return date;
          }
        }
        return null;

      case TreatmentDurationType.weeklyPattern:
        if (medication.weeklyDays == null || medication.weeklyDays!.isEmpty) {
          return null;
        }

        // Find the next occurrence of one of the selected weekdays
        for (int i = 1; i <= 7; i++) {
          final nextDate = from.add(Duration(days: i));
          if (medication.weeklyDays!.contains(nextDate.weekday)) {
            return nextDate;
          }
        }
        return null;

      default:
        // For everyday, untilFinished, custom - always tomorrow if not today
        return from.add(const Duration(days: 1));
    }
  }

  String _formatNextDose(Map<String, dynamic>? nextDoseInfo) {
    if (nextDoseInfo == null) return '';

    final date = nextDoseInfo['date'] as DateTime;
    final time = nextDoseInfo['time'] as String;
    final isToday = nextDoseInfo['isToday'] as bool;
    final isPending = nextDoseInfo['isPending'] as bool? ?? false;

    if (isToday) {
      if (isPending) {
        return '⚠️ Dosis pendiente: $time';
      } else {
        return 'Próxima toma: $time';
      }
    } else {
      // Format date
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == DateTime(tomorrow.year, tomorrow.month, tomorrow.day)) {
        return 'Próxima toma: mañana a las $time';
      } else {
        // Show day name
        const dayNames = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final dayName = dayNames[date.weekday];
        return 'Próxima toma: $dayName ${date.day}/${date.month} a las $time';
      }
    }
  }

  void _registerDose(Medication medication) async {
    print('_registerDose called');
    print('stockQuantity: ${medication.stockQuantity}');

    // Check if medication has dose times configured (BEFORE closing modal)
    if (medication.doseTimes.isEmpty) {
      print('Dose times empty');
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Este medicamento no tiene horarios configurados'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if there's any stock available (BEFORE closing modal)
    if (medication.stockQuantity <= 0) {
      print('No stock, showing SnackBar');
      final messenger = ScaffoldMessenger.of(context);
      print('Got messenger, popping navigator');
      Navigator.pop(context);
      print('Showing SnackBar');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No hay stock disponible de este medicamento'),
          duration: Duration(seconds: 2),
        ),
      );
      print('SnackBar shown');
      return;
    }

    print('Continuing with dose registration');

    // Close the modal after validation passes
    Navigator.pop(context);

    // Get available doses (doses that haven't been taken today)
    final availableDoses = medication.getAvailableDosesToday();

    // Check if there are available doses
    if (availableDoses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya has tomado todas las dosis de hoy'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String? selectedDoseTime;

    // If only one dose is available, register it directly
    if (availableDoses.length == 1) {
      selectedDoseTime = availableDoses.first;
    } else {
      // If multiple doses are available, show dialog to select which one was taken
      selectedDoseTime = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registrar toma de ${medication.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué toma has tomado?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...availableDoses.map((doseTime) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, doseTime),
                      icon: const Icon(Icons.alarm),
                      label: Text(doseTime),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    }

    if (selectedDoseTime != null) {
      // Get the dose quantity for this specific time
      final doseQuantity = medication.getDoseQuantity(selectedDoseTime);

      // Check if there's enough stock for this dose
      if (medication.stockQuantity < doseQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock insuficiente para esta toma\n'
              'Necesitas: $doseQuantity ${medication.type.stockUnit}\n'
              'Disponible: ${medication.stockDisplayText}'
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
      List<String> updatedSkippedDoses;

      if (medication.takenDosesDate == todayString) {
        // Same day, add to existing list
        updatedTakenDoses = List.from(medication.takenDosesToday);
        updatedTakenDoses.add(selectedDoseTime);
        updatedSkippedDoses = List.from(medication.skippedDosesToday);
      } else {
        // New day, reset lists
        updatedTakenDoses = [selectedDoseTime];
        updatedSkippedDoses = [];
      }

      // Decrease stock by the dose quantity and update taken doses
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - doseQuantity,
        takenDosesToday: updatedTakenDoses,
        skippedDosesToday: updatedSkippedDoses,
        takenDosesDate: todayString,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Create history entry
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(selectedDoseTime.split(':')[0]),
        int.parse(selectedDoseTime.split(':')[1]),
      );

      final historyEntry = DoseHistoryEntry(
        id: '${medication.id}_${now.millisecondsSinceEpoch}',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: scheduledDateTime,
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: doseQuantity,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Cancel today's notification for this specific dose to prevent it from firing
      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: updatedMedication,
        doseTime: selectedDoseTime,
      );

      // Schedule dynamic fasting notification if medication requires fasting after dose
      if (updatedMedication.requiresFasting &&
          updatedMedication.fastingType == 'after' &&
          updatedMedication.notifyFasting) {
        await NotificationService.instance.scheduleDynamicFastingNotification(
          medication: updatedMedication,
          actualDoseTime: DateTime.now(),
        );
        print('Dynamic fasting notification scheduled for ${updatedMedication.name}');
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      // Show confirmation
      final remainingDoses = updatedMedication.getAvailableDosesToday();
      final confirmationMessage = remainingDoses.isEmpty
          ? 'Toma de ${medication.name} registrada a las $selectedDoseTime\n'
              'Stock restante: ${updatedMedication.stockDisplayText}\n'
              '✓ Todas las tomas de hoy completadas'
          : 'Toma de ${medication.name} registrada a las $selectedDoseTime\n'
              'Stock restante: ${updatedMedication.stockDisplayText}\n'
              'Tomas restantes hoy: ${remainingDoses.length}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmationMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _registerManualDose(Medication medication) async {
    // Close the modal first
    Navigator.pop(context);

    // Check if there's any stock available
    if (medication.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay stock disponible de este medicamento'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show dialog to input dose quantity
    final doseController = TextEditingController(text: '1.0');

    final doseQuantity = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Registrar toma de ${medication.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock disponible: ${medication.stockDisplayText}',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                // Quantity label
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.medication, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Cantidad tomada',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(dialogContext).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${medication.type.stockUnit})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity field
                TextField(
                  controller: doseController,
                  decoration: InputDecoration(
                    hintText: 'Ej: 1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final quantity = double.tryParse(doseController.text.trim());
                if (quantity != null && quantity > 0) {
                  Navigator.pop(dialogContext, quantity);
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );

    // Dispose controller after dialog closes
    Future.delayed(const Duration(milliseconds: 100), () {
      doseController.dispose();
    });

    if (doseQuantity != null && doseQuantity > 0) {
      // Check if there's enough stock for this dose
      if (medication.stockQuantity < doseQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock insuficiente para esta toma\n'
              'Necesitas: $doseQuantity ${medication.type.stockUnit}\n'
              'Disponible: ${medication.stockDisplayText}'
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Decrease stock
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - doseQuantity,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Create history entry with current time
      final now = DateTime.now();
      final historyEntry = DoseHistoryEntry(
        id: '${medication.id}_${now.millisecondsSinceEpoch}',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: now, // For manual doses, scheduled time = actual time
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: doseQuantity,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Cancel the next pending notification for this medication today
      // This prevents notifications from firing after a manual dose registration
      if (medication.doseTimes.isNotEmpty) {
        final now = DateTime.now();
        final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

        // Find the next scheduled dose time that hasn't been taken yet
        String? nextDoseTime;
        for (final doseTime in medication.doseTimes) {
          final parts = doseTime.split(':');
          final doseTimeOfDay = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );

          // Check if this dose time is in the future and hasn't been taken
          final doseMinutes = doseTimeOfDay.hour * 60 + doseTimeOfDay.minute;
          final currentMinutes = currentTime.hour * 60 + currentTime.minute;

          if (doseMinutes > currentMinutes &&
              !updatedMedication.takenDosesToday.contains(doseTime)) {
            nextDoseTime = doseTime;
            break; // Found the next pending dose
          }
        }

        // If we found a next dose time, cancel its notification
        if (nextDoseTime != null) {
          await NotificationService.instance.cancelTodaysDoseNotification(
            medication: updatedMedication,
            doseTime: nextDoseTime,
          );
          print('Cancelled notification for $nextDoseTime after manual dose registration');
        }
      }

      // Schedule dynamic fasting notification if medication requires fasting after dose
      if (updatedMedication.requiresFasting &&
          updatedMedication.fastingType == 'after' &&
          updatedMedication.notifyFasting) {
        await NotificationService.instance.scheduleDynamicFastingNotification(
          medication: updatedMedication,
          actualDoseTime: now,
        );
        print('Dynamic fasting notification scheduled for ${updatedMedication.name}');
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      // Show confirmation
      final confirmationMessage = 'Toma manual de ${medication.name} registrada\n'
          'Cantidad: $doseQuantity ${medication.type.stockUnit}\n'
          'Stock restante: ${updatedMedication.stockDisplayText}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmationMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleSuspendMedication(Medication medication) async {
    // Close the modal first
    Navigator.pop(context);

    // Toggle the suspended status
    final updatedMedication = Medication(
      id: medication.id,
      name: medication.name,
      type: medication.type,
      dosageIntervalHours: medication.dosageIntervalHours,
      durationType: medication.durationType,
      doseSchedule: medication.doseSchedule,
      stockQuantity: medication.stockQuantity,
      takenDosesToday: medication.takenDosesToday,
      skippedDosesToday: medication.skippedDosesToday,
      takenDosesDate: medication.takenDosesDate,
      lastRefillAmount: medication.lastRefillAmount,
      lowStockThresholdDays: medication.lowStockThresholdDays,
      selectedDates: medication.selectedDates,
      weeklyDays: medication.weeklyDays,
      dayInterval: medication.dayInterval,
      startDate: medication.startDate,
      endDate: medication.endDate,
      requiresFasting: medication.requiresFasting,
      fastingType: medication.fastingType,
      fastingDurationMinutes: medication.fastingDurationMinutes,
      notifyFasting: medication.notifyFasting,
      isSuspended: !medication.isSuspended, // Toggle the suspension status
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // If suspending, cancel all notifications
    if (updatedMedication.isSuspended) {
      await NotificationService.instance.cancelMedicationNotifications(
        medication.id,
        medication: updatedMedication,
      );
    } else {
      // If reactivating, reschedule notifications
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);
    }

    // Reload medications
    await _loadMedications();

    if (!mounted) return;

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedMedication.isSuspended
              ? '${medication.name} suspendido\nNo se programarán más notificaciones'
              : '${medication.name} reactivado\nNotificaciones reprogramadas',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _refillMedication(Medication medication) async {
    // Close the modal first
    Navigator.pop(context);

    // Controller for the refill amount
    final refillController = TextEditingController(
      text: medication.lastRefillAmount?.toString() ?? '',
    );

    final refillAmount = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Recargar ${medication.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock actual: ${medication.stockDisplayText}',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                // Quantity label
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.add_box, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Cantidad a agregar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(dialogContext).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${medication.type.stockUnit})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity field
                TextField(
                  controller: refillController,
                  decoration: InputDecoration(
                    hintText: medication.lastRefillAmount != null
                        ? 'Ej: ${medication.lastRefillAmount}'
                        : 'Ej: 30',
                    helperText: medication.lastRefillAmount != null
                        ? 'Última recarga: ${medication.lastRefillAmount} ${medication.type.stockUnit}'
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(refillController.text.trim());
                if (amount != null && amount > 0) {
                  Navigator.pop(dialogContext, amount);
                }
              },
              child: const Text('Recargar'),
            ),
          ],
        );
      },
    );

    // Dispose controller after dialog closes completely
    // Use a small delay to ensure dialog animation finishes
    Future.delayed(const Duration(milliseconds: 100), () {
      refillController.dispose();
    });

    if (refillAmount != null && refillAmount > 0) {
      // Update medication with new stock and save refill amount
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + refillAmount,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: refillAmount, // Save for future suggestions
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock de ${medication.name} recargado\n'
            'Agregado: $refillAmount ${medication.type.stockUnit}\n'
            'Nuevo stock: ${updatedMedication.stockDisplayText}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDeleteModal(Medication medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Handle indicator
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Compact header with icon and info
                  Row(
                    children: [
                      Icon(
                        medication.type.icon,
                        size: 36,
                        color: medication.type.getColor(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              medication.type.displayName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: medication.type.getColor(context),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  medication.durationType.icon,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  medication.durationDisplayText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons - more compact
                  // Show different button based on whether medication allows manual registration
                  if (medication.allowsManualDoseRegistration) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _registerManualDose(medication),
                        icon: const Icon(Icons.medication, size: 18),
                        label: const Text('Registrar toma manual'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _registerDose(medication),
                        icon: const Icon(Icons.medication_liquid, size: 18),
                        label: const Text('Registrar toma'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _refillMedication(medication),
                      icon: const Icon(Icons.add_box, size: 18),
                      label: const Text('Recargar medicamento'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _toggleSuspendMedication(medication),
                      icon: Icon(
                        medication.isSuspended ? Icons.play_arrow : Icons.pause,
                        size: 18,
                      ),
                      label: Text(medication.isSuspended ? 'Reactivar medicamento' : 'Suspender medicamento'),
                      style: FilledButton.styleFrom(
                        backgroundColor: medication.isSuspended
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.secondaryContainer,
                        foregroundColor: medication.isSuspended
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSecondaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _navigateToEditMedication(medication),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar medicamento'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        // Delete from database
                        await DatabaseHelper.instance.deleteMedication(medication.id);

                        // Cancel notifications for the deleted medication
                        await NotificationService.instance.cancelMedicationNotifications(medication.id, medication: medication);

                        setState(() {
                          _medications.remove(medication);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${medication.name} eliminado'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Eliminar medicamento'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDebugInfo() async {
    final notificationsEnabled = await NotificationService.instance.areNotificationsEnabled();
    final canScheduleExact = await NotificationService.instance.canScheduleExactAlarms();
    final pendingNotifications = await NotificationService.instance.getPendingNotifications();

    if (!mounted) return;

    // Build notification info with medication data
    final notificationInfoList = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final notification in pendingNotifications) {
      String? medicationName;
      String? scheduledTime;
      String? scheduledDate;
      String? notificationType;
      bool isPastDue = false;

      // Determine notification type based on ID range
      final id = notification.id;
      if (id >= 6000000) {
        notificationType = 'Ayuno dinámico';
      } else if (id >= 5000000) {
        notificationType = 'Ayuno programado';
      } else if (id >= 4000000) {
        notificationType = 'Patrón semanal';
      } else if (id >= 3000000) {
        notificationType = 'Fecha específica';
      } else if (id >= 2000000) {
        notificationType = 'Pospuesta';
      } else {
        notificationType = 'Diaria recurrente';
      }

      // Try to parse payload to get medication info
      if (notification.payload != null && notification.payload!.isNotEmpty) {
        final parts = notification.payload!.split('|');
        if (parts.isNotEmpty) {
          final medicationId = parts[0];
          final medication = _medications.firstWhere(
            (m) => m.id == medicationId,
            orElse: () => _medications.first, // fallback
          );

          if (medication.id == medicationId) {
            medicationName = medication.name;

            // Check if this is a fasting notification
            if (parts.length > 1 && (parts[1].contains('fasting'))) {
              // This is a fasting notification
              final isDynamic = parts[1].contains('dynamic');
              final fastingType = medication.fastingType == 'before' ? 'Antes de tomar' : 'Después de tomar';
              final duration = medication.fastingDurationMinutes ?? 0;

              scheduledTime = '$fastingType ($duration min)';
              scheduledDate = isDynamic ? 'Basado en toma real' : 'Basado en horario';
            } else if (parts.length > 1) {
              // Regular dose notification
              final doseIndexOrTime = parts[1];

              // Check if it's a time string (HH:mm)
              if (doseIndexOrTime.contains(':')) {
                scheduledTime = doseIndexOrTime;
              } else {
                // It's a dose index
                final doseIndex = int.tryParse(doseIndexOrTime);
                if (doseIndex != null && doseIndex < medication.doseTimes.length) {
                  scheduledTime = medication.doseTimes[doseIndex];
                }
              }

              // Infer date based on notification type and medication
              if (scheduledTime != null) {
                final timeParts = scheduledTime.split(':');
                final schedHour = int.parse(timeParts[0]);
                final schedMin = int.parse(timeParts[1]);

                if (notificationType == 'Diaria recurrente') {
                  // Check if it's for today or tomorrow
                  final currentMinutes = now.hour * 60 + now.minute;
                  final scheduledMinutes = schedHour * 60 + schedMin;

                  if (scheduledMinutes > currentMinutes) {
                    scheduledDate = 'Hoy ${now.day}/${now.month}/${now.year}';
                    isPastDue = false;
                  } else {
                    final tomorrow = now.add(const Duration(days: 1));
                    scheduledDate = 'Mañana ${tomorrow.day}/${tomorrow.month}/${tomorrow.year}';
                    isPastDue = false; // Not past due if it's scheduled for tomorrow
                  }
                } else if (notificationType == 'Fecha específica' || notificationType == 'Patrón semanal') {
                  // Try to find the next date from medication schedule
                  if (medication.selectedDates != null && medication.selectedDates!.isNotEmpty) {
                    // For specific dates
                    final today = DateTime(now.year, now.month, now.day);
                    for (final dateString in medication.selectedDates!) {
                      final dateParts = dateString.split('-');
                      final date = DateTime(
                        int.parse(dateParts[0]),
                        int.parse(dateParts[1]),
                        int.parse(dateParts[2]),
                      );

                      if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
                        scheduledDate = '${date.day}/${date.month}/${date.year}';

                        // Check if past due
                        if (date.isAtSameMomentAs(today)) {
                          final currentMinutes = now.hour * 60 + now.minute;
                          final scheduledMinutes = schedHour * 60 + schedMin;
                          isPastDue = scheduledMinutes < currentMinutes;
                        }
                        break;
                      }
                    }
                  } else if (medication.weeklyDays != null && medication.weeklyDays!.isNotEmpty) {
                    // For weekly patterns - find next matching day
                    for (int i = 0; i <= 7; i++) {
                      final checkDate = now.add(Duration(days: i));
                      if (medication.weeklyDays!.contains(checkDate.weekday)) {
                        scheduledDate = '${checkDate.day}/${checkDate.month}/${checkDate.year}';

                        // Check if past due (only if it's today)
                        if (i == 0) {
                          final currentMinutes = now.hour * 60 + now.minute;
                          final scheduledMinutes = schedHour * 60 + schedMin;
                          isPastDue = scheduledMinutes < currentMinutes;
                        }
                        break;
                      }
                    }
                  } else {
                    scheduledDate = 'Hoy o posterior';
                  }
                } else if (notificationType == 'Pospuesta') {
                  // Postponed notifications are usually for today or tomorrow
                  final currentMinutes = now.hour * 60 + now.minute;
                  final scheduledMinutes = schedHour * 60 + schedMin;

                  if (scheduledMinutes > currentMinutes) {
                    scheduledDate = 'Hoy ${now.day}/${now.month}/${now.year}';
                  } else {
                    final tomorrow = now.add(const Duration(days: 1));
                    scheduledDate = 'Mañana ${tomorrow.day}/${tomorrow.month}/${tomorrow.year}';
                  }
                }
              }
            }
          }
        }
      }

      notificationInfoList.add({
        'notification': notification,
        'medicationName': medicationName,
        'scheduledTime': scheduledTime,
        'scheduledDate': scheduledDate,
        'notificationType': notificationType,
        'isPastDue': isPastDue,
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug de Notificaciones'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✓ Permisos de notificaciones: ${notificationsEnabled ? "Sí" : "No"}',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '⏰ Alarmas exactas (Android 12+): ${canScheduleExact ? "Sí" : "NO"}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canScheduleExact ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              if (!canScheduleExact) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ IMPORTANTE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Sin este permiso las notificaciones NO saltarán.',
                        style: TextStyle(fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Ajustes → Aplicaciones → MedicApp → Alarmas y recordatorios',
                        style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text('📊 Notificaciones pendientes: ${pendingNotifications.length}'),
              const SizedBox(height: 8),
              Text('💊 Medicamentos con horarios: ${_medications.where((m) => m.doseTimes.isNotEmpty).length}/${_medications.length}'),
              const SizedBox(height: 16),
              const Text('Notificaciones programadas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (pendingNotifications.isEmpty)
                const Text('⚠️ No hay notificaciones programadas', style: TextStyle(color: Colors.orange))
              else
                ...notificationInfoList.map((info) {
                  final notification = info['notification'];
                  final medicationName = info['medicationName'] as String?;
                  final scheduledTime = info['scheduledTime'] as String?;
                  final scheduledDate = info['scheduledDate'] as String?;
                  final notificationType = info['notificationType'] as String?;
                  final isPastDue = info['isPastDue'] as bool;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPastDue
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        border: isPastDue
                            ? Border.all(color: Colors.red, width: 1)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ID: ${notification.id}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isPastDue ? Colors.red : null,
                                ),
                              ),
                              if (isPastDue) ...[
                                const SizedBox(width: 8),
                                const Text(
                                  '⚠️ PASADA',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (medicationName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '💊 $medicationName',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                          if (notificationType != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '📋 Tipo: $notificationType',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (scheduledDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '📅 Fecha: $scheduledDate',
                              style: TextStyle(
                                fontSize: 14,
                                color: isPastDue ? Colors.red.shade700 : Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (scheduledTime != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '⏰ Hora: $scheduledTime',
                              style: TextStyle(
                                fontSize: 14,
                                color: isPastDue ? Colors.red.shade700 : Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            notification.title ?? "Sin título",
                            style: const TextStyle(fontSize: 15),
                          ),
                          if (notification.body != null)
                            Text(
                              notification.body!,
                              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              const Text('Medicamentos y horarios:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._medications.map((medication) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (medication.doseTimes.isEmpty)
                        const Text('  ⚠️ Sin horarios configurados', style: TextStyle(fontSize: 14, color: Colors.orange))
                      else
                        ...medication.doseTimes.map((time) => Text('  • $time', style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _testNotification() async {
    await NotificationService.instance.showTestNotification();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación de prueba enviada'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _testScheduledNotification() async {
    await NotificationService.instance.scheduleTestNotification();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación programada para 1 minuto'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _rescheduleAllNotifications() async {
    print('Reprogramando todas las notificaciones...');

    for (final medication in _medications) {
      if (medication.doseTimes.isNotEmpty) {
        await NotificationService.instance.scheduleMedicationNotifications(medication);
      }
    }

    if (!mounted) return;

    final pending = await NotificationService.instance.getPendingNotifications();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificaciones reprogramadas: ${pending.length}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show modal to add a new medication
  /// Navigation to other sections (Pastillero, Botiquín, Historial) is now done via bottom navigation bar
  void _showAddMedicationModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToAddMedication();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir medicamento'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayDosesSection(Medication medication) {
    final allDoses = [
      ...medication.takenDosesToday.map((time) => {'time': time, 'status': 'taken'}),
      ...medication.skippedDosesToday.map((time) => {'time': time, 'status': 'skipped'}),
    ]..sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Text(
            'Tomas de hoy:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allDoses.map((dose) {
              final time = dose['time'] as String;
              final status = dose['status'] as String;
              final isTaken = status == 'taken';

              return InkWell(
                onTap: () => _showEditTodayDoseDialog(medication, time, isTaken),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isTaken ? Colors.green : Colors.orange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isTaken ? Colors.green : Colors.orange).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTaken ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: isTaken ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isTaken ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTodayDoseDialog(Medication medication, String doseTime, bool isTaken) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Toma de ${medication.name} a las $doseTime'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado actual: ${isTaken ? "Tomada" : "Omitida"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Qué deseas hacer?',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, 'delete'),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'toggle'),
            icon: Icon(isTaken ? Icons.cancel : Icons.check_circle),
            label: Text(isTaken ? 'Marcar Omitida' : 'Marcar Tomada'),
            style: FilledButton.styleFrom(
              backgroundColor: isTaken ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );

    if (result == 'delete') {
      await _deleteTodayDose(medication, doseTime, isTaken);
    } else if (result == 'toggle') {
      await _toggleTodayDoseStatus(medication, doseTime, isTaken);
    }
  }

  Future<void> _deleteTodayDose(Medication medication, String doseTime, bool wasTaken) async {
    try {
      // Remove from taken or skipped doses
      List<String> takenDoses = List.from(medication.takenDosesToday);
      List<String> skippedDoses = List.from(medication.skippedDosesToday);

      if (wasTaken) {
        takenDoses.remove(doseTime);
      } else {
        skippedDoses.remove(doseTime);
      }

      // Restore stock if it was taken
      double newStock = medication.stockQuantity;
      if (wasTaken) {
        final doseQuantity = medication.getDoseQuantity(doseTime);
        newStock += doseQuantity;
      }

      // Update medication
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: newStock,
        takenDosesToday: takenDoses,
        skippedDosesToday: skippedDoses,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Delete from history
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(doseTime.split(':')[0]),
        int.parse(doseTime.split(':')[1]),
      );

      // Find and delete the history entry
      final historyEntries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      for (final entry in historyEntries) {
        if (entry.scheduledDateTime.year == scheduledDateTime.year &&
            entry.scheduledDateTime.month == scheduledDateTime.month &&
            entry.scheduledDateTime.day == scheduledDateTime.day &&
            entry.scheduledDateTime.hour == scheduledDateTime.hour &&
            entry.scheduledDateTime.minute == scheduledDateTime.minute) {
          await DatabaseHelper.instance.deleteDoseHistory(entry.id);
          break;
        }
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Toma de las $doseTime eliminada'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleTodayDoseStatus(Medication medication, String doseTime, bool wasTaken) async {
    try {
      // Move between taken and skipped
      List<String> takenDoses = List.from(medication.takenDosesToday);
      List<String> skippedDoses = List.from(medication.skippedDosesToday);

      double newStock = medication.stockQuantity;
      final doseQuantity = medication.getDoseQuantity(doseTime);

      if (wasTaken) {
        // Change from taken to skipped
        takenDoses.remove(doseTime);
        skippedDoses.add(doseTime);
        // Restore stock
        newStock += doseQuantity;
      } else {
        // Change from skipped to taken
        skippedDoses.remove(doseTime);
        takenDoses.add(doseTime);
        // Remove stock
        if (newStock < doseQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay suficiente stock para marcar como tomada'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        newStock -= doseQuantity;
      }

      // Update medication
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: newStock,
        takenDosesToday: takenDoses,
        skippedDosesToday: skippedDoses,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Update history entry
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(doseTime.split(':')[0]),
        int.parse(doseTime.split(':')[1]),
      );

      // Find and update the history entry
      final historyEntries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      for (final entry in historyEntries) {
        if (entry.scheduledDateTime.year == scheduledDateTime.year &&
            entry.scheduledDateTime.month == scheduledDateTime.month &&
            entry.scheduledDateTime.day == scheduledDateTime.day &&
            entry.scheduledDateTime.hour == scheduledDateTime.hour &&
            entry.scheduledDateTime.minute == scheduledDateTime.minute) {
          final updatedEntry = entry.copyWith(
            status: wasTaken ? DoseStatus.skipped : DoseStatus.taken,
            registeredDateTime: DateTime.now(),
          );
          await DatabaseHelper.instance.insertDoseHistory(updatedEntry);
          break;
        }
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Toma de las $doseTime marcada como ${wasTaken ? "Omitida" : "Tomada"}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _onTitleTap,
          child: const Text('Mis Medicamentos'),
        ),
        actions: _debugMenuVisible
            ? [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'test') {
                _testNotification();
              } else if (value == 'test_scheduled') {
                _testScheduledNotification();
              } else if (value == 'reschedule') {
                _rescheduleAllNotifications();
              } else if (value == 'debug') {
                _showDebugInfo();
              } else if (value == 'open_alarms') {
                NotificationService.instance.openExactAlarmSettings();
              } else if (value == 'open_battery') {
                NotificationService.instance.openBatteryOptimizationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active),
                    SizedBox(width: 8),
                    Text('Probar notificación'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_scheduled',
                child: Row(
                  children: [
                    Icon(Icons.alarm_add),
                    SizedBox(width: 8),
                    Text('Probar programada (1 min)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reschedule',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Reprogramar notificaciones'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Info de notificaciones'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open_alarms',
                child: Row(
                  children: [
                    Icon(Icons.alarm),
                    SizedBox(width: 8),
                    Text('⚙️ Alarmas y recordatorios'),
                  ],
                ),
              ),
              // Battery optimization is only available on Android
              if (Platform.isAndroid)
                const PopupMenuItem(
                  value: 'open_battery',
                  child: Row(
                    children: [
                      Icon(Icons.battery_full),
                      SizedBox(width: 8),
                      Text('⚙️ Optimización de batería'),
                    ],
                  ),
                ),
            ],
          ),
        ]
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _medications.isEmpty
          ? RefreshIndicator(
              onRefresh: _loadMedications,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay medicamentos registrados',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pulsa el botón + para añadir uno',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Arrastra hacia abajo para recargar',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : Column(
              children: [
                // Battery optimization info (only show on Android and if not dismissed)
                if (Platform.isAndroid && !_batteryBannerDismissed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.amber.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.amber.shade800),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Para que las notificaciones funcionen, desactiva las restricciones de batería:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Text(
                            'Ajustes → Aplicaciones → MedicApp → Batería → "Sin restricciones"',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await NotificationService.instance.openBatteryOptimizationSettings();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.amber.shade800,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.settings,
                                        size: 16,
                                        color: Colors.amber.shade800,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Abrir ajustes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.amber.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16,
                                        color: Colors.amber.shade800,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _dismissBatteryBanner,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade700,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Hecho',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Medications list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadMedications,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                      final medication = _medications[index];

                      // Determine stock status icon and color
                      IconData? stockIcon;
                      Color? stockColor;
                      if (medication.isStockEmpty) {
                        stockIcon = Icons.error;
                        stockColor = Colors.red;
                      } else if (medication.isStockLow) {
                        stockIcon = Icons.warning;
                        stockColor = Colors.orange;
                      }

                      return Opacity(
                  opacity: (medication.isFinished || medication.isSuspended) ? 0.5 : 1.0, // Dim finished or suspended medications
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: medication.type.getColor(context).withOpacity(0.2),
                            child: Icon(
                              medication.type.icon,
                              color: medication.type.getColor(context),
                            ),
                          ),
                          title: Text(
                            medication.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Phase 2: Show progress bar if treatment has dates
                              if (medication.progress != null) ...[
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: medication.progress,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      medication.isFinished
                                        ? Colors.grey
                                        : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              // Show suspended status
                              if (medication.isSuspended) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pause_circle_outline,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Suspendido',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                              ],
                              // Phase 2: Show status description (e.g., "Día 3 de 7", "Empieza el...", "Finalizado")
                              if (!medication.isSuspended && medication.statusDescription.isNotEmpty) ...[
                                Text(
                                  medication.statusDescription,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: medication.isPending
                                          ? Colors.orange
                                          : medication.isFinished
                                            ? Colors.grey
                                            : Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                medication.type.displayName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: medication.type.getColor(context),
                                    ),
                              ),
                              Text(
                                medication.durationDisplayText,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              if (_getNextDoseInfo(medication) != null) ...[
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    final doseInfo = _getNextDoseInfo(medication);
                                    final isPending = doseInfo?['isPending'] as bool? ?? false;
                                    final iconColor = isPending
                                        ? Colors.orange
                                        : Theme.of(context).colorScheme.primary;
                                    final textColor = isPending
                                        ? Colors.orange.shade700
                                        : Theme.of(context).colorScheme.primary;

                                    return Row(
                                      children: [
                                        Icon(
                                          isPending ? Icons.warning_amber : Icons.alarm,
                                          size: 18,
                                          color: iconColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            _formatNextDose(doseInfo),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          trailing: stockIcon != null
                        ? GestureDetector(
                            onTap: () {
                              // Show stock information when tapping the indicator
                              final dailyDose = medication.totalDailyDose;
                              final daysLeft = dailyDose > 0
                                  ? (medication.stockQuantity / dailyDose).floor()
                                  : 0;

                              final message = medication.isStockEmpty
                                  ? '${medication.name}\nStock: ${medication.stockDisplayText}'
                                  : '${medication.name}\nStock: ${medication.stockDisplayText}\nDuración estimada: $daysLeft días';

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: stockColor,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: stockColor!.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                stockIcon,
                                color: stockColor,
                                size: 18,
                              ),
                            ),
                          )
                              : null,
                          onTap: () => _showDeleteModal(medication),
                        ),
                        // Tomas del día ya registradas
                        if (medication.isTakenDosesDateToday &&
                            (medication.takenDosesToday.isNotEmpty ||
                             medication.skippedDosesToday.isNotEmpty))
                          _buildTodayDosesSection(medication),
                      ],
                    ),
                  ),
                );
                    },
                  ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
