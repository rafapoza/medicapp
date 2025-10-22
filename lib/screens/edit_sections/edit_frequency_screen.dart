import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/medication.dart';
import '../../models/treatment_duration_type.dart';
import '../../widgets/forms/frequency_option_card.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';
import '../specific_dates_selector_screen.dart';
import '../weekly_days_selector_screen.dart';

/// Pantalla para editar la frecuencia del medicamento
class EditFrequencyScreen extends StatefulWidget {
  final Medication medication;

  const EditFrequencyScreen({
    super.key,
    required this.medication,
  });

  @override
  State<EditFrequencyScreen> createState() => _EditFrequencyScreenState();
}

enum FrequencyMode {
  everyday,
  untilFinished,
  specificDates,
  weeklyPattern,
  alternateDays,
  customInterval,
}

class _EditFrequencyScreenState extends State<EditFrequencyScreen> {
  late FrequencyMode _selectedMode;
  late List<String>? _selectedDates;
  late List<int>? _weeklyDays;
  late int? _dayInterval;
  final _intervalController = TextEditingController(text: '3');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.medication.selectedDates;
    _weeklyDays = widget.medication.weeklyDays;
    _dayInterval = widget.medication.dayInterval;

    // Determine current mode from medication
    _selectedMode = _getModeFromMedication();

    if (_dayInterval != null && _dayInterval != 2) {
      _intervalController.text = _dayInterval.toString();
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  FrequencyMode _getModeFromMedication() {
    switch (widget.medication.durationType) {
      case TreatmentDurationType.everyday:
        return FrequencyMode.everyday;
      case TreatmentDurationType.untilFinished:
        return FrequencyMode.untilFinished;
      case TreatmentDurationType.specificDates:
        return FrequencyMode.specificDates;
      case TreatmentDurationType.weeklyPattern:
        return FrequencyMode.weeklyPattern;
      case TreatmentDurationType.intervalDays:
        if (_dayInterval == 2) {
          return FrequencyMode.alternateDays;
        } else {
          return FrequencyMode.customInterval;
        }
      case TreatmentDurationType.asNeeded:
        // "As needed" medications don't have a frequency mode (they're taken manually)
        // This should not normally be reached, as these medications shouldn't be edited here
        return FrequencyMode.everyday; // Default fallback
    }
  }

  Future<void> _saveChanges() async {
    TreatmentDurationType durationType;
    List<String>? specificDates;
    List<int>? weeklyDays;
    int? dayInterval;

    // Convert mode to duration type and related fields
    switch (_selectedMode) {
      case FrequencyMode.everyday:
        durationType = TreatmentDurationType.everyday;
        specificDates = null;
        weeklyDays = null;
        dayInterval = null;
        break;

      case FrequencyMode.untilFinished:
        durationType = TreatmentDurationType.untilFinished;
        specificDates = null;
        weeklyDays = null;
        dayInterval = null;
        break;

      case FrequencyMode.specificDates:
        durationType = TreatmentDurationType.specificDates;
        if (_selectedDates == null || _selectedDates!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecciona al menos una fecha'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        specificDates = _selectedDates;
        weeklyDays = null;
        dayInterval = null;
        break;

      case FrequencyMode.weeklyPattern:
        durationType = TreatmentDurationType.weeklyPattern;
        if (_weeklyDays == null || _weeklyDays!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecciona al menos un día de la semana'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        specificDates = null;
        weeklyDays = _weeklyDays;
        dayInterval = null;
        break;

      case FrequencyMode.alternateDays:
        durationType = TreatmentDurationType.intervalDays;
        specificDates = null;
        weeklyDays = null;
        dayInterval = 2;
        break;

      case FrequencyMode.customInterval:
        durationType = TreatmentDurationType.intervalDays;
        final interval = int.tryParse(_intervalController.text);
        if (interval == null || interval < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El intervalo debe ser al menos 2 días'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        specificDates = null;
        weeklyDays = null;
        dayInterval = interval;
        break;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedMedication = Medication(
        id: widget.medication.id,
        name: widget.medication.name,
        type: widget.medication.type,
        dosageIntervalHours: widget.medication.dosageIntervalHours,
        durationType: durationType,
        selectedDates: specificDates,
        weeklyDays: weeklyDays,
        dayInterval: dayInterval,
        doseSchedule: widget.medication.doseSchedule,
        stockQuantity: widget.medication.stockQuantity,
        takenDosesToday: widget.medication.takenDosesToday,
        skippedDosesToday: widget.medication.skippedDosesToday,
        takenDosesDate: widget.medication.takenDosesDate,
        lastRefillAmount: widget.medication.lastRefillAmount,
        lowStockThresholdDays: widget.medication.lowStockThresholdDays,
        startDate: widget.medication.startDate,
        endDate: widget.medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reschedule notifications
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Frecuencia actualizada correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, updatedMedication);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar cambios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Frecuencia'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        'Patrón de frecuencia',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Con qué frecuencia tomarás este medicamento?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Frequency options
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.everyday,
                        selectedValue: _selectedMode,
                        icon: Icons.calendar_today,
                        title: 'Todos los días',
                        subtitle: 'Tomar el medicamento diariamente',
                        color: Colors.blue,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                      const SizedBox(height: 12),
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.untilFinished,
                        selectedValue: _selectedMode,
                        icon: Icons.hourglass_bottom,
                        title: 'Hasta acabar',
                        subtitle: 'Hasta que se termine el medicamento',
                        color: Colors.green,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                      const SizedBox(height: 12),
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.specificDates,
                        selectedValue: _selectedMode,
                        icon: Icons.event,
                        title: 'Fechas específicas',
                        subtitle: 'Seleccionar fechas concretas',
                        color: Colors.purple,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                      const SizedBox(height: 12),
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.weeklyPattern,
                        selectedValue: _selectedMode,
                        icon: Icons.view_week,
                        title: 'Días de la semana',
                        subtitle: 'Seleccionar días específicos cada semana',
                        color: Colors.indigo,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                      const SizedBox(height: 12),
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.alternateDays,
                        selectedValue: _selectedMode,
                        icon: Icons.repeat,
                        title: 'Días alternos',
                        subtitle: 'Cada 2 días desde el inicio del tratamiento',
                        color: Colors.orange,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                      const SizedBox(height: 12),
                      FrequencyOptionCard<FrequencyMode>(
                        value: FrequencyMode.customInterval,
                        selectedValue: _selectedMode,
                        icon: Icons.timeline,
                        title: 'Intervalo personalizado',
                        subtitle: 'Cada N días desde el inicio',
                        color: Colors.teal,
                        onTap: (value) => setState(() => _selectedMode = value),
                      ),
                    ],
                  ),
                ),
              ),

              // Show additional controls based on selected mode
              if (_selectedMode == FrequencyMode.specificDates) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fechas seleccionadas',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedDates != null && _selectedDates!.isNotEmpty
                              ? '${_selectedDates!.length} fechas seleccionadas'
                              : 'Ninguna fecha seleccionada',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push<List<String>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpecificDatesSelectorScreen(
                                  initialSelectedDates: _selectedDates ?? [],
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedDates = result;
                              });
                            }
                          },
                          icon: const Icon(Icons.event),
                          label: const Text('Seleccionar fechas'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_selectedMode == FrequencyMode.weeklyPattern) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Días de la semana',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _weeklyDays != null && _weeklyDays!.isNotEmpty
                              ? '${_weeklyDays!.length} días seleccionados'
                              : 'Ningún día seleccionado',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push<List<int>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeeklyDaysSelectorScreen(
                                  initialSelectedDays: _weeklyDays ?? [],
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _weeklyDays = result;
                              });
                            }
                          },
                          icon: const Icon(Icons.view_week),
                          label: const Text('Seleccionar días'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_selectedMode == FrequencyMode.customInterval) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intervalo de días',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _intervalController,
                          decoration: InputDecoration(
                            labelText: 'Cada cuántos días',
                            hintText: 'Ej: 3',
                            prefixIcon: const Icon(Icons.timeline),
                            suffixText: 'días',
                            helperText: 'Debe ser al menos 2 días',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
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
    );
  }
}
