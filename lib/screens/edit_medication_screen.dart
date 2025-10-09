import 'package:flutter/material.dart';
import '../models/medication.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
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

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final updatedMedication = Medication(
        id: widget.medication.id, // Keep the same ID
        name: _nameController.text.trim(),
      );

      Navigator.pop(context, updatedMedication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Medicamento'),
      ),
      body: Padding(
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saveMedication,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
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
    );
  }
}
