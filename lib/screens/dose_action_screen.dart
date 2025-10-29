import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../models/medication.dart';
import '../models/dose_history_entry.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../services/dose_action_service.dart';
import 'dose_action/widgets/medication_header_card.dart';
import 'dose_action/widgets/take_dose_button.dart';
import 'dose_action/widgets/skip_dose_button.dart';
import 'dose_action/widgets/postpone_buttons.dart';

class DoseActionScreen extends StatefulWidget {
  final String medicationId;
  final String doseTime;

  const DoseActionScreen({
    super.key,
    required this.medicationId,
    required this.doseTime,
  });

  @override
  State<DoseActionScreen> createState() => _DoseActionScreenState();
}

class _DoseActionScreenState extends State<DoseActionScreen> {
  Medication? _medication;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedication();
  }

  Future<void> _loadMedication() async {
    final medication = await DatabaseHelper.instance.getMedication(widget.medicationId);

    if (mounted) {
      setState(() {
        _medication = medication;
        _isLoading = false;
      });
    }
  }

  Future<void> _registerTaken() async {
    if (_medication == null) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      // Use service to register the dose
      final updatedMedication = await DoseActionService.registerTakenDose(
        medication: _medication!,
        doseTime: widget.doseTime,
      );

      if (!mounted) return;

      // Show confirmation and go back
      Navigator.pop(context, true); // Return true to indicate changes were made
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.doseActionTakenRegistered(
              _medication!.name,
              widget.doseTime,
              updatedMedication.stockDisplayText,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } on InsufficientStockException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.doseActionInsufficientStock(
              e.doseQuantity.toString(),
              e.unit,
              _medication!.stockDisplayText,
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _registerSkipped() async {
    if (_medication == null) return;

    // Use service to register the skipped dose
    await DoseActionService.registerSkippedDose(
      medication: _medication!,
      doseTime: widget.doseTime,
    );

    if (!mounted) return;

    // Show confirmation and go back
    Navigator.pop(context, true); // Return true to indicate changes were made
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.doseActionSkippedRegistered(
            _medication!.name,
            widget.doseTime,
            _medication!.stockDisplayText,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _postponeDose() async {
    if (_medication == null) return;

    // Show time picker to select new time
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (newTime == null) return;

    // Format the new time
    final newTimeString = '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';

    // Schedule a one-time notification for this dose
    await NotificationService.instance.schedulePostponedDoseNotification(
      medication: _medication!,
      originalDoseTime: widget.doseTime,
      newTime: newTime,
    );

    if (!mounted) return;

    // Show confirmation and go back
    Navigator.pop(context, true); // Return true to indicate changes were made
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.doseActionPostponed(_medication!.name, newTimeString),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _postpone15Minutes() async {
    if (_medication == null) return;

    // Calculate time 15 minutes from now
    final now = DateTime.now();
    final newDateTime = now.add(const Duration(minutes: 15));
    final newTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);

    // Format the new time
    final newTimeString = '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';

    // Schedule a one-time notification for this dose
    await NotificationService.instance.schedulePostponedDoseNotification(
      medication: _medication!,
      originalDoseTime: widget.doseTime,
      newTime: newTime,
    );

    if (!mounted) return;

    // Show confirmation and go back
    Navigator.pop(context, true); // Return true to indicate changes were made
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.doseActionPostponed15(_medication!.name, newTimeString),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.doseActionLoading),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_medication == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.doseActionError),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.doseActionMedicationNotFound),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.doseActionBack),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doseActionTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Medication header
            MedicationHeaderCard(
              medication: _medication!,
              doseTime: widget.doseTime,
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              l10n.doseActionWhatToDo,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Option 1: Register taken
            TakeDoseButton(onPressed: _registerTaken),
            const SizedBox(height: 16),
            // Option 2: Register skipped
            SkipDoseButton(onPressed: _registerSkipped),
            const SizedBox(height: 16),
            // Option 3: Postpone 15 minutes (quick action)
            Postpone15MinutesButton(onPressed: _postpone15Minutes),
            const SizedBox(height: 12),
            // Option 4: Postpone custom time
            PostponeCustomButton(onPressed: _postponeDose),
            const SizedBox(height: 24),
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.btnCancel),
            ),
          ],
        ),
      ),
    );
  }
}
