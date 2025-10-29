import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class DoseSelectionDialog {
  static Future<String?> show(
    BuildContext context, {
    required String medicationName,
    required List<String> availableDoses,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.registerDoseOfMedication(medicationName)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.whichDoseDidYouTake,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...availableDoses.map((doseTime) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, doseTime),
                    icon: const Icon(Icons.alarm),
                    label: Text(doseTime),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.btnCancel),
            ),
          ],
        );
      },
    );
  }
}
