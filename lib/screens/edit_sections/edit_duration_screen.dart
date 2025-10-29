import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../models/treatment_duration_type.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';
import '../specific_dates_selector_screen.dart';
import 'edit_duration/widgets/duration_type_info_card.dart';
import 'edit_duration/widgets/treatment_dates_card.dart';
import 'edit_duration/widgets/save_cancel_buttons.dart';

/// Pantalla para editar la duración del tratamiento
class EditDurationScreen extends StatefulWidget {
  final Medication medication;

  const EditDurationScreen({
    super.key,
    required this.medication,
  });

  @override
  State<EditDurationScreen> createState() => _EditDurationScreenState();
}

class _EditDurationScreenState extends State<EditDurationScreen> {
  late TreatmentDurationType _durationType;
  late DateTime? _startDate;
  late DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _durationType = widget.medication.durationType;
    _startDate = widget.medication.startDate;
    _endDate = widget.medication.endDate;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final l10n = AppLocalizations.of(context)!;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, reset it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;

    // Validate based on duration type
    if (_durationType == TreatmentDurationType.everyday ||
        _durationType == TreatmentDurationType.untilFinished) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.editDurationSelectDates),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
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
        durationType: _durationType,
        selectedDates: widget.medication.selectedDates,
        weeklyDays: widget.medication.weeklyDays,
        dayInterval: widget.medication.dayInterval,
        doseSchedule: widget.medication.doseSchedule,
        stockQuantity: widget.medication.stockQuantity,
        takenDosesToday: widget.medication.takenDosesToday,
        skippedDosesToday: widget.medication.skippedDosesToday,
        takenDosesDate: widget.medication.takenDosesDate,
        lastRefillAmount: widget.medication.lastRefillAmount,
        lowStockThresholdDays: widget.medication.lowStockThresholdDays,
        startDate: _startDate,
        endDate: _endDate,
        requiresFasting: widget.medication.requiresFasting,
        fastingType: widget.medication.fastingType,
        fastingDurationMinutes: widget.medication.fastingDurationMinutes,
        notifyFasting: widget.medication.notifyFasting,
        isSuspended: widget.medication.isSuspended,
        lastDailyConsumption: widget.medication.lastDailyConsumption,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reschedule notifications
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editDurationUpdated),
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
          content: Text(l10n.editDurationError(e.toString())),
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
        title: Text(l10n.editDurationTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DurationTypeInfoCard(durationType: _durationType),
              const SizedBox(height: 16),

              if (_durationType == TreatmentDurationType.everyday ||
                  _durationType == TreatmentDurationType.untilFinished ||
                  _durationType == TreatmentDurationType.weeklyPattern ||
                  _durationType == TreatmentDurationType.intervalDays) ...[
                TreatmentDatesCard(
                  startDate: _startDate,
                  endDate: _endDate,
                  onSelectStartDate: () => _selectDate(context, true),
                  onSelectEndDate: () => _selectDate(context, false),
                ),
              ],

              const SizedBox(height: 24),
              SaveCancelButtons(
                isSaving: _isSaving,
                onSave: _saveChanges,
                onCancel: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
