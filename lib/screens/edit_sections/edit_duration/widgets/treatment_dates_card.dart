import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class TreatmentDatesCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  const TreatmentDatesCard({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
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
              l10n.editDurationTreatmentDates,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Start date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.editDurationStartDate),
              subtitle: Text(
                startDate != null
                    ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                    : l10n.editDurationNotSelected,
              ),
              trailing: const Icon(Icons.edit),
              onTap: onSelectStartDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            const SizedBox(height: 12),

            // End date
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(l10n.editDurationEndDate),
              subtitle: Text(
                endDate != null
                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                    : l10n.editDurationNotSelected,
              ),
              trailing: const Icon(Icons.edit),
              onTap: onSelectEndDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),

            if (startDate != null && endDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.editDurationDays(endDate!.difference(startDate!).inDays + 1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
