import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';

class FilterDialog {
  static Future<void> show({
    required BuildContext context,
    required List<Medication> medications,
    required String? selectedMedicationId,
    required DateTime? startDate,
    required DateTime? endDate,
    required Function(String?, DateTime?, DateTime?) onApply,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    String? tempSelectedMedicationId = selectedMedicationId;
    DateTime? tempStartDate = startDate;
    DateTime? tempEndDate = endDate;

    await showDialog(
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
                    value: tempSelectedMedicationId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.doseHistoryAllMedications),
                      ),
                      ...medications.map((med) => DropdownMenuItem<String?>(
                            value: med.id,
                            child: Text(med.name),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        tempSelectedMedicationId = value;
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
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                tempStartDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            tempStartDate != null
                                ? '${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}'
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
                              initialDate: tempEndDate ?? DateTime.now(),
                              firstDate: tempStartDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                tempEndDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            tempEndDate != null
                                ? '${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}'
                                : l10n.dateToLabel,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (tempStartDate != null || tempEndDate != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            tempStartDate = null;
                            tempEndDate = null;
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
              onApply(tempSelectedMedicationId, tempStartDate, tempEndDate);
            },
            child: Text(l10n.doseHistoryApply),
          ),
        ],
      ),
    );
  }
}
