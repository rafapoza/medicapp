import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class SpecificDatesSelectorCard extends StatelessWidget {
  final List<String>? specificDates;
  final VoidCallback onSelectDates;

  const SpecificDatesSelectorCard({
    super.key,
    required this.specificDates,
    required this.onSelectDates,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectDatesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectDatesSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSelectDates,
              icon: const Icon(Icons.event),
              label: Text(specificDates == null || specificDates!.isEmpty
                  ? l10n.selectDatesButton
                  : l10n.dateSelected(specificDates!.length)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
