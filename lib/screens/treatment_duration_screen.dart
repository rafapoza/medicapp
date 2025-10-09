import 'package:flutter/material.dart';
import '../models/treatment_duration_type.dart';

class TreatmentDurationScreen extends StatefulWidget {
  final TreatmentDurationType? initialDurationType;
  final int? initialCustomDays;

  const TreatmentDurationScreen({
    super.key,
    this.initialDurationType,
    this.initialCustomDays,
  });

  @override
  State<TreatmentDurationScreen> createState() =>
      _TreatmentDurationScreenState();
}

class _TreatmentDurationScreenState extends State<TreatmentDurationScreen> {
  late TreatmentDurationType _selectedDurationType;
  final _customDaysController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedDurationType =
        widget.initialDurationType ?? TreatmentDurationType.everyday;
    if (widget.initialCustomDays != null) {
      _customDaysController.text = widget.initialCustomDays.toString();
    }
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_selectedDurationType == TreatmentDurationType.custom) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    final customDays = _selectedDurationType == TreatmentDurationType.custom
        ? int.parse(_customDaysController.text)
        : null;

    Navigator.pop(context, {
      'durationType': _selectedDurationType,
      'customDays': customDays,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duración del tratamiento'),
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
                          '¿Cuántos días vas a tomar este medicamento?',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...TreatmentDurationType.values.map((type) {
                          final isSelected = _selectedDurationType == type;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDurationType = type;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? type.getColor(context).withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? type.getColor(context)
                                        : Theme.of(context).dividerColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      type.icon,
                                      color: isSelected
                                          ? type.getColor(context)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        type.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? type.getColor(context)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: type.getColor(context),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_selectedDurationType ==
                            TreatmentDurationType.custom) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customDaysController,
                            decoration: InputDecoration(
                              labelText: 'Número de días',
                              hintText: 'Ej: 7',
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixText: 'días',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, introduce el número de días';
                              }

                              final days = int.tryParse(value.trim());
                              if (days == null || days <= 0) {
                                return 'El número de días debe ser mayor a 0';
                              }

                              if (days > 365) {
                                return 'El número de días no puede ser mayor a 365';
                              }

                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _continue,
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
