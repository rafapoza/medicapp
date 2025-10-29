import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../models/treatment_duration_type.dart';
import '../models/dose_history_entry.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'edit_medication_menu_screen.dart';
import 'medication_info_screen.dart';

class MedicineCabinetScreen extends StatefulWidget {
  final bool showAppBar;

  const MedicineCabinetScreen({super.key, this.showAppBar = true});

  @override
  State<MedicineCabinetScreen> createState() => _MedicineCabinetScreenState();
}

class _MedicineCabinetScreenState extends State<MedicineCabinetScreen> {
  List<Medication> _allMedications = [];
  List<Medication> _filteredMedications = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    final medications = await DatabaseHelper.instance.getAllMedications();

    if (!mounted) return;

    // Sort alphabetically by name
    medications.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _allMedications = medications;
      _filteredMedications = medications;
      _isLoading = false;
    });
  }

  void _filterMedications(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMedications = _allMedications;
      } else {
        _filteredMedications = _allMedications.where((medication) {
          return medication.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToAddMedication() async {
    final newMedication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationInfoScreen(
          existingMedications: _allMedications,
        ),
      ),
    );

    if (newMedication != null) {
      // Reload medications after adding a new one
      await _loadMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(l10n.medicineCabinetTitle),
            )
          : null,
      body: Column(
        children: [
          // Search bar
          if (_allMedications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.medicineCabinetSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _filterMedications('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: _filterMedications,
              ),
            ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _allMedications.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadMedications,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.medical_information_outlined,
                                        size: 80,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.medicineCabinetEmptyTitle,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.medicineCabinetEmptySubtitle,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.medicineCabinetPullToRefresh,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : _filteredMedications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.medicineCabinetNoResults,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.medicineCabinetNoResultsHint,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMedications,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredMedications.length,
                              itemBuilder: (context, index) {
                                final medication = _filteredMedications[index];
                                return _MedicationCard(
                                  medication: medication,
                                  onMedicationUpdated: _loadMedications,
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

class _MedicationCard extends StatefulWidget {
  final Medication medication;
  final VoidCallback onMedicationUpdated;

  const _MedicationCard({
    required this.medication,
    required this.onMedicationUpdated,
  });

  @override
  State<_MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<_MedicationCard> {
  void _showMedicationModal() {
    final l10n = AppLocalizations.of(context)!;
    final isAsNeeded = widget.medication.durationType == TreatmentDurationType.asNeeded;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with medication info
              Row(
                children: [
                  Icon(
                    widget.medication.type.icon,
                    size: 36,
                    color: widget.medication.type.getColor(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.medication.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.medication.type.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: widget.medication.type.getColor(context),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.medicineCabinetStock} ${widget.medication.stockDisplayText}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Action buttons
              if (widget.medication.isSuspended) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _resumeMedication();
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(l10n.medicineCabinetResumeMedication),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (isAsNeeded && !widget.medication.isSuspended) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _registerManualDose();
                    },
                    icon: const Icon(Icons.medication, size: 18),
                    label: Text(l10n.medicineCabinetRegisterDose),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _refillMedication();
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(l10n.medicineCabinetRefillMedication),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _editMedication();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l10n.medicineCabinetEditMedication),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteMedication();
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.medicineCabinetDeleteMedication),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(l10n.btnClose),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _refillMedication() async {
    final l10n = AppLocalizations.of(context)!;
    // Controller for the refill amount
    final refillController = TextEditingController(
      text: widget.medication.lastRefillAmount?.toString() ?? '',
    );

    final refillAmount = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.medicineCabinetRefillTitle(widget.medication.name)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.medicineCabinetCurrentStock} ${widget.medication.stockDisplayText}',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                // Quantity label
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.add_box, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.medicineCabinetAddQuantityLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(dialogContext).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.medication.type.stockUnit})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity field
                TextField(
                  controller: refillController,
                  decoration: InputDecoration(
                    hintText: widget.medication.lastRefillAmount != null
                        ? '${l10n.medicineCabinetExample} ${widget.medication.lastRefillAmount}'
                        : '${l10n.medicineCabinetExample} 30',
                    helperText: widget.medication.lastRefillAmount != null
                        ? '${l10n.medicineCabinetLastRefill} ${widget.medication.lastRefillAmount} ${widget.medication.type.stockUnit}'
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(refillController.text.trim());
                if (amount != null && amount > 0) {
                  Navigator.pop(dialogContext, amount);
                }
              },
              child: Text(l10n.medicineCabinetRefillButton),
            ),
          ],
        );
      },
    );

    // Dispose controller after dialog closes
    Future.delayed(const Duration(milliseconds: 100), () {
      refillController.dispose();
    });

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
    final doseController = TextEditingController(text: '1.0');

    final doseQuantity = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.medicineCabinetRegisterDoseTitle(widget.medication.name)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.medicineCabinetAvailableStock} ${widget.medication.stockDisplayText}',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: doseController,
                  decoration: InputDecoration(
                    labelText: l10n.medicineCabinetDoseTaken,
                    hintText: '${l10n.medicineCabinetExample} 1',
                    suffixText: widget.medication.type.stockUnit,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: () {
                final quantity = double.tryParse(doseController.text.trim());
                if (quantity != null && quantity > 0) {
                  Navigator.pop(dialogContext, quantity);
                }
              },
              child: Text(l10n.medicineCabinetRegisterButton),
            ),
          ],
        );
      },
    );

    // Dispose controller after dialog closes
    Future.delayed(const Duration(milliseconds: 100), () {
      doseController.dispose();
    });

    if (doseQuantity != null && doseQuantity > 0) {
      // Check if there's enough stock for this dose
      if (widget.medication.stockQuantity < doseQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.medicineCabinetInsufficientStock(
                doseQuantity.toString(),
                widget.medication.type.stockUnit,
                widget.medication.stockDisplayText,
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // For "as needed" medications, calculate lastDailyConsumption
      // Query dose history for today to get total consumption
      double? lastDailyConsumption = widget.medication.lastDailyConsumption;

      if (widget.medication.durationType == TreatmentDurationType.asNeeded) {
        // Query history for today
        final now = DateTime.now();
        final todayHistory = await DatabaseHelper.instance.getDoseHistoryForDateRange(
          medicationId: widget.medication.id,
          startDate: DateTime(now.year, now.month, now.day),
          endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );

        // Calculate total consumption for today (including the dose we're about to register)
        final existingConsumption = todayHistory
            .where((entry) => entry.status == DoseStatus.taken)
            .fold(0.0, (sum, entry) => sum + entry.quantity);
        lastDailyConsumption = existingConsumption + doseQuantity;
      }

      // Decrease stock and update medication
      final updatedMedication = Medication(
        id: widget.medication.id,
        name: widget.medication.name,
        type: widget.medication.type,
        dosageIntervalHours: widget.medication.dosageIntervalHours,
        durationType: widget.medication.durationType,
        doseSchedule: widget.medication.doseSchedule,
        stockQuantity: widget.medication.stockQuantity - doseQuantity,
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
        isSuspended: widget.medication.isSuspended,
        lastDailyConsumption: lastDailyConsumption,
      );

      // Update in database
      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Create history entry with current time (both scheduled and actual)
      final now = DateTime.now();
      final historyEntry = DoseHistoryEntry(
        id: '${widget.medication.id}_${now.millisecondsSinceEpoch}',
        medicationId: widget.medication.id,
        medicationName: widget.medication.name,
        medicationType: widget.medication.type,
        scheduledDateTime: now, // For manual doses, scheduled time = actual time
        registeredDateTime: now,
        status: DoseStatus.taken,
        quantity: doseQuantity,
      );

      await DatabaseHelper.instance.insertDoseHistory(historyEntry);

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
