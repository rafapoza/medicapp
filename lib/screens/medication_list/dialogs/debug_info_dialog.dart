import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';
import '../../../services/notification_service.dart';

class DebugInfoDialog {
  static Future<void> show({
    required BuildContext context,
    required List<Medication> medications,
  }) async {
    final notificationsEnabled = await NotificationService.instance.areNotificationsEnabled();
    final canScheduleExact = await NotificationService.instance.canScheduleExactAlarms();
    final pendingNotifications = await NotificationService.instance.getPendingNotifications();

    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;

    // Build notification info with medication data
    final notificationInfoList = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final notification in pendingNotifications) {
      String? medicationName;
      String? scheduledTime;
      String? scheduledDate;
      String? notificationType;
      bool isPastDue = false;

      // Determine notification type based on ID range
      final id = notification.id;
      if (id >= 6000000) {
        notificationType = l10n.notificationTypeDynamicFasting;
      } else if (id >= 5000000) {
        notificationType = l10n.notificationTypeScheduledFasting;
      } else if (id >= 4000000) {
        notificationType = l10n.notificationTypeWeeklyPattern;
      } else if (id >= 3000000) {
        notificationType = l10n.notificationTypeSpecificDate;
      } else if (id >= 2000000) {
        notificationType = l10n.notificationTypePostponed;
      } else {
        notificationType = l10n.notificationTypeDailyRecurring;
      }

      // Try to parse payload to get medication info
      if (notification.payload != null && notification.payload!.isNotEmpty) {
        final parts = notification.payload!.split('|');
        if (parts.isNotEmpty) {
          final medicationId = parts[0];
          final medication = medications.firstWhere(
            (m) => m.id == medicationId,
            orElse: () => medications.first, // fallback
          );

          if (medication.id == medicationId) {
            medicationName = medication.name;

            // Check if this is a fasting notification
            if (parts.length > 1 && (parts[1].contains('fasting'))) {
              // This is a fasting notification
              final isDynamic = parts[1].contains('dynamic');
              final fastingType = medication.fastingType == 'before' ? l10n.beforeTaking : l10n.afterTaking;
              final duration = medication.fastingDurationMinutes ?? 0;

              scheduledTime = '$fastingType ($duration min)';
              scheduledDate = isDynamic ? l10n.basedOnActualDose : l10n.basedOnSchedule;
            } else if (parts.length > 1) {
              // Regular dose notification
              final doseIndexOrTime = parts[1];

              // Check if it's a time string (HH:mm)
              if (doseIndexOrTime.contains(':')) {
                scheduledTime = doseIndexOrTime;
              } else {
                // It's a dose index
                final doseIndex = int.tryParse(doseIndexOrTime);
                if (doseIndex != null && doseIndex < medication.doseTimes.length) {
                  scheduledTime = medication.doseTimes[doseIndex];
                }
              }

              // Infer date based on notification type and medication
              if (scheduledTime != null) {
                final timeParts = scheduledTime.split(':');
                final schedHour = int.parse(timeParts[0]);
                final schedMin = int.parse(timeParts[1]);

                if (notificationType == l10n.notificationTypeDailyRecurring) {
                  // Check if it's for today or tomorrow
                  final currentMinutes = now.hour * 60 + now.minute;
                  final scheduledMinutes = schedHour * 60 + schedMin;

                  if (scheduledMinutes > currentMinutes) {
                    scheduledDate = l10n.today(now.day, now.month, now.year);
                    isPastDue = false;
                  } else {
                    final tomorrow = now.add(const Duration(days: 1));
                    scheduledDate = l10n.tomorrow(tomorrow.day, tomorrow.month, tomorrow.year);
                    isPastDue = false; // Not past due if it's scheduled for tomorrow
                  }
                } else if (notificationType == l10n.notificationTypeSpecificDate || notificationType == l10n.notificationTypeWeeklyPattern) {
                  // Try to find the next date from medication schedule
                  if (medication.selectedDates != null && medication.selectedDates!.isNotEmpty) {
                    // For specific dates
                    final today = DateTime(now.year, now.month, now.day);
                    for (final dateString in medication.selectedDates!) {
                      final dateParts = dateString.split('-');
                      final date = DateTime(
                        int.parse(dateParts[0]),
                        int.parse(dateParts[1]),
                        int.parse(dateParts[2]),
                      );

                      if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
                        scheduledDate = '${date.day}/${date.month}/${date.year}';

                        // Check if past due
                        if (date.isAtSameMomentAs(today)) {
                          final currentMinutes = now.hour * 60 + now.minute;
                          final scheduledMinutes = schedHour * 60 + schedMin;
                          isPastDue = scheduledMinutes < currentMinutes;
                        }
                        break;
                      }
                    }
                  } else if (medication.weeklyDays != null && medication.weeklyDays!.isNotEmpty) {
                    // For weekly patterns - find next matching day
                    for (int i = 0; i <= 7; i++) {
                      final checkDate = now.add(Duration(days: i));
                      if (medication.weeklyDays!.contains(checkDate.weekday)) {
                        scheduledDate = '${checkDate.day}/${checkDate.month}/${checkDate.year}';

                        // Check if past due (only if it's today)
                        if (i == 0) {
                          final currentMinutes = now.hour * 60 + now.minute;
                          final scheduledMinutes = schedHour * 60 + schedMin;
                          isPastDue = scheduledMinutes < currentMinutes;
                        }
                        break;
                      }
                    }
                  } else {
                    scheduledDate = l10n.todayOrLater;
                  }
                } else if (notificationType == l10n.notificationTypePostponed) {
                  // Postponed notifications are usually for today or tomorrow
                  final currentMinutes = now.hour * 60 + now.minute;
                  final scheduledMinutes = schedHour * 60 + schedMin;

                  if (scheduledMinutes > currentMinutes) {
                    scheduledDate = l10n.today(now.day, now.month, now.year);
                  } else {
                    final tomorrow = now.add(const Duration(days: 1));
                    scheduledDate = l10n.tomorrow(tomorrow.day, tomorrow.month, tomorrow.year);
                  }
                } else {
                  // Default case: assume it's for today or tomorrow based on time
                  final currentMinutes = now.hour * 60 + now.minute;
                  final scheduledMinutes = schedHour * 60 + schedMin;

                  if (scheduledMinutes > currentMinutes) {
                    scheduledDate = l10n.today(now.day, now.month, now.year);
                    isPastDue = false;
                  } else {
                    final tomorrow = now.add(const Duration(days: 1));
                    scheduledDate = l10n.tomorrow(tomorrow.day, tomorrow.month, tomorrow.year);
                    isPastDue = false;
                  }
                }
              }
            }
          }
        }
      }

      notificationInfoList.add({
        'notification': notification,
        'medicationName': medicationName,
        'scheduledTime': scheduledTime,
        'scheduledDate': scheduledDate,
        'notificationType': notificationType,
        'isPastDue': isPastDue,
      });
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationDebugTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.notificationPermissions(notificationsEnabled ? l10n.yesText : l10n.noText),
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.exactAlarmsAndroid12(canScheduleExact ? l10n.yesText : l10n.noText),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canScheduleExact ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              if (!canScheduleExact) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.importantWarning,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.withoutPermissionNoNotifications,
                        style: TextStyle(fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.alarmsSettings,
                        style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(l10n.pendingNotificationsCount(pendingNotifications.length)),
              const SizedBox(height: 8),
              Text(l10n.medicationsWithSchedules(medications.where((m) => m.doseTimes.isNotEmpty).length, medications.length)),
              const SizedBox(height: 16),
              Text(l10n.scheduledNotifications, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (pendingNotifications.isEmpty)
                Text(l10n.noScheduledNotifications, style: TextStyle(color: Colors.orange))
              else
                ...notificationInfoList.map((info) {
                  final notification = info['notification'];
                  final medicationName = info['medicationName'] as String?;
                  final scheduledTime = info['scheduledTime'] as String?;
                  final scheduledDate = info['scheduledDate'] as String?;
                  final notificationType = info['notificationType'] as String?;
                  final isPastDue = info['isPastDue'] as bool;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPastDue
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        border: isPastDue
                            ? Border.all(color: Colors.red, width: 1)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ID: ${notification.id}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isPastDue ? Colors.red : null,
                                ),
                              ),
                              if (isPastDue) ...[
                                const SizedBox(width: 8),
                                Text(
                                  l10n.pastDueWarning,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (medicationName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.medicationInfo(medicationName),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                          if (notificationType != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              l10n.notificationType(notificationType),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (scheduledDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.scheduleDate(scheduledDate),
                              style: TextStyle(
                                fontSize: 14,
                                color: isPastDue ? Colors.red.shade700 : Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (scheduledTime != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              l10n.scheduleTime(scheduledTime),
                              style: TextStyle(
                                fontSize: 14,
                                color: isPastDue ? Colors.red.shade700 : Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            notification.title ?? l10n.noTitle,
                            style: const TextStyle(fontSize: 15),
                          ),
                          if (notification.body != null)
                            Text(
                              notification.body!,
                              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              Text(l10n.medicationsAndSchedules, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...medications.map((medication) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (medication.doseTimes.isEmpty)
                        Text(l10n.noSchedulesConfiguredWarning, style: TextStyle(fontSize: 14, color: Colors.orange))
                      else
                        ...medication.doseTimes.map((time) => Text('  • $time', style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.closeButton),
          ),
        ],
      ),
    );
  }
}
