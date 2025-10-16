import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'medication_frequency_screen.dart';

/// Pantalla 3: Fechas de inicio y fin del tratamiento (opcional)
class MedicationDatesScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final List<String>? specificDates;

  const MedicationDatesScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.specificDates,
  });

  @override
  State<MedicationDatesScreen> createState() => _MedicationDatesScreenState();
}

class _MedicationDatesScreenState extends State<MedicationDatesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Por defecto, no establecemos fecha de inicio (empieza hoy)
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: 'Fecha de inicio del tratamiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Si la fecha de fin es anterior a la nueva fecha de inicio, ajustarla
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 7)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: 'Fecha de fin del tratamiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _continueToNextStep() async {
    // Para fechas específicas, ir directamente a dosis (saltando frecuencia)
    if (widget.durationType == TreatmentDurationType.specificDates) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationFrequencyScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: widget.durationType,
            startDate: _startDate,
            endDate: _endDate,
            specificDates: widget.specificDates,
            skipFrequencyScreen: true,
          ),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    } else {
      // Para otros tipos, ir a la pantalla de frecuencia
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationFrequencyScreen(
            medicationName: widget.medicationName,
            medicationType: widget.medicationType,
            durationType: widget.durationType,
            startDate: _startDate,
            endDate: _endDate,
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final stepNumber = widget.durationType == TreatmentDurationType.specificDates ? '3 de 6' : '3 de 7';
    final progressValue = widget.durationType == TreatmentDurationType.specificDates ? 3 / 6 : 3 / 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechas del Tratamiento'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Paso $stepNumber',
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
                value: progressValue,
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
                        'Fechas del tratamiento',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Cuándo comenzarás y terminarás este tratamiento?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ambas fechas son opcionales. Si no las estableces, el tratamiento comenzará hoy y no tendrá fecha límite.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fecha de inicio
                      InkWell(
                        onTap: _selectStartDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _startDate != null
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.outline,
                              width: _startDate != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: _startDate != null
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Fecha de inicio',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Opcional',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _startDate != null ? dateFormat.format(_startDate!) : 'Empieza hoy',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _startDate != null ? Colors.green : null,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: _startDate != null
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botón para limpiar fecha de inicio
                      if (_startDate != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null; // También limpiar fin si había
                            });
                          },
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Empezar hoy'),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Fecha de fin (opcional)
                      InkWell(
                        onTap: _selectEndDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _endDate != null
                                  ? Colors.deepOrange
                                  : Theme.of(context).colorScheme.outline,
                              width: _endDate != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.stop,
                                color: _endDate != null
                                    ? Colors.deepOrange
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Fecha de fin',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Opcional',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _endDate != null ? dateFormat.format(_endDate!) : 'Sin fecha límite',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _endDate != null ? Colors.deepOrange : null,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: _endDate != null
                                    ? Colors.deepOrange
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botón para limpiar fecha de fin
                      if (_endDate != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Sin fecha límite'),
                        ),
                      ],

                      // Resumen de duración si ambas fechas están seleccionadas
                      if (_startDate != null && _endDate != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tratamiento de ${_endDate!.difference(_startDate!).inDays + 1} días',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
