import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../models/medication_type.dart';

/// Widget reutilizable para el formulario de información básica del medicamento
/// Usado tanto en creación como en edición de medicamentos
class MedicationInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final MedicationType selectedType;
  final ValueChanged<MedicationType> onTypeChanged;
  final List<Medication> existingMedications;
  final String? existingMedicationId;
  final bool showDescription;

  const MedicationInfoForm({
    super.key,
    required this.nameController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.existingMedications,
    this.existingMedicationId,
    this.showDescription = true,
  });

  bool _medicationExists(String name) {
    return existingMedications.any(
      (medication) =>
          medication.id != existingMedicationId &&
          medication.name.toLowerCase() == name.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDescription) ...[
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
        ],

        // Campo de nombre
        if (!showDescription)
          Text(
            'Nombre del medicamento',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        if (!showDescription) const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nombre del medicamento',
            hintText: 'Ej: Paracetamol',
            prefixIcon: const Icon(Icons.medication),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: showDescription,
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
        SizedBox(height: showDescription ? 32 : 24),

        // Selector de tipo
        Text(
          'Tipo de medicamento',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: showDescription ? FontWeight.w600 : null,
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
                final isSelected = selectedType == type;
                return InkWell(
                  onTap: () => onTypeChanged(type),
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
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }
}
