import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../../specific_dates_selector_screen.dart';

class SpecificDatesConfigCard extends StatelessWidget {
  final List<String>? selectedDates;
  final ValueChanged<List<String>> onDatesChanged;

  const SpecificDatesConfigCard({
    super.key,
    required this.selectedDates,
    required this.onDatesChanged,
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
              l10n.editFrequencySelectedDates,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedDates != null && selectedDates!.isNotEmpty
                  ? l10n.editFrequencyDatesCount(selectedDates!.length)
                  : l10n.editFrequencyNoDatesSelected,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<List<String>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecificDatesSelectorScreen(
                      initialSelectedDates: selectedDates ?? [],
                    ),
                  ),
                );
                if (result != null) {
                  onDatesChanged(result);
                }
              },
              icon: const Icon(Icons.event),
              label: Text(l10n.editFrequencySelectDatesButton),
            ),
          ],
        ),
      ),
    );
  }
}
