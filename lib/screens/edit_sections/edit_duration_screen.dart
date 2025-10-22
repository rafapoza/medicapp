import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../models/treatment_duration_type.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';
import '../specific_dates_selector_screen.dart';

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
  late int? _customDays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _durationType = widget.medication.durationType;
    _startDate = widget.medication.startDate;
    _endDate = widget.medication.endDate;

    // Calculate custom days if there's an end date
    if (_startDate != null && _endDate != null) {
      _customDays = _endDate!.difference(_startDate!).inDays + 1;
    } else {
      _customDays = null;
    }
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.editDurationTypeLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.editDurationCurrentType(_durationType.displayName),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.editDurationChangeTypeInfo,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_durationType == TreatmentDurationType.everyday ||
                  _durationType == TreatmentDurationType.untilFinished ||
                  _durationType == TreatmentDurationType.weeklyPattern ||
                  _durationType == TreatmentDurationType.intervalDays) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.editDurationTreatmentDates,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Start date
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(l10n.editDurationStartDate),
                          subtitle: Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : l10n.editDurationNotSelected,
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _selectDate(context, true),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Theme.of(context).dividerColor),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // End date
                        ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(l10n.editDurationEndDate),
                          subtitle: Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : l10n.editDurationNotSelected,
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _selectDate(context, false),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Theme.of(context).dividerColor),
                          ),
                        ),

                        if (_startDate != null && _endDate != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.editDurationDays(_endDate!.difference(_startDate!).inDays + 1),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                label: Text(_isSaving ? l10n.editBasicInfoSaving : l10n.editBasicInfoSaveChanges),
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
    );
  }
}
