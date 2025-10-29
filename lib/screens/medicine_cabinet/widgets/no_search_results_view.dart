import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class NoSearchResultsView extends StatelessWidget {
  const NoSearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.medicineCabinetNoResults,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.medicineCabinetNoResultsHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
