import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class ContinueCancelButtons extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const ContinueCancelButtons({
    super.key,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onContinue,
          icon: const Icon(Icons.arrow_forward),
          label: Text(l10n.specificDatesSelectorContinue),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel),
          label: Text(l10n.btnCancel),
        ),
      ],
    );
  }
}
