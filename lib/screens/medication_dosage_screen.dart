import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import 'medication_times_screen.dart';

/// Pantalla 4: Dosis (todos los días igual o cada día diferente)
class MedicationDosageScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? specificDates;
  final List<int>? weeklyDays;
  final int? dayInterval;

  const MedicationDosageScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.startDate,
    this.endDate,
    this.specificDates,
    this.weeklyDays,
    this.dayInterval,
  });

  @override
  State<MedicationDosageScreen> createState() => _MedicationDosageScreenState();
}

enum DosageMode {
  sameEveryDay,
  custom,
}

class _MedicationDosageScreenState extends State<MedicationDosageScreen> {
  DosageMode _selectedMode = DosageMode.sameEveryDay;
  final _intervalController = TextEditingController(text: '8');
  final _customDosesController = TextEditingController(text: '3');

  @override
  void dispose() {
    _intervalController.dispose();
    _customDosesController.dispose();
    super.dispose();
  }

  int _calculateDosesFromInterval() {
    final interval = int.tryParse(_intervalController.text) ?? 8;
    if (interval > 0 && 24 % interval == 0) {
      return 24 ~/ interval;
    }
    return 3; // Default
  }

  int _getDosesPerDay() {
    if (_selectedMode == DosageMode.sameEveryDay) {
      return _calculateDosesFromInterval();
    } else {
      return int.tryParse(_customDosesController.text) ?? 3;
    }
  }

  void _continueToNextStep() {
    int dosageIntervalHours;
    int dosesPerDay;

    if (_selectedMode == DosageMode.sameEveryDay) {
      // Validar que el intervalo divida 24 exactamente
      final interval = int.tryParse(_intervalController.text);

      if (interval == null || interval <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, introduce un intervalo válido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (interval > 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El intervalo no puede ser mayor a 24 horas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (24 % interval != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El intervalo debe dividir 24 exactamente (1, 2, 3, 4, 6, 8, 12, 24)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      dosageIntervalHours = interval;
      dosesPerDay = 24 ~/ interval;
    } else {
      // Modo personalizado
      final doses = int.tryParse(_customDosesController.text);

      if (doses == null || doses <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, introduce un número de tomas válido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (doses > 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No puedes tomar más de 24 dosis al día'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Para modo personalizado, usamos un intervalo ficticio
      // Esto es solo para compatibilidad con el modelo existente
      dosageIntervalHours = 24 ~/ doses;
      dosesPerDay = doses;
    }

    // Continuar a la pantalla de horarios
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationTimesScreen(
          medicationName: widget.medicationName,
          medicationType: widget.medicationType,
          durationType: widget.durationType,
          startDate: widget.startDate,
          endDate: widget.endDate,
          specificDates: widget.specificDates,
          weeklyDays: widget.weeklyDays,
          dayInterval: widget.dayInterval,
          dosageIntervalHours: dosageIntervalHours,
          dosesPerDay: dosesPerDay,
          isCustomDosage: _selectedMode == DosageMode.custom,
        ),
      ),
    ).then((result) {
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dosesPerDay = _getDosesPerDay();
    final stepNumber = widget.durationType == TreatmentDurationType.specificDates ? '4 de 6' : '5 de 7';
    final progressValue = widget.durationType == TreatmentDurationType.specificDates ? 4 / 6 : 5 / 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Dosis'),
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
                        'Configuración de dosis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Cómo prefieres configurar las dosis diarias?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Opciones de modo
                      _buildDosageModeOption(
                        DosageMode.sameEveryDay,
                        Icons.schedule,
                        'Todos los días igual',
                        'Especifica cada cuántas horas tomar el medicamento',
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildDosageModeOption(
                        DosageMode.custom,
                        Icons.tune,
                        'Personalizado',
                        'Define el número de tomas por día',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),

              // Controles según el modo seleccionado
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedMode == DosageMode.sameEveryDay) ...[
                        Text(
                          'Intervalo entre tomas',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El intervalo debe dividir 24 exactamente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _intervalController,
                          decoration: InputDecoration(
                            labelText: 'Cada cuántas horas',
                            hintText: 'Ej: 8',
                            prefixIcon: const Icon(Icons.access_time),
                            suffixText: 'horas',
                            helperText: 'Valores válidos: 1, 2, 3, 4, 6, 8, 12, 24',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {}); // Actualizar el contador de dosis
                          },
                        ),
                      ] else ...[
                        Text(
                          'Número de tomas al día',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Define cuántas veces al día tomarás el medicamento',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customDosesController,
                          decoration: InputDecoration(
                            labelText: 'Tomas por día',
                            hintText: 'Ej: 3',
                            prefixIcon: const Icon(Icons.medication),
                            suffixText: 'tomas',
                            helperText: 'Número total de tomas diarias',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {}); // Actualizar el contador de dosis
                          },
                        ),
                      ],

                      // Resumen de dosis
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
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tomas por día',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$dosesPerDay ${dosesPerDay == 1 ? 'toma' : 'tomas'}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildDosageModeOption(
    DosageMode mode,
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
