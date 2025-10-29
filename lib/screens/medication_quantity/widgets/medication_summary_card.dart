import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../../models/medication_type.dart';
import '../../../models/treatment_duration_type.dart';

class MedicationSummaryCard extends StatelessWidget {
  final String medicationName;
  final MedicationType medicationType;
  final TreatmentDurationType durationType;
  final Map<String, double> doseSchedule;
  final List<String>? specificDates;
  final List<int>? weeklyDays;
  final int? dayInterval;

  const MedicationSummaryCard({
    super.key,
    required this.medicationName,
    required this.medicationType,
    required this.durationType,
    required this.doseSchedule,
    this.specificDates,
    this.weeklyDays,
    this.dayInterval,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.summaryTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              icon: Icons.medication,
              label: l10n.summaryMedication,
              value: medicationName,
            ),
            _SummaryRow(
              icon: medicationType.icon,
              label: l10n.summaryType,
              value: medicationType.displayName,
            ),
            if (doseSchedule.isNotEmpty) ...[
              _SummaryRow(
                icon: Icons.access_time,
                label: l10n.summaryDosesPerDay,
                value: '${doseSchedule.length}',
              ),
              _SummaryRow(
                icon: Icons.schedule,
                label: l10n.summarySchedules,
                value: doseSchedule.keys.join(', '),
              ),
            ],
            _SummaryRow(
              icon: Icons.calendar_today,
              label: l10n.summaryFrequency,
              value: _getFrequencyDescription(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (durationType) {
      case TreatmentDurationType.everyday:
        return l10n.summaryFrequencyDaily;
      case TreatmentDurationType.untilFinished:
        return l10n.summaryFrequencyUntilEmpty;
      case TreatmentDurationType.specificDates:
        return l10n.summaryFrequencySpecificDates(specificDates?.length ?? 0);
      case TreatmentDurationType.weeklyPattern:
        return l10n.summaryFrequencyWeekdays(weeklyDays?.length ?? 0);
      case TreatmentDurationType.intervalDays:
        final interval = dayInterval ?? 2;
        return l10n.summaryFrequencyEveryNDays(interval);
      case TreatmentDurationType.asNeeded:
        return l10n.summaryFrequencyAsNeeded;
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
