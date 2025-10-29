import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../../weekly_days_selector_screen.dart';

class WeeklyPatternConfigCard extends StatelessWidget {
  final List<int>? weeklyDays;
  final ValueChanged<List<int>> onDaysChanged;

  const WeeklyPatternConfigCard({
    super.key,
    required this.weeklyDays,
    required this.onDaysChanged,
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
              l10n.editFrequencyWeeklyDaysLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              weeklyDays != null && weeklyDays!.isNotEmpty
                  ? l10n.editFrequencyWeeklyDaysCount(weeklyDays!.length)
                  : l10n.editFrequencyNoDaysSelected,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<List<int>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyDaysSelectorScreen(
                      initialSelectedDays: weeklyDays ?? [],
                    ),
                  ),
                );
                if (result != null) {
                  onDaysChanged(result);
                }
              },
              icon: const Icon(Icons.view_week),
              label: Text(l10n.editFrequencySelectDaysButton),
            ),
          ],
        ),
      ),
    );
  }
}
