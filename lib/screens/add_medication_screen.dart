import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_type.dart';
import 'treatment_duration_screen.dart';

class AddMedicationScreen extends StatefulWidget {
  final List<Medication> existingMedications;

  const AddMedicationScreen({
    super.key,
    required this.existingMedications,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageIntervalController = TextEditingController(text: '8');
  MedicationType _selectedType = MedicationType.pastilla;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageIntervalController.dispose();
    super.dispose();
  }

  bool _medicationExists(String name) {
    return widget.existingMedications.any(
      (medication) => medication.name.toLowerCase() == name.toLowerCase(),
    );
  }

  void _continueToNextStep() async {
    if (_formKey.currentState!.validate()) {
      // Navigate to treatment duration screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TreatmentDurationScreen(),
        ),
      );

      if (result != null && mounted) {
        // Create medication with all information
        final newMedication = Medication(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          type: _selectedType,
          durationType: result['durationType'],
          customDays: result['customDays'],
        );

        Navigator.pop(context, newMedication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Medicamento'),
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
