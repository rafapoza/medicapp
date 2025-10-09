import 'package:flutter/material.dart';
import '../models/medication.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _medicationExists(String name) {
    return widget.existingMedications.any(
      (medication) => medication.name.toLowerCase() == name.toLowerCase(),
    );
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final newMedication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
      );

      Navigator.pop(context, newMedication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Medicamento'),
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
                label: const Text('Guardar Medicamento'),
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
