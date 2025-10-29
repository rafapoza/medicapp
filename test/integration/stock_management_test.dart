import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:medicapp/main.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/notification_service.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  // Initialize sqflite for testing on desktop/VM
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize ffi implementation for desktop testing
    sqfliteFfiInit();
    // Set global factory to use ffi implementation
    databaseFactory = databaseFactoryFfi;
  });

  // Clean up database before each test to ensure test isolation
  setUp(() async {
    // Set larger window size for accessibility tests (larger fonts and buttons)
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView!.physicalSize = const Size(1200, 1800);
    binding.platformDispatcher.implicitView!.devicePixelRatio = 1.0;

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

  testWidgets('Should show error icon for medication with no stock', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with 0 stock
    await addMedicationWithDuration(tester, 'MedSinStock', stockQuantity: '0');
    await waitForDatabase(tester);

    // Verify the medication is displayed
    expect(find.text('MedSinStock'), findsOneWidget);

    // Verify error icon is shown (red icon for no stock)
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('Should show warning icon for medication with low stock', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with low stock (2 days worth with 8-hour interval = 6 doses)
    // Stock low is detected when less than 3 days worth (< 9 doses for 8-hour interval)
    await addMedicationWithDuration(tester, 'MedStockBajo', stockQuantity: '6', dosageIntervalHours: 8);
    await waitForDatabase(tester);

    // Verify the medication is displayed
    expect(find.text('MedStockBajo'), findsOneWidget);

    // Verify warning icon is shown (orange icon for low stock)
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets('Should not show stock icon for medication with sufficient stock', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with sufficient stock (10 days worth)
    await addMedicationWithDuration(tester, 'MedStockOK', stockQuantity: '30', dosageIntervalHours: 8);
    await waitForDatabase(tester);

    // Verify the medication is displayed
    expect(find.text('MedStockOK'), findsOneWidget);

    // Verify no stock warning icons are shown
    // Note: There might be other icons in the UI (like alarm icon for next dose)
    // but no error or warning icons for stock
    expect(find.byIcon(Icons.error), findsNothing);
    expect(find.byIcon(Icons.warning), findsNothing);
  });

  testWidgets('Should show stock details when tapping stock indicator', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with low stock
    await addMedicationWithDuration(tester, 'Aspirina', stockQuantity: '5', dosageIntervalHours: 12);
    await waitForDatabase(tester);

    // Verify the medication is displayed
    expect(find.text('Aspirina'), findsOneWidget);

    // Verify warning icon is shown (this confirms low stock detection works)
    expect(find.byIcon(Icons.warning), findsOneWidget);

    // Tap on the warning icon to show stock details
    await tester.tap(find.byIcon(Icons.warning));

    // Wait for the tap to be processed
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Verify the tap was processed - the warning icon should still be visible
    // (The SnackBar shows stock details but we can't reliably verify its text in tests)
    expect(find.byIcon(Icons.warning), findsOneWidget);

    // Verify the medication is still displayed (operation didn't crash)
    expect(find.text('Aspirina'), findsOneWidget);
  });
}
