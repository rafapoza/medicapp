import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_type.dart';
import 'treatment_duration_screen.dart';
import 'medication_schedule_screen.dart';

class EditMedicationScreen extends StatefulWidget {
  final Medication medication;
  final List<Medication> existingMedications;

  const EditMedicationScreen({
    super.key,
    required this.medication,
    required this.existingMedications,
  });

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageIntervalController;
  late final TextEditingController _stockController;
  late final TextEditingController _lowStockThresholdController;
  late MedicationType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _dosageIntervalController = TextEditingController(
      text: widget.medication.dosageIntervalHours.toString(),
    );
    _stockController = TextEditingController(
      text: widget.medication.stockQuantity.toString(),
    );
    _lowStockThresholdController = TextEditingController(
      text: widget.medication.lowStockThresholdDays.toString(),
    );
    _selectedType = widget.medication.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageIntervalController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  bool _medicationExists(String name) {
    // Check if the name already exists, but exclude the current medication
    return widget.existingMedications.any(
      (medication) =>
          medication.id != widget.medication.id &&
          medication.name.toLowerCase() == name.toLowerCase(),
    );
  }

  void _continueToNextStep() async {
    if (_formKey.currentState!.validate()) {
      // Navigate to treatment duration screen with existing data
      final durationResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreatmentDurationScreen(
            initialDurationType: widget.medication.durationType,
            initialCustomDays: widget.medication.customDays,
            initialSelectedDates: widget.medication.selectedDates,
            initialWeeklyDays: widget.medication.weeklyDays,
          ),
        ),
      );

      if (durationResult != null && mounted) {
        // Navigate to medication schedule screen with existing data
        final scheduleResult = await Navigator.push<Map<String, double>>(
          context,
          MaterialPageRoute(
            builder: (context) => MedicationScheduleScreen(
              dosageIntervalHours: int.parse(_dosageIntervalController.text),
              medicationType: _selectedType,
              initialDoseSchedule: widget.medication.doseSchedule,
              autoFillForTesting: kDebugMode, // Auto-fill in debug mode for testing
            ),
          ),
        );

        if (scheduleResult != null && mounted) {
          // Create updated medication with all information
          final updatedMedication = Medication(
            id: widget.medication.id, // Keep the same ID
            name: _nameController.text.trim(),
            type: _selectedType,
            dosageIntervalHours: int.parse(_dosageIntervalController.text),
            durationType: durationResult['durationType'],
            customDays: durationResult['customDays'],
            selectedDates: durationResult['selectedDates'] as List<String>?,
            weeklyDays: durationResult['weeklyDays'] as List<int>?,
            doseSchedule: scheduleResult,
            stockQuantity: double.tryParse(_stockController.text) ?? 0,
            // Preserve taken doses information when editing
            takenDosesToday: widget.medication.takenDosesToday,
            skippedDosesToday: widget.medication.skippedDosesToday,
            takenDosesDate: widget.medication.takenDosesDate,
            lastRefillAmount: widget.medication.lastRefillAmount,
            lowStockThresholdDays: int.tryParse(_lowStockThresholdController.text) ?? 3,
          );

          Navigator.pop(context, updatedMedication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Medicamento'),
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
                        'Información del medicamento',
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
                      TextFormField(
                        controller: _dosageIntervalController,
                        decoration: InputDecoration(
                          labelText: 'Frecuencia de tomas',
                          hintText: 'Ej: 8',
                          prefixIcon: const Icon(Icons.access_time),
                          suffixText: 'horas',
                          helperText: 'Intervalo entre tomas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, introduce la frecuencia de horas';
                          }

                          final hours = int.tryParse(value.trim());
                          if (hours == null || hours <= 0) {
                            return 'El número de horas debe ser mayor a 0';
                          }

                          if (hours > 24) {
                            return 'El número de horas no puede ser mayor a 24';
                          }

                          if (24 % hours != 0) {
                            return 'Las horas deben dividir 24 exactamente (1, 2, 3, 4, 6, 8, 12, 24)';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'Cantidad disponible',
                          hintText: 'Ej: 30',
                          prefixIcon: const Icon(Icons.inventory_2),
                          suffixText: _selectedType.stockUnit,
                          helperText: 'Cantidad de ${_selectedType.stockUnit} que tienes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, introduce la cantidad disponible';
                          }

                          final quantity = double.tryParse(value.trim());
                          if (quantity == null || quantity < 0) {
                            return 'La cantidad debe ser mayor o igual a 0';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _lowStockThresholdController,
                        decoration: InputDecoration(
                          labelText: 'Avisar cuando queden',
                          hintText: 'Ej: 3',
                          prefixIcon: const Icon(Icons.notifications_active),
                          suffixText: 'días',
                          helperText: 'Días de antelación para el aviso',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, introduce los días';
                          }

                          final days = int.tryParse(value.trim());
                          if (days == null || days < 1) {
                            return 'Debe ser al menos 1 día';
                          }

                          if (days > 30) {
                            return 'No puede ser mayor a 30 días';
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
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _continueToNextStep,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
