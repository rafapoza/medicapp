import 'package:flutter/material.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'specific_dates_selector_screen.dart';
import 'medication_dates_screen.dart';

/// Pantalla 2: Tipo de duración del tratamiento
class MedicationDurationScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;

  const MedicationDurationScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
  });

  @override
  State<MedicationDurationScreen> createState() => _MedicationDurationScreenState();
}

class _MedicationDurationScreenState extends State<MedicationDurationScreen> {
  TreatmentDurationType _selectedDurationType = TreatmentDurationType.everyday;
  List<String>? _specificDates;

  Future<void> _selectSpecificDates() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificDatesSelectorScreen(
          initialSelectedDates: _specificDates,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _specificDates = result;
      });
    }
  }

  void _continueToNextStep() async {
    // Si se seleccionaron fechas específicas, validar
    if (_selectedDurationType == TreatmentDurationType.specificDates) {
      if (_specificDates == null || _specificDates!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona al menos una fecha'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Ir a la pantalla de fechas (inicio/fin) - solo si NO es fechas específicas
    if (_selectedDurationType != TreatmentDurationType.specificDates) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationDatesScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: _selectedDurationType,
          ),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    } else {
      // Para fechas específicas, ir directamente a la siguiente pantalla con las fechas
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationDatesScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: _selectedDurationType,
            specificDates: _specificDates,
          ),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de Tratamiento'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Paso 2 de 7',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicador de progreso
              LinearProgressIndicator(
                value: 2 / 7,
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
                        'Tipo de tratamiento',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Cómo vas a tomar este medicamento?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Opciones de tipo de duración
                      _buildDurationOption(
                        TreatmentDurationType.everyday,
                        'Tratamiento continuo',
                        'Todos los días, con patrón regular',
                      ),
                      const SizedBox(height: 12),
                      _buildDurationOption(
                        TreatmentDurationType.untilFinished,
                        'Hasta acabar medicación',
                        'Termina cuando se acabe el stock',
                      ),
                      const SizedBox(height: 12),
                      _buildDurationOption(
                        TreatmentDurationType.specificDates,
                        'Fechas específicas',
                        'Solo días concretos seleccionados',
                      ),
                    ],
                  ),
                ),
              ),

              // Selector de fechas específicas si está seleccionado
              if (_selectedDurationType == TreatmentDurationType.specificDates) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Selecciona las fechas',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Elige los días exactos en los que tomarás el medicamento',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _selectSpecificDates,
                          icon: const Icon(Icons.event),
                          label: Text(_specificDates == null || _specificDates!.isEmpty
                              ? 'Seleccionar fechas'
                              : '${_specificDates!.length} fecha${_specificDates!.length != 1 ? 's' : ''} seleccionada${_specificDates!.length != 1 ? 's' : ''}'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

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

              // Botón atrás
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Atrás'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationOption(
    TreatmentDurationType type,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedDurationType == type;
    final color = type.getColor(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDurationType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              type.icon,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? color.withOpacity(0.8)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
