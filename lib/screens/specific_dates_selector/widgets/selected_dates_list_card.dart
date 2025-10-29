import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import 'date_list_tile.dart';

class SelectedDatesListCard extends StatelessWidget {
  final List<String> sortedDates;
  final Function(String) onRemoveDate;
  final DateTime Function(String) parseDate;

  const SelectedDatesListCard({
    super.key,
    required this.sortedDates,
    required this.onRemoveDate,
    required this.parseDate,
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
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Colors.deepPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.specificDatesSelectorSelectedDates(sortedDates.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedDates.map((dateString) {
              final date = parseDate(dateString);
              return DateListTile(
                date: date,
                onRemove: () => onRemoveDate(dateString),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
