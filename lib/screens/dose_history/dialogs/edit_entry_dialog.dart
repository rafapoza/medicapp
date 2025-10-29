import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/dose_history_entry.dart';

class EditEntryDialog {
  static Future<EditEntryAction?> show({
    required BuildContext context,
    required DoseHistoryEntry entry,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Check if entry is from today (allows deletion)
    final now = DateTime.now();
    final isToday = entry.scheduledDateTime.year == now.year &&
        entry.scheduledDateTime.month == now.month &&
        entry.scheduledDateTime.day == now.day;

    return showDialog<EditEntryAction>(
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
              onPressed: () => Navigator.pop(context, EditEntryAction.delete),
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
            onPressed: () => Navigator.pop(context, null),
            child: Text(l10n.btnCancel),
          ),
          if (entry.status == DoseStatus.taken)
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, EditEntryAction.markAsSkipped),
              icon: const Icon(Icons.cancel),
              label: Text(l10n.doseHistoryMarkAsSkipped),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            )
          else
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, EditEntryAction.markAsTaken),
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
}

enum EditEntryAction {
  markAsTaken,
  markAsSkipped,
  delete,
}
