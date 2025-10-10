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
    // Set local location (default to UTC, will be updated based on device)
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

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

    // For Android 13+ (API level 33+)
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // For iOS
    final iOSPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iOSPlugin != null) {
      await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

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

    if (medication.doseTimes.isEmpty) return;

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

      await _scheduleNotification(
        id: notificationId,
        title: '💊 Hora de tomar tu medicamento',
        body: '${medication.name} - ${medication.type.displayName}',
        hour: hour,
        minute: minute,
        payload: '${medication.id}|$i', // Store medication ID and dose index
      );
    }
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
    } catch (e) {
      // If exact alarms are not permitted, try with inexact alarms
      print('Failed to schedule exact alarm: $e');
      print('Falling back to inexact alarm...');

      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (e2) {
        print('Failed to schedule alarm: $e2');
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
}
