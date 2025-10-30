import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicapp/main.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/notification_service.dart';
import '../helpers/widget_test_helpers.dart';
import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DatabaseTestHelper.setupAll();

  // Clean up database before each test to ensure test isolation
  setUp(() async {
    // Set larger window size for accessibility tests (larger fonts and buttons)
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView!.physicalSize = const Size(1200, 1800);
    binding.platformDispatcher.implicitView!.devicePixelRatio = 1.0;

    // Mock SharedPreferences to avoid plugin errors in tests
    SharedPreferences.setMockInitialValues({});

    // Close and reset the database to get a fresh in-memory instance
    await DatabaseHelper.resetDatabase();
    // Enable in-memory mode for this test
    DatabaseHelper.setInMemoryDatabase(true);
    // Enable test mode for notifications (disables actual notifications)
    NotificationService.instance.enableTestMode();
  });

  // Clean up after each test
  tearDown(() {
    // Reset window size to default
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView!.resetPhysicalSize();
    binding.platformDispatcher.implicitView!.resetDevicePixelRatio();
  });

  testWidgets('MedicApp should load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());

    // Initial pump to let initState run
    await tester.pump();

    // Wait for database operations and async timers to complete
    await waitForDatabase(tester);

    // Additional wait for the new getMedicationIdsWithDosesToday query
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 1000));
    });

    // Pump to rebuild UI after all database operations
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify that the app shows the correct title.
    expect(find.text(getL10n(tester).mainScreenTitle), findsWidgets);

    // Verify that the empty state is shown.
    expect(find.text(getL10n(tester).mainScreenEmptyTitle), findsWidgets);

    // Verify that the add button is present.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
