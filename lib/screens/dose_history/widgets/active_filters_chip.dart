import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ActiveFiltersChip extends StatelessWidget {
  final String filterDescription;
  final VoidCallback onClear;

  const ActiveFiltersChip({
    super.key,
    required this.filterDescription,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              filterDescription,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear, size: 16),
            label: Text(l10n.doseHistoryClear),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}
