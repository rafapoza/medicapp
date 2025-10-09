import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
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
    final medications = await DatabaseHelper.instance.getAllMedications();
    if (!mounted) return; // Check if widget is still mounted
    setState(() {
      _medications.clear();
      _medications.addAll(medications);
      _isLoading = false;
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

    if (newMedication != null) {
      // Save to database
      await DatabaseHelper.instance.insertMedication(newMedication);

      setState(() {
        _medications.add(newMedication);
      });
    }
  }

  void _navigateToEditMedication(Medication medication) async {
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
      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      setState(() {
        final index = _medications.indexWhere((m) => m.id == medication.id);
        if (index != -1) {
          _medications[index] = updatedMedication;
        }
      });

      // Close the modal if it's still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${updatedMedication.name} actualizado'),
          duration: const Duration(seconds: 2),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Medicamentos'),
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
