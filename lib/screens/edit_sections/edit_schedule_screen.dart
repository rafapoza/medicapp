import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../widgets/forms/dose_schedule_editor.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';
import 'edit_duration/widgets/save_cancel_buttons.dart';

/// Pantalla para editar horarios y cantidades de las tomas
class EditScheduleScreen extends StatefulWidget {
  final Medication medication;

  const EditScheduleScreen({
    super.key,
    required this.medication,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final _editorKey = GlobalKey<DoseScheduleEditorState>();
  bool _isSaving = false;

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;
    final editorState = _editorKey.currentState;
    if (editorState == null) return;

    if (!editorState.allQuantitiesValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editScheduleValidationQuantities),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editorState.hasDuplicateTimes()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editScheduleValidationDuplicates),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final doseSchedule = editorState.getDoseSchedule();
      final dosageIntervalHours = editorState.getDosageIntervalHours();

      final updatedMedication = Medication(
        id: widget.medication.id,
        name: widget.medication.name,
        type: widget.medication.type,
        dosageIntervalHours: dosageIntervalHours,
        durationType: widget.medication.durationType,
        selectedDates: widget.medication.selectedDates,
        weeklyDays: widget.medication.weeklyDays,
        dayInterval: widget.medication.dayInterval,
        doseSchedule: doseSchedule,
        stockQuantity: widget.medication.stockQuantity,
        takenDosesToday: widget.medication.takenDosesToday,
        skippedDosesToday: widget.medication.skippedDosesToday,
        takenDosesDate: widget.medication.takenDosesDate,
        lastRefillAmount: widget.medication.lastRefillAmount,
        lowStockThresholdDays: widget.medication.lowStockThresholdDays,
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

      // Reschedule notifications with new times
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editScheduleUpdated),
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
          content: Text(l10n.editScheduleError(e.toString())),
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

  void _addDose() {
    _editorKey.currentState?.addDose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editScheduleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addDose,
            tooltip: l10n.editScheduleAddDose,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dose schedule editor
          Expanded(
            child: DoseScheduleEditor(
              key: _editorKey,
              initialDoseCount: widget.medication.doseSchedule.length,
              initialSchedule: widget.medication.doseSchedule,
              medicationType: widget.medication.type,
              allowAddRemove: true,
              headerText: l10n.editScheduleDosesPerDay(widget.medication.doseSchedule.length),
              subtitleText: l10n.editScheduleAdjustTimeAndQuantity,
            ),
          ),

          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SaveCancelButtons(
              isSaving: _isSaving,
              onSave: _saveChanges,
              onCancel: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
