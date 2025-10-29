import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class IntervalInputCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const IntervalInputCard({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dosageIntervalLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.dosageIntervalHelp,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.dosageIntervalFieldLabel,
            hintText: l10n.dosageIntervalHint,
            prefixIcon: const Icon(Icons.access_time),
            suffixText: l10n.dosageIntervalUnit,
            helperText: l10n.dosageIntervalValidValues,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => onChanged(),
        ),
      ],
    );
  }
}
