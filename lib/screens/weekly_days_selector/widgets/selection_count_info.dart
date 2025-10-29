import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class SelectionCountInfo extends StatelessWidget {
  final int selectedCount;

  const SelectionCountInfo({
    super.key,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.teal,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.weeklyDaysSelectorSelectedCount(selectedCount, selectedCount != 1 ? 's' : ''),
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
