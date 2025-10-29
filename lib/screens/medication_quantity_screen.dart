import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../models/medication.dart';
import '../models/medication_type.dart';
import '../models/treatment_duration_type.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'medication_quantity/widgets/stock_input_card.dart';
import 'medication_quantity/widgets/medication_summary_card.dart';
import 'medication_quantity/widgets/save_buttons.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
          content: Text(l10n.msgMedicationAddedSuccess(newMedication.name)),
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
          content: Text(l10n.msgMedicationAddError(e.toString())),
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
    final currentStep = widget.durationType == TreatmentDurationType.asNeeded
        ? 2
        : widget.durationType == TreatmentDurationType.specificDates
            ? 7
            : 8;
    final totalSteps = widget.durationType == TreatmentDurationType.asNeeded
        ? 2
        : widget.durationType == TreatmentDurationType.specificDates
            ? 7
            : 8;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationQuantityTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                l10n.stepIndicator(currentStep, totalSteps),
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
                StockInputCard(
                  stockController: _stockController,
                  lowStockController: _lowStockThresholdController,
                  medicationType: widget.medicationType,
                ),

                const SizedBox(height: 16),

                // Resumen del medicamento
                MedicationSummaryCard(
                  medicationName: widget.medicationName,
                  medicationType: widget.medicationType,
                  durationType: widget.durationType,
                  doseSchedule: widget.doseSchedule,
                  specificDates: widget.specificDates,
                  weeklyDays: widget.weeklyDays,
                  dayInterval: widget.dayInterval,
                ),

                const SizedBox(height: 24),

                SaveButtons(
                  isSaving: _isSaving,
                  onSave: _saveMedication,
                  onBack: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
