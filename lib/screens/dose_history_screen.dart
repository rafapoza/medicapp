import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/dose_history_entry.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';

class DoseHistoryScreen extends StatefulWidget {
  const DoseHistoryScreen({super.key});

  @override
  State<DoseHistoryScreen> createState() => _DoseHistoryScreenState();
}

class _DoseHistoryScreenState extends State<DoseHistoryScreen> {
  List<DoseHistoryEntry> _historyEntries = [];
  List<Medication> _medications = [];
  bool _isLoading = true;
  bool _hasChanges = false; // Track if any changes were made

  // Filter state
  String? _selectedMedicationId;
  DateTime? _startDate;
  DateTime? _endDate;

  // Statistics
  Map<String, dynamic> _statistics = {
    'total': 0,
    'taken': 0,
    'skipped': 0,
    'adherence': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load medications for filter dropdown
    final medications = await DatabaseHelper.instance.getAllMedications();

    // Load history entries
    List<DoseHistoryEntry> entries;
    if (_startDate != null && _endDate != null) {
      entries = await DatabaseHelper.instance.getDoseHistoryForDateRange(
        startDate: _startDate!,
        endDate: _endDate!,
        medicationId: _selectedMedicationId,
      );
    } else if (_selectedMedicationId != null) {
      entries = await DatabaseHelper.instance.getDoseHistoryForMedication(_selectedMedicationId!);
    } else {
      entries = await DatabaseHelper.instance.getAllDoseHistory();
    }

    // Load statistics
    final stats = await DatabaseHelper.instance.getDoseStatistics(
      medicationId: _selectedMedicationId,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (mounted) {
      setState(() {
        _medications = medications;
        _historyEntries = entries;
        _statistics = stats;
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.doseHistoryFilterTitle),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medication filter
                  Text(l10n.doseHistoryMedicationLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _selectedMedicationId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.doseHistoryAllMedications),
                      ),
                      ..._medications.map((med) => DropdownMenuItem<String?>(
                            value: med.id,
                            child: Text(med.name),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedMedicationId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date range filter
                  Text(l10n.doseHistoryDateRangeLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _startDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : l10n.dateFromLabel,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _endDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : l10n.dateToLabel,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_startDate != null || _endDate != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: Text(l10n.doseHistoryClearDates),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            child: Text(l10n.doseHistoryApply),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedMedicationId = null;
      _startDate = null;
      _endDate = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasFilters = _selectedMedicationId != null || _startDate != null || _endDate != null;

    return Scaffold(
      appBar: AppBar(
        // Only show back button if there's a previous route in the navigation stack
        // When accessed via BottomNavigationBar, there's no previous route
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop(_hasChanges);
                },
              )
            : null,
        title: Text(l10n.doseHistoryTitle),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              hasFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: hasFilters ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.statisticsTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.medication,
                                label: l10n.doseHistoryTotal,
                                value: '${_statistics['total']}',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle,
                                label: l10n.doseHistoryTaken,
                                value: '${_statistics['taken']}',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.cancel,
                                label: l10n.doseHistorySkipped,
                                value: '${_statistics['skipped']}',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Adherence bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.adherenceLabel,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${_statistics['adherence'].toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getAdherenceColor(_statistics['adherence']),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _statistics['adherence'] / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getAdherenceColor(_statistics['adherence']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Active filters chip
                if (hasFilters)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getFilterDescription(l10n),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear, size: 16),
                          label: Text(l10n.doseHistoryClear),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ),

                // History list
                Expanded(
                  child: _historyEntries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                hasFilters
                                    ? l10n.emptyDosesWithFilters
                                    : l10n.emptyDoses,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _historyEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _historyEntries[index];
                            return _DoseHistoryCard(
                              entry: entry,
                              onTap: () => _showEditEntryDialog(entry),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showEditEntryDialog(DoseHistoryEntry entry) {
    final l10n = AppLocalizations.of(context)!;

    // Check if entry is from today (allows deletion)
    final now = DateTime.now();
    final isToday = entry.scheduledDateTime.year == now.year &&
        entry.scheduledDateTime.month == now.month &&
        entry.scheduledDateTime.day == now.day;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.doseHistoryEditEntry(entry.medicationName)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.dateLabel} ${entry.scheduledDateFormatted}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.scheduledTimeLabel} ${entry.scheduledTimeFormatted}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.currentStatusLabel} ${entry.status.displayName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.changeStatusToQuestion,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actionsOverflowButtonSpacing: 8,
        actions: [
          // Delete button (only for today's entries)
          if (isToday)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _confirmDeleteEntry(entry);
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.btnDelete),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          // Spacer - push other buttons to the right
          if (isToday)
            const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnCancel),
          ),
          if (entry.status == DoseStatus.taken)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _changeEntryStatus(entry, DoseStatus.skipped);
              },
              icon: const Icon(Icons.cancel),
              label: Text(l10n.doseHistoryMarkAsSkipped),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            )
          else
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _changeEntryStatus(entry, DoseStatus.taken);
              },
              icon: const Icon(Icons.check_circle),
              label: Text(l10n.doseHistoryMarkAsTaken),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _changeEntryStatus(DoseHistoryEntry entry, DoseStatus newStatus) async {
    final l10n = AppLocalizations.of(context)!;

    // Create updated entry
    final updatedEntry = entry.copyWith(
      status: newStatus,
      registeredDateTime: DateTime.now(), // Update registered time
    );

    // Update in database
    await DatabaseHelper.instance.insertDoseHistory(updatedEntry);

    // Reload data
    await _loadData();

    if (!mounted) return;

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.statusUpdatedTo(newStatus.displayName),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteEntry(DoseHistoryEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.doseHistoryConfirmDelete),
        content: Text(
          l10n.doseHistoryConfirmDeleteMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHistoryEntry(entry);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistoryEntry(DoseHistoryEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Get the medication
      final medication = await DatabaseHelper.instance.getMedication(entry.medicationId);

      if (medication == null) {
        throw Exception(l10n.doseActionMedicationNotFound);
      }

      // Check if entry is from today
      final now = DateTime.now();
      final isToday = entry.scheduledDateTime.year == now.year &&
          entry.scheduledDateTime.month == now.month &&
          entry.scheduledDateTime.day == now.day;

      if (isToday) {
        // Remove from taken or skipped doses
        final doseTime = entry.scheduledTimeFormatted;
        List<String> takenDoses = List.from(medication.takenDosesToday);
        List<String> skippedDoses = List.from(medication.skippedDosesToday);

        takenDoses.remove(doseTime);
        skippedDoses.remove(doseTime);

        // Restore stock if it was taken
        double newStock = medication.stockQuantity;
        if (entry.status == DoseStatus.taken) {
          newStock += entry.quantity;
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
      }

      // Delete history entry
      await DatabaseHelper.instance.deleteDoseHistory(entry.id);

      // Mark that changes were made
      _hasChanges = true;

      // Reload data
      await _loadData();

      if (!mounted) return;

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.doseHistoryRecordDeleted),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.doseHistoryDeleteError(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getFilterDescription(AppLocalizations l10n) {
    final parts = <String>[];

    if (_selectedMedicationId != null) {
      final medication = _medications.firstWhere((m) => m.id == _selectedMedicationId);
      parts.add(medication.name);
    }

    if (_startDate != null && _endDate != null) {
      parts.add('${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}');
    } else if (_startDate != null) {
      parts.add(l10n.filterFrom('${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'));
    } else if (_endDate != null) {
      parts.add(l10n.filterTo('${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'));
    }

    return parts.join(' • ');
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 80) return Colors.green;
    if (adherence >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseHistoryCard extends StatelessWidget {
  final DoseHistoryEntry entry;
  final VoidCallback onTap;

  const _DoseHistoryCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTaken = entry.status == DoseStatus.taken;
    final statusColor = isTaken ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
          children: [
            // Icon with status indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                entry.medicationType.icon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.medicationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isTaken ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.status.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isTaken) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${entry.quantity} ${entry.medicationType.stockUnitSingular}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        entry.scheduledDateFormatted,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        entry.scheduledTimeFormatted,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  // Always show registered time
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isTaken ? Icons.check_circle_outline : Icons.cancel_outlined,
                        size: 12,
                        color: statusColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.doseRegisteredAt(entry.registeredTimeFormatted),
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Show delay/advance if not on time
                      if (!entry.wasOnTime) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${entry.delayInMinutes > 0 ? '+' : ''}${entry.delayInMinutes} min)',
                          style: TextStyle(
                            fontSize: 11,
                            color: entry.delayInMinutes > 0 ? Colors.orange : Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
