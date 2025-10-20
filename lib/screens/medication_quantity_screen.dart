import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

/// Pantalla 7: Cantidad de medicamentos (última pantalla del flujo)
class MedicationQuantityScreen extends StatefulWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? specificDates;
  final List<int>? weeklyDays;
  final int? dayInterval;
  final int dosageIntervalHours;
  final Map<String, double> doseSchedule;
  final bool requiresFasting;
  final String? fastingType;
  final int? fastingDurationMinutes;
  final bool notifyFasting;

  const MedicationQuantityScreen({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    this.startDate,
    this.endDate,
    this.specificDates,
    this.weeklyDays,
    this.dayInterval,
    required this.dosageIntervalHours,
    required this.doseSchedule,
    this.requiresFasting = false,
    this.fastingType,
    this.fastingDurationMinutes,
    this.notifyFasting = false,
  });

  @override
  State<MedicationQuantityScreen> createState() => _MedicationQuantityScreenState();
}

class _MedicationQuantityScreenState extends State<MedicationQuantityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stockController = TextEditingController(text: '0');
  final _lowStockThresholdController = TextEditingController(text: '3');
  bool _isSaving = false;

  @override
  void dispose() {
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create medication object
      final newMedication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: widget.medicationName,
        type: widget.medicationType,
        dosageIntervalHours: widget.dosageIntervalHours,
        durationType: widget.durationType,
        selectedDates: widget.specificDates,
        weeklyDays: widget.weeklyDays,
        dayInterval: widget.dayInterval,
        doseSchedule: widget.doseSchedule,
        stockQuantity: double.tryParse(_stockController.text) ?? 0,
        lowStockThresholdDays: int.tryParse(_lowStockThresholdController.text) ?? 3,
        startDate: widget.startDate,
        endDate: widget.endDate,
        requiresFasting: widget.requiresFasting,
        fastingType: widget.fastingType,
        fastingDurationMinutes: widget.fastingDurationMinutes,
        notifyFasting: widget.notifyFasting,
      );

      // Save to database
      await DatabaseHelper.instance.insertMedication(newMedication);

      // Schedule notifications
      await NotificationService.instance.scheduleMedicationNotifications(newMedication);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newMedication.name} añadido correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Return to the initial screen (close all the stack)
      Navigator.pop(context, newMedication);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el medicamento: $e'),
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
    final stepNumber = widget.durationType == TreatmentDurationType.asNeeded
        ? '2 de 2'
        : widget.durationType == TreatmentDurationType.specificDates
            ? '7 de 7'
            : '8 de 8';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cantidad de Medicamento'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador de progreso
                LinearProgressIndicator(
                  value: 1.0, // Always 100% since this is the last step
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
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cantidad de medicamento',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Establece la cantidad disponible y cuándo deseas recibir alertas',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Stock quantity label
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Cantidad disponible',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${widget.medicationType.stockUnit})',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stock quantity field
                        TextFormField(
                          controller: _stockController,
                          decoration: InputDecoration(
                            hintText: 'Ej: 30',
                            helperText: 'Cantidad de ${widget.medicationType.stockUnit} que tienes actualmente',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, introduce la cantidad disponible';
                            }

                            final quantity = double.tryParse(value.trim());
                            if (quantity == null || quantity < 0) {
                              return 'La cantidad debe ser mayor o igual a 0';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Low stock threshold
                        TextFormField(
                          controller: _lowStockThresholdController,
                          decoration: InputDecoration(
                            labelText: 'Avisar cuando queden',
                            hintText: 'Ej: 3',
                            prefixIcon: const Icon(Icons.notifications_active),
                            suffixText: 'días',
                            helperText: 'Días de antelación para recibir la alerta de bajo stock',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, introduce los días de antelación';
                            }

                            final days = int.tryParse(value.trim());
                            if (days == null || days < 1) {
                              return 'Debe ser al menos 1 día';
                            }

                            if (days > 30) {
                              return 'No puede ser mayor a 30 días';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resumen del medicamento
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Resumen',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          Icons.medication,
                          'Medicamento',
                          widget.medicationName,
                        ),
                        _buildSummaryRow(
                          widget.medicationType.icon,
                          'Tipo',
                          widget.medicationType.displayName,
                        ),
                        if (widget.doseSchedule.isNotEmpty) ...[
                          _buildSummaryRow(
                            Icons.access_time,
                            'Tomas al día',
                            '${widget.doseSchedule.length}',
                          ),
                          _buildSummaryRow(
                            Icons.schedule,
                            'Horarios',
                            widget.doseSchedule.keys.join(', '),
                          ),
                        ],
                        _buildSummaryRow(
                          Icons.calendar_today,
                          'Frecuencia',
                          _getFrequencyDescription(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón guardar
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveMedication,
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
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar Medicamento'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),

                // Botón atrás
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
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
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFrequencyDescription() {
    switch (widget.durationType) {
      case TreatmentDurationType.everyday:
        return 'Todos los días';
      case TreatmentDurationType.untilFinished:
        return 'Hasta acabar medicación';
      case TreatmentDurationType.specificDates:
        return '${widget.specificDates?.length ?? 0} fechas específicas';
      case TreatmentDurationType.weeklyPattern:
        return '${widget.weeklyDays?.length ?? 0} días de la semana';
      case TreatmentDurationType.intervalDays:
        final interval = widget.dayInterval ?? 2;
        return 'Cada $interval días';
      case TreatmentDurationType.asNeeded:
        return 'Según necesidad';
    }
  }
}
