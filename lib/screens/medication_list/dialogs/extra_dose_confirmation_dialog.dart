import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ExtraDoseConfirmationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String medicationName,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.allDosesTakenToday),
              ),
            ],
          ),
          content: Text(
            l10n.extraDoseConfirmationMessage(medicationName),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.btnCancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.extraDoseConfirm),
            ),
          ],
        );
      },
    );
  }
}
