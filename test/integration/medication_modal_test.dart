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

  testWidgets('Should open modal when tapping a medication', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication first
    await addMedicationWithDuration(tester, 'Aspirina');
    await waitForDatabase(tester);

    // Tap on the medication card
    await tester.tap(find.text('Aspirina'));
    await tester.pumpAndSettle();

    // Verify modal is shown
    expect(find.text(getL10n(tester).medicineCabinetDeleteMedication), findsWidgets);
    expect(find.text(getL10n(tester).medicineCabinetEditMedication), findsWidgets);
    expect(find.text(getL10n(tester).btnCancel), findsWidgets);
    // The medication name should appear twice: once in the list and once in the modal
    expect(find.text('Aspirina'), findsNWidgets(2));
  });

  testWidgets('Modal should display treatment duration', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with "Hasta acabar" duration
    await addMedicationWithDuration(
      tester,
      'Vitamina C',
      durationType: getL10n(tester).durationUntilEmptyTitle,
    );
    await waitForDatabase(tester);

    // Tap on the medication to open modal
    await tester.tap(find.text('Vitamina C'));
    await tester.pumpAndSettle();

    // Verify duration is displayed in modal (short version "Hasta acabar")
    expect(find.text(getL10n(tester).editFrequencyUntilFinished), findsWidgets);
  });
}
