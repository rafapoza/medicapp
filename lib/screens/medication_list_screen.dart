import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'add_medication_screen.dart';
import 'edit_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
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

  void _showDeleteModal(Medication medication) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
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
              Icon(
                medication.type.icon,
                size: 48,
                color: medication.type.getColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                medication.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                medication.type.displayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: medication.type.getColor(context),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      medication.durationType.icon,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      medication.durationDisplayText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _navigateToEditMedication(medication),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar medicamento'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar medicamento'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Medicamentos'),
        actions: [
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
        ],
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
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
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
                              Text(
                                _formatNextDose(_getNextDoseTime(medication)),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    onTap: () => _showDeleteModal(medication),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMedication,
        child: const Icon(Icons.add),
      ),
    );
  }
}
