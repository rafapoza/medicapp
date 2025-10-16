import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../database/database_helper.dart';

/// Pantalla para editar la cantidad disponible y umbral de bajo stock
class EditQuantityScreen extends StatefulWidget {
  final Medication medication;

  const EditQuantityScreen({
    super.key,
    required this.medication,
  });

  @override
  State<EditQuantityScreen> createState() => _EditQuantityScreenState();
}

class _EditQuantityScreenState extends State<EditQuantityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _stockController;
  late final TextEditingController _lowStockThresholdController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: widget.medication.stockQuantity.toString(),
    );
    _lowStockThresholdController = TextEditingController(
      text: widget.medication.lowStockThresholdDays.toString(),
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
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
        durationType: widget.medication.durationType,
        selectedDates: widget.medication.selectedDates,
        weeklyDays: widget.medication.weeklyDays,
        dayInterval: widget.medication.dayInterval,
        doseSchedule: widget.medication.doseSchedule,
        stockQuantity: double.tryParse(_stockController.text) ?? 0,
        takenDosesToday: widget.medication.takenDosesToday,
        skippedDosesToday: widget.medication.skippedDosesToday,
        takenDosesDate: widget.medication.takenDosesDate,
        lastRefillAmount: widget.medication.lastRefillAmount,
        lowStockThresholdDays: int.tryParse(_lowStockThresholdController.text) ?? 3,
        startDate: widget.medication.startDate,
        endDate: widget.medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cantidad actualizada correctamente'),
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
        title: const Text('Editar Cantidad'),
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

                        // Stock quantity
                        TextFormField(
                          controller: _stockController,
                          decoration: InputDecoration(
                            labelText: 'Cantidad disponible',
                            hintText: 'Ej: 30',
                            prefixIcon: const Icon(Icons.inventory_2),
                            suffixText: widget.medication.type.stockUnit,
                            helperText: 'Cantidad de ${widget.medication.type.stockUnit} que tienes actualmente',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
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
      ),
    );
  }
}
