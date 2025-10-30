import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';

class TodayDosesSection extends StatelessWidget {
  final Medication medication;
  final Function(String doseTime, bool isTaken) onDoseTap;
  final Map<String, DateTime>? actualDoseTimes;
  final bool showActualTime;

  const TodayDosesSection({
    super.key,
    required this.medication,
    required this.onDoseTap,
    this.actualDoseTimes,
    this.showActualTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allDoses = [
      ...medication.takenDosesToday.map((time) => {'time': time, 'status': 'taken'}),
      ...medication.skippedDosesToday.map((time) => {'time': time, 'status': 'skipped'}),
      ...medication.extraDosesToday.map((time) => {'time': time, 'status': 'extra'}),
    ]..sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Text(
            l10n.todayDosesLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allDoses.map((dose) {
              final time = dose['time'] as String;
              final status = dose['status'] as String;
              final isTaken = status == 'taken';
              final isSkipped = status == 'skipped';
              final isExtra = status == 'extra';

              // Determine which time to show
              String displayTime = time;
              if (isTaken && showActualTime && actualDoseTimes != null && actualDoseTimes!.containsKey(time)) {
                final actualTime = actualDoseTimes![time]!;
                displayTime = '${actualTime.hour.toString().padLeft(2, '0')}:${actualTime.minute.toString().padLeft(2, '0')}';
              }

              // Determine colors and icons based on status
              Color bgColor;
              Color borderColor;
              Color textColor;
              IconData icon;
              if (isExtra) {
                bgColor = Colors.purple.withOpacity(0.1);
                borderColor = Colors.purple.withOpacity(0.3);
                textColor = Colors.purple.shade700;
                icon = Icons.star;
              } else if (isTaken) {
                bgColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green.withOpacity(0.3);
                textColor = Colors.green.shade700;
                icon = Icons.check_circle;
              } else {
                bgColor = Colors.orange.withOpacity(0.1);
                borderColor = Colors.orange.withOpacity(0.3);
                textColor = Colors.orange.shade700;
                icon = Icons.cancel;
              }

              return InkWell(
                onTap: isExtra ? null : () => onDoseTap(time, isTaken),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isExtra ? Colors.purple : (isTaken ? Colors.green : Colors.orange),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        displayTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (isExtra) ...[
                        const SizedBox(width: 4),
                        Text(
                          'Extra',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
