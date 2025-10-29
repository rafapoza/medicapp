import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class CustomIntervalConfigCard extends StatelessWidget {
  final TextEditingController intervalController;

  const CustomIntervalConfigCard({
    super.key,
    required this.intervalController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.editFrequencyIntervalLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: intervalController,
              decoration: InputDecoration(
                labelText: l10n.editFrequencyIntervalField,
                hintText: l10n.editFrequencyIntervalHint,
                prefixIcon: const Icon(Icons.timeline),
                suffixText: l10n.pillOrganizerDays,
                helperText: l10n.editFrequencyIntervalHelp,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
