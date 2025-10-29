import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class SaveButtons extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onBack;

  const SaveButtons({
    super.key,
    required this.isSaving,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isSaving ? null : onSave,
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.check),
          label: Text(isSaving ? l10n.savingButton : l10n.saveMedicationButton),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: isSaving ? null : onBack,
          icon: const Icon(Icons.arrow_back),
          label: Text(l10n.btnBack),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
