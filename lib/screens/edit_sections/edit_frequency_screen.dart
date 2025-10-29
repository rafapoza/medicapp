import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../models/treatment_duration_type.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';
import 'edit_frequency/widgets/frequency_options_list.dart';
import 'edit_frequency/widgets/specific_dates_config_card.dart';
import 'edit_frequency/widgets/weekly_pattern_config_card.dart';
import 'edit_frequency/widgets/custom_interval_config_card.dart';
import 'edit_duration/widgets/save_cancel_buttons.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
            SnackBar(
              content: Text(l10n.editFrequencySelectAtLeastOneDate),
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
            SnackBar(
              content: Text(l10n.editFrequencySelectAtLeastOneDay),
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
            SnackBar(
              content: Text(l10n.editFrequencyIntervalMin),
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
          content: Text(l10n.editFrequencyUpdated),
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
          content: Text(l10n.editFrequencyError(e.toString())),
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
        title: Text(l10n.editFrequencyTitle),
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
                        l10n.editFrequencyPattern,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.editFrequencyQuestion,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Frequency options
                      FrequencyOptionsList(
                        selectedMode: _selectedMode,
                        onModeChanged: (value) => setState(() => _selectedMode = value),
                      ),
                    ],
                  ),
                ),
              ),

              // Show additional controls based on selected mode
              if (_selectedMode == FrequencyMode.specificDates) ...[
                const SizedBox(height: 16),
                SpecificDatesConfigCard(
                  selectedDates: _selectedDates,
                  onDatesChanged: (dates) => setState(() => _selectedDates = dates),
                ),
              ],

              if (_selectedMode == FrequencyMode.weeklyPattern) ...[
                const SizedBox(height: 16),
                WeeklyPatternConfigCard(
                  weeklyDays: _weeklyDays,
                  onDaysChanged: (days) => setState(() => _weeklyDays = days),
                ),
              ],

              if (_selectedMode == FrequencyMode.customInterval) ...[
                const SizedBox(height: 16),
                CustomIntervalConfigCard(
                  intervalController: _intervalController,
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
