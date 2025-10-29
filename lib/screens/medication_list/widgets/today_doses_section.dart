import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';

class TodayDosesSection extends StatelessWidget {
  final Medication medication;
  final Function(String doseTime, bool isTaken) onDoseTap;

  const TodayDosesSection({
    super.key,
    required this.medication,
    required this.onDoseTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allDoses = [
      ...medication.takenDosesToday.map((time) => {'time': time, 'status': 'taken'}),
      ...medication.skippedDosesToday.map((time) => {'time': time, 'status': 'skipped'}),
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

              return InkWell(
                onTap: () => onDoseTap(time, isTaken),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isTaken ? Colors.green : Colors.orange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isTaken ? Colors.green : Colors.orange).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTaken ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: isTaken ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isTaken ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
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
