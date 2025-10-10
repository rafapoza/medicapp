import 'package:flutter/material.dart';
import 'screens/medication_list_screen.dart';
import 'services/notification_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  try {
    await NotificationService.instance.initialize();
    print('Notification service initialized successfully');

    // Request notification permissions
    final granted = await NotificationService.instance.requestPermissions();
    print('Notification permissions granted: $granted');

    if (!granted) {
      print('WARNING: Notification permissions were not granted!');
    }

    // Verify notifications are enabled
    final enabled = await NotificationService.instance.areNotificationsEnabled();
    print('Notifications enabled: $enabled');
  } catch (e) {
    print('Error initializing notifications: $e');
  }

  runApp(const MedicApp());
}

class MedicApp extends StatelessWidget {
  const MedicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedicApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MedicationListScreen(),
    );
  }
}
