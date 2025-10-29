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

  testWidgets('Should add medication with default type and everyday duration', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);
    await addMedicationWithDuration(tester, 'Paracetamol');

    // Wait for the main screen to complete its async operations after Navigator.pop
    await waitForDatabase(tester);

    expect(find.text('Paracetamol'), findsOneWidget);
    expect(find.text(getL10n(tester).medicationTypePill), findsAtLeastNWidgets(1));
    expect(find.text(getL10n(tester).frequencyDailyTitle), findsAtLeastNWidgets(1));
  });

  testWidgets('Should add medication with "Hasta acabar medicación" duration', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);
    await addMedicationWithDuration(
      tester,
      'Antibiótico',
      durationType: getL10n(tester).durationUntilEmptyTitle,
    );
    await waitForDatabase(tester);

    expect(find.text('Antibiótico'), findsOneWidget);
    // The UI shows the short version "Hasta acabar", not the full title
    expect(find.text(getL10n(tester).editFrequencyUntilFinished), findsWidgets);
  });

  testWidgets('Should select different medication type', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add medication with Jarabe type
    await addMedicationWithDuration(tester, 'Medicina X', type: getL10n(tester).medicationTypeSyrup);
    await waitForDatabase(tester);

    // Verify medication was added with Jarabe type
    expect(find.text('Medicina X'), findsOneWidget);
    expect(find.text(getL10n(tester).medicationTypeSyrup), findsWidgets);
  });

  testWidgets('Should show error when adding duplicate medication', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add first medication
    await addMedicationWithDuration(tester, 'Paracetamol');
    await waitForDatabase(tester);

    // Wait for all animations and overlays (like SnackBars) to complete
    await tester.pumpAndSettle();

    // Try to add the same medication again
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Paracetamol');
    await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
    await tester.tap(find.text(getL10n(tester).btnContinue));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text(getL10n(tester).validationDuplicateMedication), findsWidgets);
    expect(find.text(getL10n(tester).addMedicationTitle), findsWidgets);
  });

  testWidgets('Duplicate validation should be case-insensitive', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add first medication
    await addMedicationWithDuration(tester, 'Ibuprofeno');
    await waitForDatabase(tester);

    // Wait for all animations and overlays (like SnackBars) to complete
    await tester.pumpAndSettle();

    // Try to add the same medication with different case
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'IBUPROFENO');
    await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
    await tester.tap(find.text(getL10n(tester).btnContinue));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text(getL10n(tester).validationDuplicateMedication), findsWidgets);
  });
}
