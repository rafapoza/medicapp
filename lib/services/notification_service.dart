import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medication.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService instance = NotificationService._init();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Flag to disable notifications during testing
  bool _isTestMode = false;

  NotificationService._init();

  /// Enable test mode (disables actual notifications)
  void enableTestMode() {
    _isTestMode = true;
  }

  /// Disable test mode (enables actual notifications)
  void disableTestMode() {
    _isTestMode = false;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    // Skip initialization in test mode
    if (_isTestMode) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Try to use the device's local timezone, fallback to Europe/Madrid
    try {
      // Get device timezone name (this may not work on all platforms)
      final String timeZoneName = DateTime.now().timeZoneName;
      print('Device timezone name: $timeZoneName');

      // Common timezone mappings
      // For most cases, we'll use Europe/Madrid as it's a common timezone
      // but log the device timezone for debugging
      tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
      print('Using timezone: Europe/Madrid');
    } catch (e) {
      print('Error setting timezone: $e');
      // Fallback to UTC if there's an error
      tz.setLocalLocation(tz.UTC);
      print('Using fallback timezone: UTC');
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Request notification permissions (especially important for iOS and Android 13+)
  Future<bool> requestPermissions() async {
    // Skip in test mode
    if (_isTestMode) return true;

    bool granted = true;

    // For Android 13+ (API level 33+)
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      granted = result ?? false;
      print('Android notification permission granted: $granted');
    }

    // For iOS
    final iOSPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iOSPlugin != null) {
      final result = await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
      print('iOS notification permission granted: $granted');
    }

    return granted;
  }

  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    // Skip in test mode
    if (_isTestMode) return true;

    // For Android
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final result = await androidPlugin.areNotificationsEnabled();
      return result ?? false;
    }

    // For iOS, we can't directly check, so we return true if we've initialized
    return true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Here you can handle navigation when user taps on notification
    // For example, navigate to medication details
    print('Notification tapped: ${response.payload}');
  }

  /// Schedule notifications for a medication based on its dose times
  Future<void> scheduleMedicationNotifications(Medication medication) async {
    // Skip in test mode
    if (_isTestMode) return;

    if (medication.doseTimes.isEmpty) {
      print('No dose times for medication: ${medication.name}');
      return;
    }

    print('Scheduling notifications for ${medication.name} with ${medication.doseTimes.length} dose times');

    // Cancel any existing notifications for this medication first
    await cancelMedicationNotifications(medication.id);

    // Schedule a notification for each dose time
    for (int i = 0; i < medication.doseTimes.length; i++) {
      final doseTime = medication.doseTimes[i];
      final parts = doseTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Create unique notification ID for each dose
      // Using medication ID hash + dose index
      final notificationId = _generateNotificationId(medication.id, i);

      print('Scheduling notification ID $notificationId for ${medication.name} at $hour:$minute');

      await _scheduleNotification(
        id: notificationId,
        title: '💊 Hora de tomar tu medicamento',
        body: '${medication.name} - ${medication.type.displayName}',
        hour: hour,
        minute: minute,
        payload: '${medication.id}|$i', // Store medication ID and dose index
      );
    }

    // Verify notifications were scheduled
    final pending = await getPendingNotifications();
    print('Total pending notifications after scheduling: ${pending.length}');
  }

  /// Schedule a single notification at a specific time daily
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    // Skip in test mode
    if (_isTestMode) return;

    // Get the current time
    final now = tz.TZDateTime.now(tz.local);

    // Schedule for today at the specified time
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'medication_reminders', // channel ID
      'Recordatorios de Medicamentos', // channel name
      channelDescription: 'Notificaciones para recordarte tomar tus medicamentos',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Recordatorio de medicamento',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    // iOS notification details
    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Schedule the notification to repeat daily
    print('Attempting to schedule notification ID $id for $hour:$minute on $scheduledDate');

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
        payload: payload,
      );
      print('Successfully scheduled notification ID $id with exactAllowWhileIdle');
    } catch (e) {
      // If exact alarms are not permitted, try with inexact alarms
      print('Failed to schedule exact alarm: $e');
      print('This may require SCHEDULE_EXACT_ALARM permission on Android 12+');
      print('Falling back to inexact alarm...');

      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
        print('Successfully scheduled notification ID $id with inexact mode');
      } catch (e2) {
        print('Failed to schedule inexact alarm: $e2');
        // Don't throw - allow the app to continue without notifications
      }
    }
  }

  /// Cancel all notifications for a specific medication
  Future<void> cancelMedicationNotifications(String medicationId) async {
    // Skip in test mode
    if (_isTestMode) return;

    // We need to cancel all possible dose notifications for this medication
    // Assuming maximum 24 doses per day (hourly)
    for (int i = 0; i < 24; i++) {
      final notificationId = _generateNotificationId(medicationId, i);
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    // Skip in test mode
    if (_isTestMode) return;

    await _notificationsPlugin.cancelAll();
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    // Return empty list in test mode
    if (_isTestMode) return [];

    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Generate a unique notification ID based on medication ID and dose index
  int _generateNotificationId(String medicationId, int doseIndex) {
    // Use a combination of medication ID hash and dose index
    // This ensures unique IDs for each dose of each medication
    final medicationHash = medicationId.hashCode.abs();
    // Keep the ID within a reasonable range to avoid overflow
    return (medicationHash % 1000000) * 100 + doseIndex;
  }

  /// Test notification (for debugging)
  Future<void> showTestNotification() async {
    // Skip in test mode
    if (_isTestMode) return;

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification from MedicApp',
      notificationDetails,
    );
  }

  /// Test scheduled notification (1 minute in the future)
  Future<void> scheduleTestNotification() async {
    // Skip in test mode
    if (_isTestMode) return;

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(minutes: 1));

    print('Scheduling test notification for: $scheduledDate (1 minute from now)');
    print('Current time: $now');
    print('Timezone: ${tz.local}');

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        999999, // Unique ID for test
        '⏰ Test Programmed Notification',
        'If you see this, scheduled notifications work!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Test notification scheduled successfully for 1 minute from now');
    } catch (e) {
      print('Error scheduling test notification: $e');
    }
  }
}
