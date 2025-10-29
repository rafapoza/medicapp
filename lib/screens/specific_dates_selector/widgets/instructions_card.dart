import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class InstructionsCard extends StatelessWidget {
  final VoidCallback onAddDate;

  const InstructionsCard({
    super.key,
    required this.onAddDate,
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
              l10n.specificDatesSelectorSelectDates,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.specificDatesSelectorDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onAddDate,
              icon: const Icon(Icons.add),
              label: Text(l10n.specificDatesSelectorAddDate),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple.withOpacity(0.2),
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
