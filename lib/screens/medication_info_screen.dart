import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_type.dart';
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

  bool _medicationExists(String name) {
    return widget.existingMedications.any(
      (medication) => medication.name.toLowerCase() == name.toLowerCase(),
    );
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

                // Card con información
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del medicamento',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comienza proporcionando el nombre y tipo de medicamento',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Nombre del medicamento
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del medicamento',
                            hintText: 'Ej: Paracetamol',
                            prefixIcon: const Icon(Icons.medication),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
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
                        const SizedBox(height: 32),

                        // Tipo de medicamento
                        Text(
                          'Tipo de medicamento',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
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
