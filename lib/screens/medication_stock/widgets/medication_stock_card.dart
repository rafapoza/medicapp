import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../../models/medication.dart';

class MedicationStockCard extends StatelessWidget {
  final Medication medication;

  const MedicationStockCard({
    super.key,
    required this.medication,
  });

  Color _getStockStatusColor() {
    if (medication.isStockEmpty) {
      return Colors.red;
    } else if (medication.isStockLow) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStockStatusIcon() {
    if (medication.isStockEmpty) {
      return Icons.error;
    } else if (medication.isStockLow) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  String _getStockStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (medication.isStockEmpty) {
      return l10n.pillOrganizerNoStock;
    } else if (medication.isStockLow) {
      return l10n.pillOrganizerLowStock;
    } else {
      return l10n.pillOrganizerAvailableStock;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStockStatusColor();
    final statusIcon = _getStockStatusIcon();
    final statusText = _getStockStatusText(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: medication.type.getColor(context).withOpacity(0.2),
                  child: Icon(
                    medication.type.icon,
                    color: medication.type.getColor(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        medication.type.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: medication.type.getColor(context),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pillOrganizerCurrentStock,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication.stockDisplayText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                    ),
                  ],
                ),
                if (medication.doseTimes.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.pillOrganizerEstimatedDuration,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.stockQuantity > 0 && medication.totalDailyDose > 0
                            ? '${(medication.stockQuantity / medication.totalDailyDose).floor()} ${l10n.pillOrganizerDays}'
                            : '0 ${l10n.pillOrganizerDays}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
