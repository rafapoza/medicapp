import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../models/treatment_duration_type.dart';
import '../models/dose_history_entry.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../services/preferences_service.dart';
import '../utils/medication_sorter.dart';
import 'medication_info_screen.dart';
import 'edit_medication_menu_screen.dart';
import 'medication_list/widgets/medication_card.dart';
import 'medication_list/widgets/battery_optimization_banner.dart';
import 'medication_list/widgets/empty_medications_view.dart';
import 'medication_list/widgets/today_doses_section.dart';
import 'medication_list/widgets/debug_menu.dart';
import 'medication_list/dialogs/medication_options_sheet.dart';
import 'medication_list/dialogs/dose_selection_dialog.dart';
import 'medication_list/dialogs/manual_dose_input_dialog.dart';
import 'medication_list/dialogs/refill_input_dialog.dart';
import 'medication_list/dialogs/edit_today_dose_dialog.dart';
import 'medication_list/dialogs/notification_permission_dialog.dart';
import 'medication_list/dialogs/debug_info_dialog.dart';
import 'medication_list/services/dose_calculation_service.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> with WidgetsBindingObserver {
  final List<Medication> _medications = [];
  bool _isLoading = true;
  bool _debugMenuVisible = false;
  int _titleTapCount = 0;
  DateTime? _lastTapTime;
  bool _batteryBannerDismissed = false;
  // Cache for "as needed" medication doses taken today
  final Map<String, Map<String, dynamic>> _asNeededDosesInfo = {};
  // Cache for actual dose times (scheduled time -> actual time)
  final Map<String, Map<String, DateTime>> _actualDoseTimes = {};
  // Cache for fasting periods
  final Map<String, Map<String, dynamic>> _fastingPeriods = {};
  // User preference for showing actual time
  bool _showActualTime = false;
  // User preference for showing fasting countdown
  bool _showFastingCountdown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    _loadBatteryBannerPreference();
    _loadShowActualTimePreference();
    _loadShowFastingCountdownPreference();
    _loadMedications();
    _checkNotificationPermissions();
  }

  /// Load show actual time preference
  Future<void> _loadShowActualTimePreference() async {
    final showActualTime = await PreferencesService.getShowActualTimeForTakenDoses();
    if (mounted) {
      setState(() {
        _showActualTime = showActualTime;
      });
    }
  }

  /// Load show fasting countdown preference
  Future<void> _loadShowFastingCountdownPreference() async {
    final showFastingCountdown = await PreferencesService.getShowFastingCountdown();
    if (mounted) {
      setState(() {
        _showFastingCountdown = showFastingCountdown;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload medications when app resumes (e.g., after handling a notification)
    if (state == AppLifecycleState.resumed) {
      _loadMedications();
    }
  }

  /// Load battery banner dismissal preference
  Future<void> _loadBatteryBannerPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _batteryBannerDismissed = prefs.getBool('battery_banner_dismissed') ?? false;
        });
      }
    } catch (e) {
      // SharedPreferences not available (e.g., in tests)
      print('Could not load battery banner preference: $e');
    }
  }

  /// Dismiss battery banner and save preference
  Future<void> _dismissBatteryBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('battery_banner_dismissed', true);
      if (mounted) {
        setState(() {
          _batteryBannerDismissed = true;
        });
      }
    } catch (e) {
      // SharedPreferences not available (e.g., in tests)
      print('Could not save battery banner preference: $e');
      // Still hide the banner in the current session
      if (mounted) {
        setState(() {
          _batteryBannerDismissed = true;
        });
      }
    }
  }

  /// Check notification permissions and show warning if needed
  Future<void> _checkNotificationPermissions() async {
    await NotificationPermissionDialog.checkAndShowIfNeeded(
      context: context,
      hasMedications: _medications.isNotEmpty,
    );
  }

  void _onTitleTap() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    // Reset counter if more than 2 seconds have passed since last tap
    if (_lastTapTime == null || now.difference(_lastTapTime!).inSeconds > 2) {
      _titleTapCount = 1;
    } else {
      _titleTapCount++;
    }

    _lastTapTime = now;

    // Toggle debug menu visibility after 5 taps
    if (_titleTapCount >= 5) {
      setState(() {
        _debugMenuVisible = !_debugMenuVisible;
        _titleTapCount = 0;
        _lastTapTime = null;
      });

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_debugMenuVisible
              ? l10n.debugMenuActivated
              : l10n.debugMenuDeactivated),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadMedications() async {
    print('Loading medications from database...');
    final allMedications = await DatabaseHelper.instance.getAllMedications();
    print('Loaded ${allMedications.length} medications');

    // Get medication IDs that have doses registered today
    final medicationIdsWithDosesToday = await DatabaseHelper.instance.getMedicationIdsWithDosesToday();
    print('Found ${medicationIdsWithDosesToday.length} medications with doses taken today');

    // Filter medications for display:
    // - Exclude suspended medications (they only appear in Botiquín)
    // - Include programmed medications (not "as needed")
    // - Include "as needed" medications that have been taken today
    final medications = allMedications.where((m) {
      // Always exclude suspended medications
      if (m.isSuspended) return false;

      // Include if it's a programmed medication (not "as needed")
      if (m.durationType != TreatmentDurationType.asNeeded) return true;

      // Include "as needed" medications that have doses registered today
      return medicationIdsWithDosesToday.contains(m.id);
    }).toList();

    print('Filtered to ${medications.length} medications (excluded ${allMedications.length - medications.length} suspended or "as needed" without doses today)');

    for (var med in medications) {
      print('- ${med.name}: ${med.doseTimes.length} dose times');
    }

    // Load "as needed" doses information for medications that have been taken today
    _asNeededDosesInfo.clear();
    for (final med in medications) {
      if (med.durationType == TreatmentDurationType.asNeeded) {
        final dosesInfo = await DoseCalculationService.getAsNeededDosesInfo(med);
        if (dosesInfo != null) {
          _asNeededDosesInfo[med.id] = dosesInfo;
        }
      }
    }

    // Load actual dose times if user preference is enabled
    _actualDoseTimes.clear();
    if (_showActualTime) {
      for (final med in medications) {
        if (med.isTakenDosesDateToday && med.takenDosesToday.isNotEmpty) {
          final actualTimes = await DoseCalculationService.getActualDoseTimes(med);
          if (actualTimes.isNotEmpty) {
            _actualDoseTimes[med.id] = actualTimes;
          }
        }
      }
    }

    // Load fasting periods if user preference is enabled
    _fastingPeriods.clear();
    if (_showFastingCountdown) {
      for (final med in medications) {
        if (med.requiresFasting) {
          final fastingInfo = await DoseCalculationService.getActiveFastingPeriod(med);
          if (fastingInfo != null) {
            _fastingPeriods[med.id] = fastingInfo;
          }
        }
      }
    }

    // Sort medications by next dose proximity
    MedicationSorter.sortByNextDose(medications);

    if (!mounted) return; // Check if widget is still mounted

    // Update UI immediately
    setState(() {
      _medications.clear();
      _medications.addAll(medications);
      _isLoading = false;
    });

    print('UI updated with ${_medications.length} medications');

    // Schedule notifications in background without blocking UI
    _scheduleNotificationsInBackground(medications);
  }

  void _scheduleNotificationsInBackground(List<Medication> medications) {
    // Run notification scheduling in background without awaiting
    Future.microtask(() async {
      for (final medication in medications) {
        try {
          await NotificationService.instance.scheduleMedicationNotifications(medication);
        } catch (e) {
          // Log error but don't block the UI
          print('Error scheduling notifications for ${medication.name}: $e');
        }
      }
    });
  }

  void _navigateToAddMedication() async {
    final newMedication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationInfoScreen(
          existingMedications: _medications,
        ),
      ),
    );

    print('Returned from add screen: $newMedication');

    if (newMedication != null) {
      print('Adding new medication: ${newMedication.name}');
      print('Dose times: ${newMedication.doseTimes}');

      // Reload medications from database
      final reloadedMeds = await DatabaseHelper.instance.getAllMedications();
      print('Reloaded ${reloadedMeds.length} medications from DB after insert');

      // Sort by next dose proximity
      MedicationSorter.sortByNextDose(reloadedMeds);

      // Update UI immediately
      if (mounted) {
        setState(() {
          _medications.clear();
          _medications.addAll(reloadedMeds);
        });
      }
    } else {
      print('newMedication is null - user cancelled or error occurred');
    }
  }

  void _navigateToEditMedication(Medication medication) async {
    // Close the modal first
    Navigator.pop(context);

    // Then navigate to edit screen
    final updatedMedication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationMenuScreen(
          medication: medication,
          existingMedications: _medications,
        ),
      ),
    );

    if (updatedMedication != null) {
      print('Updating medication: ${updatedMedication.name}');
      print('Dose times: ${updatedMedication.doseTimes}');

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reload medications from database to ensure we have fresh data
      final reloadedMeds = await DatabaseHelper.instance.getAllMedications();
      print('Reloaded ${reloadedMeds.length} medications from DB');

      // Sort by next dose proximity
      MedicationSorter.sortByNextDose(reloadedMeds);

      // Update UI immediately
      if (mounted) {
        setState(() {
          _medications.clear();
          _medications.addAll(reloadedMeds);
        });

        // Show confirmation message
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationUpdatedShort(updatedMedication.name)),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Reschedule notifications in background (non-blocking)
      Future.microtask(() async {
        try {
          await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);
          print('Notifications rescheduled for ${updatedMedication.name}');
        } catch (e) {
          print('Error rescheduling notifications for ${updatedMedication.name}: $e');
        }
      });
    }
  }


  void _registerDose(Medication medication) async {
    final l10n = AppLocalizations.of(context)!;
    print('_registerDose called');
    print('stockQuantity: ${medication.stockQuantity}');

    // Check if medication has dose times configured (BEFORE closing modal)
    if (medication.doseTimes.isEmpty) {
      print('Dose times empty');
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.noScheduledTimes),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if there's any stock available (BEFORE closing modal)
    if (medication.stockQuantity <= 0) {
      print('No stock, showing SnackBar');
      final messenger = ScaffoldMessenger.of(context);
      print('Got messenger, popping navigator');
      Navigator.pop(context);
      print('Showing SnackBar');
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.medicineCabinetNoStockAvailable),
          duration: const Duration(seconds: 2),
        ),
      );
      print('SnackBar shown');
      return;
    }

    print('Continuing with dose registration');

    // Close the modal after validation passes
    Navigator.pop(context);

    // ALWAYS get the fresh medication from database to ensure we have the latest taken doses
    final freshMedication = await DatabaseHelper.instance.getMedication(medication.id);

    // If medication was deleted, show error and return
    if (freshMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.doseActionMedicationNotFound),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get available doses (doses that haven't been taken today)
    final availableDoses = freshMedication.getAvailableDosesToday();

    // Check if there are available doses
    if (availableDoses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allDosesTakenToday),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    String? selectedDoseTime;

    // If only one dose is available, register it directly
    if (availableDoses.length == 1) {
      selectedDoseTime = availableDoses.first;
    } else {
      // If multiple doses are available, show dialog to select which one was taken
      selectedDoseTime = await DoseSelectionDialog.show(
        context,
        medicationName: freshMedication.name,
        availableDoses: availableDoses,
      );
    }

    if (selectedDoseTime != null) {
      // Get the dose quantity for this specific time
      final doseQuantity = freshMedication.getDoseQuantity(selectedDoseTime);

      // Check if there's enough stock for this dose
      if (freshMedication.stockQuantity < doseQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.insufficientStockForThisDose(
                doseQuantity.toString(),
                freshMedication.type.stockUnit,
                freshMedication.stockDisplayText,
              )
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Get today's date
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Update taken doses for today
      List<String> updatedTakenDoses;
      List<String> updatedSkippedDoses;

      if (freshMedication.takenDosesDate == todayString) {
        // Same day, add to existing list
        updatedTakenDoses = List.from(freshMedication.takenDosesToday);
        updatedTakenDoses.add(selectedDoseTime);
        updatedSkippedDoses = List.from(freshMedication.skippedDosesToday);
      } else {
        // New day, reset lists
        updatedTakenDoses = [selectedDoseTime];
        updatedSkippedDoses = [];
      }

      // Decrease stock by the dose quantity and update taken doses
      final updatedMedication = Medication(
        id: freshMedication.id,
        name: freshMedication.name,
        type: freshMedication.type,
        dosageIntervalHours: freshMedication.dosageIntervalHours,
        durationType: freshMedication.durationType,
        doseSchedule: freshMedication.doseSchedule,
        stockQuantity: freshMedication.stockQuantity - doseQuantity,
        takenDosesToday: updatedTakenDoses,
        skippedDosesToday: updatedSkippedDoses,
        takenDosesDate: todayString,
        lastRefillAmount: freshMedication.lastRefillAmount,
        lowStockThresholdDays: freshMedication.lowStockThresholdDays,
        selectedDates: freshMedication.selectedDates,
        weeklyDays: freshMedication.weeklyDays,
        dayInterval: freshMedication.dayInterval,
        startDate: freshMedication.startDate,
        endDate: freshMedication.endDate,
        requiresFasting: freshMedication.requiresFasting,
        fastingType: freshMedication.fastingType,
        fastingDurationMinutes: freshMedication.fastingDurationMinutes,
        notifyFasting: freshMedication.notifyFasting,
        isSuspended: freshMedication.isSuspended,
        lastDailyConsumption: freshMedication.lastDailyConsumption,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Create history entry
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(selectedDoseTime.split(':')[0]),
        int.parse(selectedDoseTime.split(':')[1]),
      );

      final historyEntry = DoseHistoryEntry(
        id: '${freshMedication.id}_${now.millisecondsSinceEpoch}',
        medicationId: freshMedication.id,
        medicationName: freshMedication.name,
        medicationType: freshMedication.type,
        scheduledDateTime: scheduledDateTime,
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: doseQuantity,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Cancel today's notification for this specific dose to prevent it from firing
      await NotificationService.instance.cancelTodaysDoseNotification(
        medication: updatedMedication,
        doseTime: selectedDoseTime,
      );

      // Reschedule medication notifications to restore future notifications
      // This is needed because cancelTodaysDoseNotification may cancel recurring notifications
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      // Cancel today's fasting notification if it's a "before" fasting type
      await NotificationService.instance.cancelTodaysFastingNotification(
        medication: updatedMedication,
        doseTime: selectedDoseTime,
      );

      // Schedule dynamic fasting notification if medication requires fasting after dose
      if (updatedMedication.requiresFasting &&
          updatedMedication.fastingType == 'after' &&
          updatedMedication.notifyFasting) {
        await NotificationService.instance.scheduleDynamicFastingNotification(
          medication: updatedMedication,
          actualDoseTime: DateTime.now(),
        );
        print('Dynamic fasting notification scheduled for ${updatedMedication.name}');
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      // Show confirmation
      final remainingDoses = updatedMedication.getAvailableDosesToday();
      final confirmationMessage = remainingDoses.isEmpty
          ? '${l10n.doseRegisteredAtTime(freshMedication.name, selectedDoseTime, updatedMedication.stockDisplayText)}\n${l10n.allDosesCompletedToday}'
          : '${l10n.doseRegisteredAtTime(freshMedication.name, selectedDoseTime, updatedMedication.stockDisplayText)}\n${l10n.remainingDosesToday(remainingDoses.length)}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmationMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _registerManualDose(Medication medication) async {
    final l10n = AppLocalizations.of(context)!;
    // Close the modal first
    Navigator.pop(context);

    // Check if there's any stock available
    if (medication.stockQuantity <= 0) {
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
      medication: medication,
    );

    if (doseQuantity != null && doseQuantity > 0) {
      // Check if there's enough stock for this dose
      if (medication.stockQuantity < doseQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.insufficientStockForThisDose(
                doseQuantity.toString(),
                medication.type.stockUnit,
                medication.stockDisplayText,
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Decrease stock
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity - doseQuantity,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Create history entry with current time
      final now = DateTime.now();
      final historyEntry = DoseHistoryEntry(
        id: '${medication.id}_${now.millisecondsSinceEpoch}',
        medicationId: medication.id,
        medicationName: medication.name,
        medicationType: medication.type,
        scheduledDateTime: now, // For manual doses, scheduled time = actual time
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: doseQuantity,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

      // Cancel the next pending notification for this medication today
      // This prevents notifications from firing after a manual dose registration
      if (medication.doseTimes.isNotEmpty) {
        final now = DateTime.now();
        final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

        // Find the next scheduled dose time that hasn't been taken yet
        String? nextDoseTime;
        for (final doseTime in medication.doseTimes) {
          final parts = doseTime.split(':');
          final doseTimeOfDay = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );

          // Check if this dose time is in the future and hasn't been taken
          final doseMinutes = doseTimeOfDay.hour * 60 + doseTimeOfDay.minute;
          final currentMinutes = currentTime.hour * 60 + currentTime.minute;

          if (doseMinutes > currentMinutes &&
              !updatedMedication.takenDosesToday.contains(doseTime)) {
            nextDoseTime = doseTime;
            break; // Found the next pending dose
          }
        }

        // If we found a next dose time, cancel its notification
        if (nextDoseTime != null) {
          await NotificationService.instance.cancelTodaysDoseNotification(
            medication: updatedMedication,
            doseTime: nextDoseTime,
          );
          print('Cancelled notification for $nextDoseTime after manual dose registration');

          // Reschedule medication notifications to restore future notifications
          // This is needed because cancelTodaysDoseNotification may cancel recurring notifications
          await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);
        }
      }

      // Schedule dynamic fasting notification if medication requires fasting after dose
      if (updatedMedication.requiresFasting &&
          updatedMedication.fastingType == 'after' &&
          updatedMedication.notifyFasting) {
        await NotificationService.instance.scheduleDynamicFastingNotification(
          medication: updatedMedication,
          actualDoseTime: now,
        );
        print('Dynamic fasting notification scheduled for ${updatedMedication.name}');
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      // Show confirmation
      final confirmationMessage = l10n.manualDoseRegistered(
        medication.name,
        doseQuantity.toString(),
        medication.type.stockUnit,
        updatedMedication.stockDisplayText,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmationMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleSuspendMedication(Medication medication) async {
    // Close the modal first
    Navigator.pop(context);

    // Toggle the suspended status
    final updatedMedication = Medication(
      id: medication.id,
      name: medication.name,
      type: medication.type,
      dosageIntervalHours: medication.dosageIntervalHours,
      durationType: medication.durationType,
      doseSchedule: medication.doseSchedule,
      stockQuantity: medication.stockQuantity,
      takenDosesToday: medication.takenDosesToday,
      skippedDosesToday: medication.skippedDosesToday,
      takenDosesDate: medication.takenDosesDate,
      lastRefillAmount: medication.lastRefillAmount,
      lowStockThresholdDays: medication.lowStockThresholdDays,
      selectedDates: medication.selectedDates,
      weeklyDays: medication.weeklyDays,
      dayInterval: medication.dayInterval,
      startDate: medication.startDate,
      endDate: medication.endDate,
      requiresFasting: medication.requiresFasting,
      fastingType: medication.fastingType,
      fastingDurationMinutes: medication.fastingDurationMinutes,
      notifyFasting: medication.notifyFasting,
      isSuspended: !medication.isSuspended, // Toggle the suspension status
    );

    // Update in database
    await DatabaseHelper.instance.updateMedication(updatedMedication);

    // If suspending, cancel all notifications
    if (updatedMedication.isSuspended) {
      await NotificationService.instance.cancelMedicationNotifications(
        medication.id,
        medication: updatedMedication,
      );
    } else {
      // If reactivating, reschedule notifications
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);
    }

    // Reload medications
    await _loadMedications();

    if (!mounted) return;

    // Show confirmation
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedMedication.isSuspended
              ? l10n.medicationSuspended(medication.name)
              : l10n.medicationReactivated(medication.name),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _refillMedication(Medication medication) async {
    final l10n = AppLocalizations.of(context)!;
    // Close the modal first
    Navigator.pop(context);

    // Controller for the refill amount
    final refillAmount = await RefillInputDialog.show(
      context,
      medication: medication,
    );

    if (refillAmount != null && refillAmount > 0) {
      // Update medication with new stock and save refill amount
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: medication.stockQuantity + refillAmount,
        takenDosesToday: medication.takenDosesToday,
        skippedDosesToday: medication.skippedDosesToday,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: refillAmount, // Save for future suggestions
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        dayInterval: medication.dayInterval,
        startDate: medication.startDate,
        endDate: medication.endDate,
        requiresFasting: medication.requiresFasting,
        fastingType: medication.fastingType,
        fastingDurationMinutes: medication.fastingDurationMinutes,
        notifyFasting: medication.notifyFasting,
        isSuspended: medication.isSuspended,
        lastDailyConsumption: medication.lastDailyConsumption,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.stockRefilled(
              medication.name,
              refillAmount.toString(),
              medication.type.stockUnit,
              updatedMedication.stockDisplayText,
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDeleteModal(Medication medication) {
    MedicationOptionsSheet.show(
      context,
      medication: medication,
      onRegisterDose: () => _registerDose(medication),
      onRegisterManualDose: () => _registerManualDose(medication),
      onRefill: () => _refillMedication(medication),
      onToggleSuspend: () => _toggleSuspendMedication(medication),
      onEdit: () => _navigateToEditMedication(medication),
      onDelete: () async {
        final l10n = AppLocalizations.of(context)!;
        // Delete from database
        await DatabaseHelper.instance.deleteMedication(medication.id);

        // Cancel notifications for the deleted medication
        await NotificationService.instance.cancelMedicationNotifications(medication.id, medication: medication);

        setState(() {
          _medications.remove(medication);
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationDeletedShort(medication.name)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showDebugInfo() async {
    await DebugInfoDialog.show(
      context: context,
      medications: _medications,
    );
  }

  void _testNotification() async {
    await NotificationService.instance.showTestNotification();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.testNotificationSent),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _testScheduledNotification() async {
    await NotificationService.instance.scheduleTestNotification();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.scheduledNotificationInOneMin),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _rescheduleAllNotifications() async {
    print('Reprogramando todas las notificaciones...');

    for (final medication in _medications) {
      if (medication.doseTimes.isNotEmpty) {
        await NotificationService.instance.scheduleMedicationNotifications(medication);
      }
    }

    if (!mounted) return;

    final pending = await NotificationService.instance.getPendingNotifications();

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.notificationsRescheduled(pending.length)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTodayDosesSection(Medication medication) {
    return TodayDosesSection(
      medication: medication,
      onDoseTap: (doseTime, isTaken) => _showEditTodayDoseDialog(medication, doseTime, isTaken),
      actualDoseTimes: _actualDoseTimes[medication.id],
      showActualTime: _showActualTime,
    );
  }

  Future<void> _showEditTodayDoseDialog(Medication medication, String doseTime, bool isTaken) async {
    final result = await EditTodayDoseDialog.show(
      context,
      medicationName: medication.name,
      doseTime: doseTime,
      isTaken: isTaken,
    );

    if (result == 'delete') {
      await _deleteTodayDose(medication, doseTime, isTaken);
    } else if (result == 'toggle') {
      await _toggleTodayDoseStatus(medication, doseTime, isTaken);
    }
  }

  Future<void> _deleteTodayDose(Medication medication, String doseTime, bool wasTaken) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Remove from taken or skipped doses
      List<String> takenDoses = List.from(medication.takenDosesToday);
      List<String> skippedDoses = List.from(medication.skippedDosesToday);

      if (wasTaken) {
        takenDoses.remove(doseTime);
      } else {
        skippedDoses.remove(doseTime);
      }

      // Restore stock if it was taken
      double newStock = medication.stockQuantity;
      if (wasTaken) {
        final doseQuantity = medication.getDoseQuantity(doseTime);
        newStock += doseQuantity;
      }

      // Update medication
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: newStock,
        takenDosesToday: takenDoses,
        skippedDosesToday: skippedDoses,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Delete from history
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(doseTime.split(':')[0]),
        int.parse(doseTime.split(':')[1]),
      );

      // Find and delete the history entry
      final historyEntries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      for (final entry in historyEntries) {
        if (entry.scheduledDateTime.year == scheduledDateTime.year &&
            entry.scheduledDateTime.month == scheduledDateTime.month &&
            entry.scheduledDateTime.day == scheduledDateTime.day &&
            entry.scheduledDateTime.hour == scheduledDateTime.hour &&
            entry.scheduledDateTime.minute == scheduledDateTime.minute) {
          await DatabaseHelper.instance.deleteDoseHistory(entry.id);
          break;
        }
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.doseDeletedAt(doseTime)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorDeleting(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleTodayDoseStatus(Medication medication, String doseTime, bool wasTaken) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Move between taken and skipped
      List<String> takenDoses = List.from(medication.takenDosesToday);
      List<String> skippedDoses = List.from(medication.skippedDosesToday);

      double newStock = medication.stockQuantity;
      final doseQuantity = medication.getDoseQuantity(doseTime);

      if (wasTaken) {
        // Change from taken to skipped
        takenDoses.remove(doseTime);
        skippedDoses.add(doseTime);
        // Restore stock
        newStock += doseQuantity;
      } else {
        // Change from skipped to taken
        skippedDoses.remove(doseTime);
        takenDoses.add(doseTime);
        // Remove stock
        if (newStock < doseQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.insufficientStockForDose),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        newStock -= doseQuantity;
      }

      // Update medication
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        type: medication.type,
        dosageIntervalHours: medication.dosageIntervalHours,
        durationType: medication.durationType,
        doseSchedule: medication.doseSchedule,
        stockQuantity: newStock,
        takenDosesToday: takenDoses,
        skippedDosesToday: skippedDoses,
        takenDosesDate: medication.takenDosesDate,
        lastRefillAmount: medication.lastRefillAmount,
        lowStockThresholdDays: medication.lowStockThresholdDays,
        selectedDates: medication.selectedDates,
        weeklyDays: medication.weeklyDays,
        startDate: medication.startDate,
        endDate: medication.endDate,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Update history entry
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(doseTime.split(':')[0]),
        int.parse(doseTime.split(':')[1]),
      );

      // Find and update the history entry
      final historyEntries = await DatabaseHelper.instance.getDoseHistoryForMedication(medication.id);
      for (final entry in historyEntries) {
        if (entry.scheduledDateTime.year == scheduledDateTime.year &&
            entry.scheduledDateTime.month == scheduledDateTime.month &&
            entry.scheduledDateTime.day == scheduledDateTime.day &&
            entry.scheduledDateTime.hour == scheduledDateTime.hour &&
            entry.scheduledDateTime.minute == scheduledDateTime.minute) {
          final updatedEntry = entry.copyWith(
            status: wasTaken ? DoseStatus.skipped : DoseStatus.taken,
            registeredDateTime: DateTime.now(),
          );
          await DatabaseHelper.instance.insertDoseHistory(updatedEntry);
          break;
        }
      }

      // Reload medications
      await _loadMedications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.doseMarkedAs(doseTime, wasTaken ? l10n.skippedStatus : l10n.takenStatus)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorChangingStatus(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _onTitleTap,
          child: Text(l10n.mainScreenTitle),
        ),
        actions: _debugMenuVisible
            ? [
                DebugMenu(
                  onTestNotification: _testNotification,
                  onTestScheduled: _testScheduledNotification,
                  onReschedule: _rescheduleAllNotifications,
                  onShowDebugInfo: _showDebugInfo,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _medications.isEmpty
          ? EmptyMedicationsView(onRefresh: _loadMedications)
          : Column(
              children: [
                // Battery optimization info (only show on Android and if not dismissed)
                if (Platform.isAndroid && !_batteryBannerDismissed)
                  BatteryOptimizationBanner(onDismiss: _dismissBatteryBanner),
                // Medications list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadMedications,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final medication = _medications[index];
                        final nextDoseInfo = DoseCalculationService.getNextDoseInfo(medication);
                        final nextDoseText = nextDoseInfo != null ? DoseCalculationService.formatNextDose(nextDoseInfo, context) : null;
                        final asNeededDoseInfo = _asNeededDosesInfo.containsKey(medication.id) ? _asNeededDosesInfo[medication.id] : null;
                        final fastingPeriod = _fastingPeriods.containsKey(medication.id) ? _fastingPeriods[medication.id] : null;
                        final todayDosesWidget = (medication.isTakenDosesDateToday &&
                            (medication.takenDosesToday.isNotEmpty || medication.skippedDosesToday.isNotEmpty))
                            ? _buildTodayDosesSection(medication)
                            : null;

                        return MedicationCard(
                          medication: medication,
                          nextDoseInfo: nextDoseInfo,
                          nextDoseText: nextDoseText,
                          asNeededDoseInfo: asNeededDoseInfo,
                          fastingPeriod: fastingPeriod,
                          todayDosesWidget: todayDosesWidget,
                          onTap: () => _showDeleteModal(medication),
                        );
                      },
                  ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMedication,
        child: const Icon(Icons.add),
      ),
    );
  }
}
