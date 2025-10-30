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

  testWidgets('Should delete medication when delete button is pressed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Omeprazol');
    await waitForDatabase(tester);

    // Verify medication is in the list
    expect(find.text('Omeprazol'), findsOneWidget);

    // Tap on the medication to open modal
    await tester.tap(find.text('Omeprazol'));
    await tester.pumpAndSettle();

    // Scroll to and tap the delete button
    await scrollToWidget(tester, find.text(getL10n(tester).medicineCabinetDeleteMedication));
    await tester.tap(find.text(getL10n(tester).medicineCabinetDeleteMedication));
    await tester.pumpAndSettle();

    // Wait for database delete operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Verify medication is no longer in the list
    expect(find.text('Omeprazol'), findsNothing);

    // Note: The deletion success SnackBar is shown in MedicineCabinetScreen
    // and disappears when we navigate back, so we can't verify it here

    // Verify empty state is shown
    expect(find.text(getL10n(tester).mainScreenEmptyTitle), findsWidgets);
  });

  testWidgets('Should cancel deletion when cancel button is pressed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Loratadina');
    await waitForDatabase(tester);

    // Verify medication is in the list
    expect(find.text('Loratadina'), findsOneWidget);

    // Tap on the medication to open modal
    await tester.tap(find.text('Loratadina'));
    await tester.pumpAndSettle();

    // Scroll to and tap the cancel button
    await scrollToWidget(tester, find.text(getL10n(tester).btnCancel));
    await tester.tap(find.text(getL10n(tester).btnCancel));
    await tester.pumpAndSettle();

    // Verify medication is still in the list
    expect(find.text('Loratadina'), findsOneWidget);

    // Verify the modal is closed (delete button should not be visible)
    expect(find.text(getL10n(tester).medicineCabinetDeleteMedication), findsNothing);
  });

  testWidgets('Should delete correct medication when multiple medications exist', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add three medications
    await addMedicationWithDuration(tester, 'Medicamento A');
    await waitForDatabase(tester);
    await tester.pumpAndSettle(); // Wait for any overlays to clear

    await addMedicationWithDuration(tester, 'Medicamento B');
    await waitForDatabase(tester);
    await tester.pumpAndSettle(); // Wait for any overlays to clear

    await addMedicationWithDuration(tester, 'Medicamento C');
    await waitForDatabase(tester);
    await tester.pumpAndSettle(); // Wait for any overlays to clear

    // Verify all three medications are in the list
    expect(find.text('Medicamento A'), findsOneWidget);
    expect(find.text('Medicamento B'), findsOneWidget);
    expect(find.text('Medicamento C'), findsOneWidget);

    // Delete the second medication (Medicamento B)
    await tester.tap(find.text('Medicamento B'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text(getL10n(tester).medicineCabinetDeleteMedication));
    await tester.tap(find.text(getL10n(tester).medicineCabinetDeleteMedication));
    await tester.pumpAndSettle();

    // Wait for database delete operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Verify only Medicamento B was deleted
    expect(find.text('Medicamento A'), findsOneWidget);
    expect(find.text('Medicamento B'), findsNothing);
    expect(find.text('Medicamento C'), findsOneWidget);

    // Note: The deletion success SnackBar is shown in MedicineCabinetScreen
    // and disappears when we navigate back, so we can't verify it here
  });
}
