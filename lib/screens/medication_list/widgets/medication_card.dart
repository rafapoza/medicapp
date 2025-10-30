import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final Map<String, dynamic>? nextDoseInfo;
  final String? nextDoseText;
  final Map<String, dynamic>? asNeededDoseInfo;
  final Map<String, dynamic>? fastingPeriod;
  final Widget? todayDosesWidget;
  final VoidCallback onTap;

  const MedicationCard({
    super.key,
    required this.medication,
    this.nextDoseInfo,
    this.nextDoseText,
    this.asNeededDoseInfo,
    this.fastingPeriod,
    this.todayDosesWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Determine stock status icon and color
    IconData? stockIcon;
    Color? stockColor;
    if (medication.isStockEmpty) {
      stockIcon = Icons.error;
      stockColor = Colors.red;
    } else if (medication.isStockLow) {
      stockIcon = Icons.warning;
      stockColor = Colors.orange;
    }

    return Opacity(
      opacity: (medication.isFinished || medication.isSuspended) ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: medication.type.getColor(context).withOpacity(0.2),
                child: Icon(
                  medication.type.icon,
                  color: medication.type.getColor(context),
                ),
              ),
              title: Text(
                medication.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show progress bar if treatment has dates
                  if (medication.progress != null) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: medication.progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          medication.isFinished
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Show suspended status
                  if (medication.isSuspended) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.pause_circle_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.suspended,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  // Show status description
                  if (!medication.isSuspended && medication.statusDescription.isNotEmpty) ...[
                    Text(
                      medication.statusDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: medication.isPending
                                ? Colors.orange
                                : medication.isFinished
                                    ? Colors.grey
                                    : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    medication.type.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: medication.type.getColor(context),
                        ),
                  ),
                  Text(
                    medication.durationDisplayText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  // Show next dose info for programmed medications
                  if (nextDoseInfo != null && nextDoseText != null) ...[
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final isPending = nextDoseInfo!['isPending'] as bool? ?? false;
                        final iconColor = isPending
                            ? Colors.orange
                            : Theme.of(context).colorScheme.primary;
                        final textColor = isPending
                            ? Colors.orange.shade700
                            : Theme.of(context).colorScheme.primary;

                        return Row(
                          children: [
                            Icon(
                              isPending ? Icons.warning_amber : Icons.alarm,
                              size: 18,
                              color: iconColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                nextDoseText!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ]
                  // Show "taken today" info for "as needed" medications
                  else if (asNeededDoseInfo != null) ...[
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final count = asNeededDoseInfo!['count'] as int;
                        final totalQuantity = asNeededDoseInfo!['totalQuantity'] as double;
                        final lastDoseTime = asNeededDoseInfo!['lastDoseTime'] as DateTime;
                        final unit = asNeededDoseInfo!['unit'] as String;

                        final lastDoseTimeStr = '${lastDoseTime.hour.toString().padLeft(2, '0')}:${lastDoseTime.minute.toString().padLeft(2, '0')}';
                        final quantityStr = totalQuantity % 1 == 0
                            ? totalQuantity.toInt().toString()
                            : totalQuantity.toString();

                        final l10n = AppLocalizations.of(context)!;
                        final text = count == 1
                            ? l10n.takenTodaySingle(quantityStr, unit, lastDoseTimeStr)
                            : l10n.takenTodayMultiple(count, quantityStr, unit);

                        return Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                text,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  // Show fasting countdown if available
                  if (fastingPeriod != null) ...[
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final remainingMinutes = fastingPeriod!['remainingMinutes'] as int;
                        final fastingType = fastingPeriod!['fastingType'] as String;
                        final isActive = fastingPeriod!['isActive'] as bool;
                        final fastingEndTime = fastingPeriod!['fastingEndTime'] as DateTime;

                        final l10n = AppLocalizations.of(context)!;

                        // Format remaining time
                        String timeText;
                        if (remainingMinutes < 60) {
                          timeText = l10n.fastingRemainingMinutes(remainingMinutes);
                        } else {
                          final hours = remainingMinutes ~/ 60;
                          final minutes = remainingMinutes % 60;
                          if (minutes == 0) {
                            timeText = l10n.fastingRemainingHours(hours);
                          } else {
                            timeText = l10n.fastingRemainingHoursMinutes(hours, minutes);
                          }
                        }

                        // Format end time
                        final endTimeStr = '${fastingEndTime.hour.toString().padLeft(2, '0')}:${fastingEndTime.minute.toString().padLeft(2, '0')}';

                        final text = isActive
                            ? l10n.fastingActive(timeText, endTimeStr)
                            : l10n.fastingUpcoming(timeText, endTimeStr);

                        final iconColor = isActive
                            ? Colors.orange.shade700
                            : Colors.blue.shade700;
                        final textColor = isActive
                            ? Colors.orange.shade700
                            : Colors.blue.shade700;

                        return Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 18,
                              color: iconColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                text,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
              trailing: stockIcon != null
                  ? GestureDetector(
                      onTap: () {
                        // Show stock information when tapping the indicator
                        final dailyDose = medication.totalDailyDose;
                        final daysLeft = dailyDose > 0
                            ? (medication.stockQuantity / dailyDose).floor()
                            : 0;

                        final message = medication.isStockEmpty
                            ? l10n.medicationStockInfo(medication.name, medication.stockDisplayText)
                            : l10n.durationEstimate(medication.name, medication.stockDisplayText, daysLeft);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 2),
                            backgroundColor: stockColor,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: stockColor!.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          stockIcon,
                          color: stockColor,
                          size: 18,
                        ),
                      ),
                    )
                  : null,
              onTap: onTap,
            ),
            // Today's doses section
            if (todayDosesWidget != null) todayDosesWidget!,
          ],
        ),
      ),
    );
  }
}
