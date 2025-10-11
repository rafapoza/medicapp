import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/medication_list_screen.dart';
import 'services/notification_service.dart';

// Global navigator key to enable navigation from notification callbacks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Spanish
        Locale('en', 'US'), // English
      ],
      locale: const Locale('es', 'ES'),
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
