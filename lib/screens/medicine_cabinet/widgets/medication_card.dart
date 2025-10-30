import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';
import '../../../models/treatment_duration_type.dart';
import '../../../models/dose_history_entry.dart';
import '../../../database/database_helper.dart';
import '../../../services/notification_service.dart';
import '../../../services/dose_action_service.dart';
import '../../edit_medication_menu_screen.dart';
import 'medication_options_modal.dart';
import '../../medication_list/dialogs/refill_input_dialog.dart';
import '../../medication_list/dialogs/manual_dose_input_dialog.dart';
import '../medication_person_assignment_screen.dart';

class MedicationCard extends StatefulWidget {
  final Medication medication;
  final VoidCallback onMedicationUpdated;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onMedicationUpdated,
  });

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  void _showMedicationModal() {
    MedicationOptionsModal.show(
      context,
      medication: widget.medication,
      onResume: widget.medication.isSuspended ? _resumeMedication : null,
      onRegisterDose: widget.medication.durationType == TreatmentDurationType.asNeeded &&
                      !widget.medication.isSuspended
          ? _registerManualDose
          : null,
      onRefill: _refillMedication,
      onEdit: _editMedication,
      onAssignPersons: _assignPersons,
      onDelete: _deleteMedication,
    );
  }

  void _assignPersons() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationPersonAssignmentScreen(
          medication: widget.medication,
        ),
      ),
    );
    // Reload medications after assignment
    widget.onMedicationUpdated();
  }

  void _refillMedication() async {
    final l10n = AppLocalizations.of(context)!;

    final refillAmount = await RefillInputDialog.show(
      context,
      medication: widget.medication,
    );

    if (refillAmount != null && refillAmount > 0) {
      // Update medication with new stock and save refill amount
      final updatedMedication = Medication(
        id: widget.medication.id,
        name: widget.medication.name,
        type: widget.medication.type,
        dosageIntervalHours: widget.medication.dosageIntervalHours,
        durationType: widget.medication.durationType,
        doseSchedule: widget.medication.doseSchedule,
        stockQuantity: widget.medication.stockQuantity + refillAmount,
        takenDosesToday: widget.medication.takenDosesToday,
        skippedDosesToday: widget.medication.skippedDosesToday,
        takenDosesDate: widget.medication.takenDosesDate,
        lastRefillAmount: refillAmount,
        lowStockThresholdDays: widget.medication.lowStockThresholdDays,
        selectedDates: widget.medication.selectedDates,
        weeklyDays: widget.medication.weeklyDays,
        dayInterval: widget.medication.dayInterval,
        startDate: widget.medication.startDate,
        endDate: widget.medication.endDate,
        requiresFasting: widget.medication.requiresFasting,
        fastingType: widget.medication.fastingType,
        fastingDurationMinutes: widget.medication.fastingDurationMinutes,
        notifyFasting: widget.medication.notifyFasting,
        isSuspended: widget.medication.isSuspended,
        lastDailyConsumption: widget.medication.lastDailyConsumption,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reload medications
      widget.onMedicationUpdated();

      if (!mounted) return;

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.medicineCabinetRefillSuccess(
              widget.medication.name,
              refillAmount.toString(),
              widget.medication.type.stockUnit,
              updatedMedication.stockDisplayText,
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _registerManualDose() async {
    final l10n = AppLocalizations.of(context)!;

    // Check if there's any stock available
    if (widget.medication.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medicineCabinetNoStockAvailable),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show dialog to input dose quantity
    final doseQuantity = await ManualDoseInputDialog.show(
      context,
      medication: widget.medication,
    );

    if (doseQuantity != null && doseQuantity > 0) {
      try {
        // Calculate daily consumption if needed
        double? lastDailyConsumption;
        if (widget.medication.durationType == TreatmentDurationType.asNeeded) {
          final now = DateTime.now();
          final todayHistory = await DatabaseHelper.instance.getDoseHistoryForDateRange(
            medicationId: widget.medication.id,
            startDate: DateTime(now.year, now.month, now.day),
            endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );

          final existingConsumption = todayHistory
              .where((entry) => entry.status == DoseStatus.taken)
              .fold(0.0, (sum, entry) => sum + entry.quantity);
          lastDailyConsumption = existingConsumption + doseQuantity;
        }

        // Use service to register the dose
        final updatedMedication = await DoseActionService.registerManualDose(
          medication: widget.medication,
          quantity: doseQuantity,
          lastDailyConsumption: lastDailyConsumption,
        );

        // Reload medications
        widget.onMedicationUpdated();

        if (!mounted) return;

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.medicineCabinetDoseRegistered(
                widget.medication.name,
                doseQuantity.toString(),
                widget.medication.type.stockUnit,
                updatedMedication.stockDisplayText,
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } on InsufficientStockException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.medicineCabinetInsufficientStock(
                e.doseQuantity.toString(),
                e.unit,
                widget.medication.stockDisplayText,
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _deleteMedication() async {
    final l10n = AppLocalizations.of(context)!;
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.medicineCabinetDeleteConfirmTitle),
          content: Text(
            l10n.medicineCabinetDeleteConfirmMessage(widget.medication.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.btnDelete),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Delete medication from database
      await DatabaseHelper.instance.deleteMedication(widget.medication.id);

      // Delete dose history for this medication
      await DatabaseHelper.instance.deleteDoseHistoryForMedication(widget.medication.id);

      // Reload medications
      widget.onMedicationUpdated();

      if (!mounted) return;

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medicineCabinetDeleteSuccess(widget.medication.name)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editMedication() async {
    // Load all medications to check for duplicates
    final allMedications = await DatabaseHelper.instance.getAllMedications();

    // Navigate to edit medication menu
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationMenuScreen(
          medication: widget.medication,
          existingMedications: allMedications,
        ),
      ),
    );

    // Reload medications after editing
    widget.onMedicationUpdated();
  }

  void _resumeMedication() async {
    final l10n = AppLocalizations.of(context)!;
    // Resume medication (set isSuspended to false)
    final updatedMedication = Medication(
      id: widget.medication.id,
      name: widget.medication.name,
      type: widget.medication.type,
      dosageIntervalHours: widget.medication.dosageIntervalHours,
      durationType: widget.medication.durationType,
      doseSchedule: widget.medication.doseSchedule,
      stockQuantity: widget.medication.stockQuantity,
      takenDosesToday: widget.medication.takenDosesToday,
      skippedDosesToday: widget.medication.skippedDosesToday,
      takenDosesDate: widget.medication.takenDosesDate,
      lastRefillAmount: widget.medication.lastRefillAmount,
      lowStockThresholdDays: widget.medication.lowStockThresholdDays,
      selectedDates: widget.medication.selectedDates,
      weeklyDays: widget.medication.weeklyDays,
      dayInterval: widget.medication.dayInterval,
      startDate: widget.medication.startDate,
      endDate: widget.medication.endDate,
      requiresFasting: widget.medication.requiresFasting,
      fastingType: widget.medication.fastingType,
      fastingDurationMinutes: widget.medication.fastingDurationMinutes,
      notifyFasting: widget.medication.notifyFasting,
      isSuspended: false, // Resume medication
      lastDailyConsumption: widget.medication.lastDailyConsumption,
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // Reschedule notifications for this medication
    await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

    // Reload medications
    widget.onMedicationUpdated();

    if (!mounted) return;

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.medicineCabinetResumeSuccess(widget.medication.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stockColor = widget.medication.isStockEmpty
        ? Colors.red
        : widget.medication.isStockLow
            ? Colors.orange
            : Colors.green;

    final isAsNeeded = widget.medication.durationType == TreatmentDurationType.asNeeded;

    return Opacity(
      opacity: widget.medication.isSuspended ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          onTap: _showMedicationModal,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: widget.medication.type.getColor(context).withOpacity(0.2),
            child: Icon(
              widget.medication.type.icon,
              color: widget.medication.type.getColor(context),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.medication.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (widget.medication.isSuspended) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade600,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pause_circle_outline,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.medicineCabinetSuspended,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.medication.type.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.medication.type.getColor(context),
                    ),
              ),
              if (isAsNeeded && !widget.medication.isSuspended) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.indigo,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 12,
                        color: Colors.indigo.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.medicineCabinetTapToRegister,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Stock quantity
              Text(
                widget.medication.stockDisplayText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
              ),
              const SizedBox(height: 4),
              // Stock indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: stockColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.medication.isStockEmpty
                      ? Icons.error
                      : widget.medication.isStockLow
                          ? Icons.warning
                          : Icons.check_circle,
                  size: 14,
                  color: stockColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
