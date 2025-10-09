import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_type.dart';
import 'treatment_duration_screen.dart';

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
  late MedicationType _selectedType;

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
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreatmentDurationScreen(
            initialDurationType: widget.medication.durationType,
            initialCustomDays: widget.medication.customDays,
          ),
        ),
      );

      if (result != null && mounted) {
        // Create updated medication with all information
        final updatedMedication = Medication(
          id: widget.medication.id, // Keep the same ID
          name: _nameController.text.trim(),
          type: _selectedType,
          durationType: result['durationType'],
          customDays: result['customDays'],
        );

        Navigator.pop(context, updatedMedication);
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
