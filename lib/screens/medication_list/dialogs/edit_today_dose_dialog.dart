import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class EditTodayDoseDialog {
  static Future<String?> show(
    BuildContext context, {
    required String medicationName,
    required String doseTime,
    required bool isTaken,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.doseOfMedicationAt(medicationName, doseTime)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentStatus(isTaken ? l10n.takenStatus : l10n.skippedStatus),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.whatDoYouWantToDo,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, 'delete'),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.deleteButton),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'toggle'),
            icon: Icon(isTaken ? Icons.cancel : Icons.check_circle),
            label: Text(isTaken ? l10n.markAsSkipped : l10n.markAsTaken),
            style: FilledButton.styleFrom(
              backgroundColor: isTaken ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
