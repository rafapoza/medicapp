import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class DeleteConfirmationDialog {
  static Future<bool> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.doseHistoryConfirmDelete),
        content: Text(l10n.doseHistoryConfirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
