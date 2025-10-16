import 'package:flutter/material.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'weekly_days_selector_screen.dart';
import 'medication_dosage_screen.dart';

/// Pantalla 3: Frecuencia (cada cuántos días tomar el medicamento)
/// Se salta si se seleccionaron fechas específicas
class MedicationFrequencyScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? specificDates;
  final bool skipFrequencyScreen;

  const MedicationFrequencyScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.startDate,
    this.endDate,
    this.specificDates,
    this.skipFrequencyScreen = false,
  });

  @override
  State<MedicationFrequencyScreen> createState() => _MedicationFrequencyScreenState();
}

enum FrequencyMode {
  everyday,
  alternateDays,
  weeklyDays,
}

class _MedicationFrequencyScreenState extends State<MedicationFrequencyScreen> {
  FrequencyMode _selectedMode = FrequencyMode.everyday;
  List<int>? _weeklyDays;

  @override
  void initState() {
    super.initState();

    // Si debemos saltar esta pantalla, ir directamente a la siguiente
    if (widget.skipFrequencyScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNextScreen(
          durationType: widget.durationType,
          weeklyDays: null,
          dayInterval: null,
        );
      });
    }
  }

  Future<void> _selectWeeklyDays() async {
    final result = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyDaysSelectorScreen(
          initialSelectedDays: _weeklyDays,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _weeklyDays = result;
      });
    }
  }

  void _continueToNextStep() async {
    // Validar según el modo seleccionado
    if (_selectedMode == FrequencyMode.weeklyDays) {
      if (_weeklyDays == null || _weeklyDays!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona los días de la semana'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Determinar el tipo de duración basado en la frecuencia
    TreatmentDurationType durationType;
    List<int>? weeklyDays;
    int? dayInterval;

    switch (_selectedMode) {
      case FrequencyMode.everyday:
        durationType = TreatmentDurationType.everyday;
        weeklyDays = null;
        dayInterval = null;
        break;
      case FrequencyMode.alternateDays:
        // Días alternos: cada 2 días desde la fecha de inicio
        durationType = TreatmentDurationType.intervalDays;
        weeklyDays = null;
        dayInterval = 2;
        break;
      case FrequencyMode.weeklyDays:
        durationType = TreatmentDurationType.weeklyPattern;
        weeklyDays = _weeklyDays;
        dayInterval = null;
        break;
    }

    // Si originalmente era "hasta acabar", mantenerlo
    if (widget.durationType == TreatmentDurationType.untilFinished) {
      durationType = TreatmentDurationType.untilFinished;
    }

    _navigateToNextScreen(
      durationType: durationType,
      weeklyDays: weeklyDays,
      dayInterval: dayInterval,
    );
  }

  void _navigateToNextScreen({
    required TreatmentDurationType durationType,
    required List<int>? weeklyDays,
    required int? dayInterval,
  }) async {
    // Continuar a la pantalla de dosis
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDosageScreen(
          medicationName: widget.medicationName,
          medicationType: widget.medicationType,
          durationType: durationType,
          startDate: widget.startDate,
          endDate: widget.endDate,
          specificDates: widget.specificDates,
          weeklyDays: weeklyDays,
          dayInterval: dayInterval,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si debemos saltar esta pantalla, mostrar un loading
    if (widget.skipFrequencyScreen) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frecuencia de Medicación'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Paso 4 de 7',
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
                value: 4 / 7,
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
                        'Frecuencia de medicación',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cada cuántos días debes tomar este medicamento',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Opciones de frecuencia
                      _buildFrequencyOption(
                        FrequencyMode.everyday,
                        Icons.calendar_today,
                        'Todos los días',
                        'Medicación diaria continua',
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildFrequencyOption(
                        FrequencyMode.alternateDays,
                        Icons.repeat,
                        'Días alternos',
                        'Cada 2 días desde el inicio del tratamiento',
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildFrequencyOption(
                        FrequencyMode.weeklyDays,
                        Icons.date_range,
                        'Días de la semana específicos',
                        'Selecciona qué días tomar el medicamento',
                        Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),

              // Selector de días si se eligió "weeklyDays"
              if (_selectedMode == FrequencyMode.weeklyDays) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Días de la semana',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona los días específicos en los que tomarás el medicamento',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _selectWeeklyDays,
                          icon: const Icon(Icons.date_range),
                          label: Text(_weeklyDays == null || _weeklyDays!.isEmpty
                              ? 'Seleccionar días'
                              : '${_weeklyDays!.length} día${_weeklyDays!.length != 1 ? 's' : ''} seleccionado${_weeklyDays!.length != 1 ? 's' : ''}'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.teal,
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

  Widget _buildFrequencyOption(
    FrequencyMode mode,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    final isSelected = _selectedMode == mode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = mode;
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
              icon,
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
