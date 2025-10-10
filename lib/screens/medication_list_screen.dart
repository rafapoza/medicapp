import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'add_medication_screen.dart';
import 'edit_medication_screen.dart';
import 'medication_stock_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final List<Medication> _medications = [];
  bool _isLoading = true;
  bool _debugMenuVisible = false;
  int _titleTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadMedications();
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
    final medications = await DatabaseHelper.instance.getAllMedications();
    print('Loaded ${medications.length} medications');

    for (var med in medications) {
      print('- ${med.name}: ${med.doseTimes.length} dose times');
    }

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
        builder: (context) => AddMedicationScreen(
          existingMedications: _medications,
        ),
      ),
    );

    print('Returned from add screen: $newMedication');

    if (newMedication != null) {
      print('Adding new medication: ${newMedication.name}');
      print('Dose times: ${newMedication.doseTimes}');

      // Save to database
      final insertResult = await DatabaseHelper.instance.insertMedication(newMedication);
      print('Insert result: $insertResult');

      // Schedule notifications for the new medication
      await NotificationService.instance.scheduleMedicationNotifications(newMedication);

      // Reload medications from database
      final reloadedMeds = await DatabaseHelper.instance.getAllMedications();
      print('Reloaded ${reloadedMeds.length} medications from DB after insert');

      if (mounted) {
        setState(() {
          _medications.clear();
          _medications.addAll(reloadedMeds);
        });

        // Schedule notifications in background
        _scheduleNotificationsInBackground(reloadedMeds);
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
        builder: (context) => EditMedicationScreen(
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

      // Reschedule notifications for the updated medication
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      // Reload medications from database to ensure we have fresh data
      final reloadedMeds = await DatabaseHelper.instance.getAllMedications();
      print('Reloaded ${reloadedMeds.length} medications from DB');

      if (mounted) {
        setState(() {
          _medications.clear();
          _medications.addAll(reloadedMeds);
        });

        // Schedule notifications in background
        _scheduleNotificationsInBackground(reloadedMeds);

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedMedication.name} actualizado'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String? _getNextDoseTime(Medication medication) {
    if (medication.doseTimes.isEmpty) return null;

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Convert all dose times to minutes and sort them
    final doseTimesInMinutes = medication.doseTimes.map((timeString) {
      final parts = timeString.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return hours * 60 + minutes;
    }).toList()..sort();

    // Find the next dose time
    for (final doseMinutes in doseTimesInMinutes) {
      if (doseMinutes > currentMinutes) {
        return medication.doseTimes[doseTimesInMinutes.indexOf(doseMinutes)];
      }
    }

    // If no dose is left today, return the first dose of tomorrow
    return medication.doseTimes[doseTimesInMinutes.indexOf(doseTimesInMinutes.first)];
  }

  String _formatNextDose(String? nextDoseTime) {
    if (nextDoseTime == null) return '';

    final now = TimeOfDay.now();
    final parts = nextDoseTime.split(':');
    final doseHour = int.parse(parts[0]);
    final doseMinute = int.parse(parts[1]);
    final doseMinutes = doseHour * 60 + doseMinute;
    final currentMinutes = now.hour * 60 + now.minute;

    if (doseMinutes <= currentMinutes) {
      return 'Próxima toma: $nextDoseTime (mañana)';
    } else {
      return 'Próxima toma: $nextDoseTime';
    }
  }

  void _registerDose(Medication medication) async {
    // Close the modal first
    Navigator.pop(context);

    // Check if medication has dose times configured
    if (medication.doseTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este medicamento no tiene horarios configurados'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if there's any stock available (quick check before showing dialog)
    if (medication.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay stock disponible de este medicamento'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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
        customDays: medication.customDays,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - doseQuantity,
        takenDosesToday: updatedTakenDoses,
        skippedDosesToday: updatedSkippedDoses,
        takenDosesDate: todayString,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reschedule notifications
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

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
                TextField(
                  controller: refillController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad a agregar',
                    hintText: medication.lastRefillAmount != null
                        ? 'Ej: ${medication.lastRefillAmount}'
                        : 'Ej: 30',
                    suffixText: medication.type.stockUnit,
                    helperText: medication.lastRefillAmount != null
                        ? 'Última recarga: ${medication.lastRefillAmount} ${medication.type.stockUnit}'
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.add_box),
                  ),
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
        customDays: medication.customDays,
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
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
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
                                  size: 12,
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
                        await NotificationService.instance.cancelMedicationNotifications(medication.id);

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
    final pendingNotifications = await NotificationService.instance.getPendingNotifications();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug de Notificaciones'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✓ Permisos otorgados: ${notificationsEnabled ? "Sí" : "No"}'),
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
                ...pendingNotifications.map((notification) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${notification.id}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            notification.title ?? "Sin título",
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (notification.body != null)
                            Text(
                              notification.body!,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
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
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (medication.doseTimes.isEmpty)
                        const Text('  ⚠️ Sin horarios configurados', style: TextStyle(fontSize: 11, color: Colors.orange))
                      else
                        ...medication.doseTimes.map((time) => Text('  • $time', style: const TextStyle(fontSize: 11))),
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

  void _navigateToStock() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicationStockScreen(),
      ),
    );
  }

  void _showMainActionMenu() {
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToStock();
                  },
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Ver Pastillero'),
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
          ? Center(
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
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
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

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
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
                        if (_getNextDoseTime(medication) != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _formatNextDose(_getNextDoseTime(medication)),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMainActionMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}
