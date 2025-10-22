import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_type.dart';
import '../widgets/forms/medication_info_form.dart';
import 'medication_duration_screen.dart';

/// Pantalla 1: Información básica del medicamento (nombre y tipo)
class MedicationInfoScreen extends StatefulWidget {
  final List<Medication> existingMedications;

  const MedicationInfoScreen({
    super.key,
    required this.existingMedications,
  });

  @override
  State<MedicationInfoScreen> createState() => _MedicationInfoScreenState();
}

class _MedicationInfoScreenState extends State<MedicationInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  MedicationType _selectedType = MedicationType.pastilla;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continueToNextStep() async {
    if (_formKey.currentState!.validate()) {
      // Pasar datos a la siguiente pantalla
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationDurationScreen(
            medicationName: _nameController.text.trim(),
            medicationType: _selectedType,
          ),
        ),
      );

      // Si se completó el flujo, retornar el medicamento creado
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Medicamento'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Paso 1 de 6',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador de progreso
                LinearProgressIndicator(
                  value: 1 / 6,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 24),

                // Card con formulario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MedicationInfoForm(
                      nameController: _nameController,
                      selectedType: _selectedType,
                      onTypeChanged: (type) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      existingMedications: widget.existingMedications,
                      showDescription: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón continuar
                FilledButton.icon(
                  onPressed: _continueToNextStep,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 8),

                // Botón cancelar
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
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
