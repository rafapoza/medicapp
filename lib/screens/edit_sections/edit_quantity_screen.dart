import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        requiresFasting: widget.medication.requiresFasting,
        fastingType: widget.medication.fastingType,
        fastingDurationMinutes: widget.medication.fastingDurationMinutes,
        notifyFasting: widget.medication.notifyFasting,
        isSuspended: widget.medication.isSuspended,
        lastDailyConsumption: widget.medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editQuantityUpdated),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, updatedMedication);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editQuantityError(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editQuantityTitle),
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
                                l10n.editQuantityMedicationLabel,
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
                          l10n.editQuantityDescription,
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
                                l10n.editQuantityAvailableLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${widget.medication.type.stockUnit})',
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
                            hintText: l10n.availableQuantityHint,
                            helperText: l10n.editQuantityAvailableHelp(widget.medication.type.stockUnit),
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
                              return l10n.editQuantityValidationRequired;
                            }

                            final quantity = double.tryParse(value.trim());
                            if (quantity == null || quantity < 0) {
                              return l10n.editQuantityValidationMin;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Low stock threshold
                        TextFormField(
                          controller: _lowStockThresholdController,
                          decoration: InputDecoration(
                            labelText: l10n.editQuantityThresholdLabel,
                            hintText: l10n.lowStockAlertHint,
                            prefixIcon: const Icon(Icons.notifications_active),
                            suffixText: l10n.pillOrganizerDays,
                            helperText: l10n.editQuantityThresholdHelp,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.editQuantityThresholdValidationRequired;
                            }

                            final days = int.tryParse(value.trim());
                            if (days == null || days < 1) {
                              return l10n.editQuantityThresholdValidationMin;
                            }

                            if (days > 30) {
                              return l10n.editQuantityThresholdValidationMax;
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
                  label: Text(_isSaving ? l10n.savingButton : l10n.editBasicInfoSaveChanges),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: Text(l10n.btnCancel),
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
