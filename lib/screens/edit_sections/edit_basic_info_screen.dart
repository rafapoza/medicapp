import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../models/medication_type.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';

/// Pantalla para editar información básica del medicamento (nombre y tipo)
class EditBasicInfoScreen extends StatefulWidget {
  final Medication medication;
  final List<Medication> existingMedications;

  const EditBasicInfoScreen({
    super.key,
    required this.medication,
    required this.existingMedications,
  });

  @override
  State<EditBasicInfoScreen> createState() => _EditBasicInfoScreenState();
}

class _EditBasicInfoScreenState extends State<EditBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late MedicationType _selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _selectedType = widget.medication.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _medicationExists(String name) {
    return widget.existingMedications.any(
      (medication) =>
          medication.id != widget.medication.id &&
          medication.name.toLowerCase() == name.toLowerCase(),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedMedication = Medication(
        id: widget.medication.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        dosageIntervalHours: widget.medication.dosageIntervalHours,
        durationType: widget.medication.durationType,
        selectedDates: widget.medication.selectedDates,
        weeklyDays: widget.medication.weeklyDays,
        dayInterval: widget.medication.dayInterval,
        doseSchedule: widget.medication.doseSchedule,
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

      // Reprogramar notificaciones si el nombre cambió
      if (widget.medication.name != updatedMedication.name) {
        await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Información actualizada correctamente'),
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
        title: const Text('Editar Información Básica'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre del medicamento',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del medicamento',
                            hintText: 'Ej: Paracetamol',
                            prefixIcon: const Icon(Icons.medication),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, introduce el nombre del medicamento';
                            }

                            if (_medicationExists(value.trim())) {
                              return 'Este medicamento ya existe en tu lista';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tipo de medicamento',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final spacing = 8.0;
                            final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: MedicationType.values.map((type) {
                                final isSelected = _selectedType == type;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedType = type;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: itemWidth,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? type.getColor(context).withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? type.getColor(context)
                                            : Theme.of(context).dividerColor,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          type.icon,
                                          size: 32,
                                          color: isSelected
                                              ? type.getColor(context)
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          type.displayName,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: isSelected
                                                    ? type.getColor(context)
                                                    : Theme.of(context).colorScheme.onSurface,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
      ),
    );
  }
}
