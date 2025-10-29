import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class WeeklyDaysSelectorCard extends StatelessWidget {
  final List<int>? weeklyDays;
  final VoidCallback onSelectDays;

  const WeeklyDaysSelectorCard({
    super.key,
    required this.weeklyDays,
    required this.onSelectDays,
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
              l10n.selectWeeklyDaysTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectWeeklyDaysSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSelectDays,
              icon: const Icon(Icons.date_range),
              label: Text(weeklyDays == null || weeklyDays!.isEmpty
                  ? l10n.selectWeeklyDaysButton
                  : l10n.daySelected(weeklyDays!.length)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
