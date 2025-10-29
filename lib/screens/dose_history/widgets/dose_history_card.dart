import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/dose_history_entry.dart';

class DoseHistoryCard extends StatelessWidget {
  final DoseHistoryEntry entry;
  final VoidCallback onTap;

  const DoseHistoryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTaken = entry.status == DoseStatus.taken;
    final statusColor = isTaken ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
          children: [
            // Icon with status indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                entry.medicationType.icon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.medicationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isTaken ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.status.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isTaken) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${entry.quantity} ${entry.medicationType.stockUnitSingular}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        entry.scheduledDateFormatted,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        entry.scheduledTimeFormatted,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  // Always show registered time
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isTaken ? Icons.check_circle_outline : Icons.cancel_outlined,
                        size: 12,
                        color: statusColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.doseRegisteredAt(entry.registeredTimeFormatted),
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Show delay/advance if not on time
                      if (!entry.wasOnTime) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${entry.delayInMinutes > 0 ? '+' : ''}${entry.delayInMinutes} min)',
                          style: TextStyle(
                            fontSize: 11,
                            color: entry.delayInMinutes > 0 ? Colors.orange : Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
