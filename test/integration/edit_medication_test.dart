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

  testWidgets('Should show edit button in modal', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Metformina');
    await waitForDatabase(tester);

    // Tap on the medication to open modal
    await tester.tap(find.text('Metformina'));
    await tester.pumpAndSettle();

    // Verify edit button is shown
    expect(find.text(getL10n(tester).medicineCabinetEditMedication), findsWidgets);
    expect(find.text(getL10n(tester).medicineCabinetDeleteMedication), findsWidgets);
  });

  testWidgets('Should open edit menu when edit button is pressed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Atorvastatina');
    await waitForDatabase(tester);

    // Tap on the medication to open modal
    await tester.tap(find.text('Atorvastatina'));
    await tester.pumpAndSettle();

    // Scroll to and tap edit button
    await scrollToWidget(tester, find.text(getL10n(tester).medicineCabinetEditMedication));
    await tester.tap(find.text(getL10n(tester).medicineCabinetEditMedication));
    await tester.pumpAndSettle();

    // Verify we're on the edit MENU (not a form)
    expect(find.text(getL10n(tester).editMedicationMenuTitle), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuWhatToEdit), findsWidgets);

    // Verify all 5 editing options are shown
    expect(find.text(getL10n(tester).editMedicationMenuBasicInfo), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuDuration), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuFrequency), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuSchedules), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuQuantity), findsWidgets);

    // Verify the medication name appears in the header
    expect(find.text('Atorvastatina'), findsAtLeastNWidgets(1));
  });

  testWidgets('Should update medication name when changes are saved', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Simvastatina');
    await waitForDatabase(tester);

    // Verify medication is in the list
    expect(find.text('Simvastatina'), findsOneWidget);

    // Navigate to edit menu and select "Información Básica"
    await openEditMenuAndSelectSection(tester, 'Simvastatina', 'Información Básica');

    // Verify we're on the basic info edit screen
    expect(find.text(getL10n(tester).editBasicInfoTitle), findsWidgets);

    // Clear the text field and enter new name
    await tester.enterText(find.byType(TextFormField).first, 'Rosuvastatina');
    await tester.pumpAndSettle();

    // Save changes immediately (new modular flow - no need to continue through other screens)
    await scrollToWidget(tester, find.text(getL10n(tester).editBasicInfoSaveChanges));
    await tester.tap(find.text(getL10n(tester).editBasicInfoSaveChanges));

    // Wait for save operation to start
    await tester.pump();

    // Wait for database update operation to complete
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await tester.pump();
    await tester.pump();
    await waitForDatabase(tester);

    // Additional pump to ensure navigation is complete
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify old name is gone and new name is in the list
    expect(find.text('Simvastatina'), findsNothing);
    expect(find.text('Rosuvastatina'), findsOneWidget);

    // Verify confirmation message
    expect(find.text(getL10n(tester).editBasicInfoUpdated), findsWidgets);
  });

  testWidgets('Should update medication type when editing', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with default type (Pastilla)
    await addMedicationWithDuration(tester, 'Medicina');
    await waitForDatabase(tester);

    // Navigate to edit menu and select "Información Básica"
    await openEditMenuAndSelectSection(tester, 'Medicina', 'Información Básica');

    // Verify we're on the basic info edit screen
    expect(find.text(getL10n(tester).editBasicInfoTitle), findsWidgets);

    // Change type to Cápsula
    await scrollToWidget(tester, find.text(getL10n(tester).medicationTypeCapsule));
    await tester.tap(find.text(getL10n(tester).medicationTypeCapsule));
    await tester.pumpAndSettle();

    // Save changes immediately (new modular flow)
    await scrollToWidget(tester, find.text(getL10n(tester).editBasicInfoSaveChanges));
    await tester.tap(find.text(getL10n(tester).editBasicInfoSaveChanges));

    // Wait for save operation to start
    await tester.pump();

    // Wait for database update operation to complete
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await tester.pump();
    await tester.pump();
    await waitForDatabase(tester);

    // Additional pump to ensure navigation is complete
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify type was updated - should now show Cápsula
    expect(find.text(getL10n(tester).medicationTypeCapsule), findsWidgets);
  });

  testWidgets('Should update medication frequency when editing', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with "Todos los días" frequency
    await addMedicationWithDuration(tester, 'Vitaminas');
    await waitForDatabase(tester);

    // Verify initial frequency
    expect(find.text(getL10n(tester).frequencyDailyTitle), findsAtLeastNWidgets(1));

    // Navigate to edit menu and select "Frecuencia"
    await openEditMenuAndSelectSection(tester, 'Vitaminas', 'Frecuencia');

    // Verify we're on the frequency edit screen
    expect(find.text(getL10n(tester).editFrequencyTitle), findsWidgets);

    // Change frequency to "Hasta acabar medicación"
    await scrollToWidget(tester, find.text(getL10n(tester).editFrequencyUntilFinished));
    await tester.tap(find.text(getL10n(tester).editFrequencyUntilFinished));
    await tester.pumpAndSettle();

    // Save changes immediately (new modular flow)
    await scrollToWidget(tester, find.text(getL10n(tester).editBasicInfoSaveChanges));
    await tester.tap(find.text(getL10n(tester).editBasicInfoSaveChanges));

    // Wait for save operation to start
    await tester.pump();

    // Wait for database update operation to complete
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await tester.pump();
    await tester.pump();
    await waitForDatabase(tester);

    // Additional pump to ensure navigation is complete
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify frequency was updated (short version "Hasta acabar")
    expect(find.text(getL10n(tester).editFrequencyUntilFinished), findsWidgets);
  });

  testWidgets('Should not save when edit is cancelled', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Levotiroxina');
    await waitForDatabase(tester);

    // Navigate to edit menu and select "Información Básica"
    await openEditMenuAndSelectSection(tester, 'Levotiroxina', 'Información Básica');

    // Verify we're on the basic info edit screen
    expect(find.text(getL10n(tester).editBasicInfoTitle), findsWidgets);

    // Change the name
    await tester.enterText(find.byType(TextFormField).first, 'Otro Medicamento');
    await tester.pumpAndSettle();

    // Cancel the edit (this returns to the edit menu, not the main screen)
    await scrollToWidget(tester, find.text(getL10n(tester).btnCancel));
    await tester.tap(find.text(getL10n(tester).btnCancel));
    await tester.pumpAndSettle();

    // Verify we're back on the edit menu
    expect(find.text(getL10n(tester).editMedicationMenuTitle), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuWhatToEdit), findsWidgets);

    // Tap the back button in the AppBar to go back to main screen
    // Use the arrow_back icon to find the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify we're back on the main screen and original name is still in the list
    expect(find.text('Levotiroxina'), findsOneWidget);
    expect(find.text('Otro Medicamento'), findsNothing);

    // Verify edit menu is no longer visible
    expect(find.text(getL10n(tester).editMedicationMenuTitle), findsNothing);
  });

  testWidgets('Should not allow duplicate names when editing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add two medications
    await addMedicationWithDuration(tester, 'Amoxicilina');
    await waitForDatabase(tester);
    await tester.pumpAndSettle(); // Wait for any overlays to clear
    // Extra delay to ensure SnackBar is completely gone
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    await addMedicationWithDuration(tester, 'Azitromicina');
    await waitForDatabase(tester);
    await tester.pumpAndSettle(); // Wait for any overlays to clear

    // Navigate to edit menu and select "Información Básica"
    await openEditMenuAndSelectSection(tester, 'Azitromicina', 'Información Básica');

    // Verify we're on the basic info edit screen
    expect(find.text(getL10n(tester).editBasicInfoTitle), findsWidgets);

    // Try to change it to the name of the first medication
    await tester.enterText(find.byType(TextFormField).first, 'Amoxicilina');
    await tester.pumpAndSettle();

    // Try to save
    await scrollToWidget(tester, find.text(getL10n(tester).editBasicInfoSaveChanges));
    await tester.tap(find.text(getL10n(tester).editBasicInfoSaveChanges));

    // Wait for validation to run
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify error message is shown
    expect(find.text(getL10n(tester).validationDuplicateMedication), findsWidgets);

    // Verify we're still on the edit screen
    expect(find.text(getL10n(tester).editBasicInfoTitle), findsWidgets);
  });

  testWidgets('Should allow keeping the same name when editing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Insulina');
    await waitForDatabase(tester);

    // Navigate to edit menu and select "Información Básica"
    await openEditMenuAndSelectSection(tester, 'Insulina', 'Información Básica');

    // Verify we're on the basic info edit screen
    expect(find.text(getL10n(tester).editBasicInfoTitle), findsWidgets);

    // Keep the same name (don't change text field) and save
    await scrollToWidget(tester, find.text(getL10n(tester).editBasicInfoSaveChanges));
    await tester.tap(find.text(getL10n(tester).editBasicInfoSaveChanges));

    // Wait for save operation to start
    await tester.pump();

    // Wait for database update operation to complete
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await tester.pump();
    await tester.pump();
    await waitForDatabase(tester);

    // Additional pump to ensure navigation is complete
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify the medication is still there with the same name
    expect(find.text('Insulina'), findsOneWidget);

    // Verify confirmation message
    expect(find.text(getL10n(tester).editBasicInfoUpdated), findsWidgets);
  });

  testWidgets('Edit validation should be case-insensitive', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add two medications
    await addMedicationWithDuration(tester, 'Captopril');
    await waitForDatabase(tester);
    await addMedicationWithDuration(tester, 'Enalapril');
    await waitForDatabase(tester);

    // Navigate to edit menu and select "Información Básica"
    await openEditMenuAndSelectSection(tester, 'Enalapril', 'Información Básica');

    // Verify we're on the basic info edit screen
    expect(find.text(getL10n(tester).editBasicInfoTitle), findsWidgets);

    // Try to change it to the first medication's name with different case
    await tester.enterText(find.byType(TextFormField).first, 'CAPTOPRIL');
    await tester.pumpAndSettle();

    // Try to save
    await scrollToWidget(tester, find.text(getL10n(tester).editBasicInfoSaveChanges));
    await tester.tap(find.text(getL10n(tester).editBasicInfoSaveChanges));

    // Wait for validation to run
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify error message is shown
    expect(find.text(getL10n(tester).validationDuplicateMedication), findsWidgets);
  });

  testWidgets('Edit menu should show current frequency values', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with "Hasta acabar" frequency
    await addMedicationWithDuration(
      tester,
      'Probiótico',
      durationType: getL10n(tester).durationUntilEmptyTitle,
    );
    await waitForDatabase(tester);

    // Open edit menu
    await tester.tap(find.text('Probiótico'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text(getL10n(tester).medicineCabinetEditMedication));
    await tester.tap(find.text(getL10n(tester).medicineCabinetEditMedication));
    await tester.pumpAndSettle();

    // Verify we're on the edit menu
    expect(find.text(getL10n(tester).editMedicationMenuTitle), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuWhatToEdit), findsWidgets);

    // Verify the frequency option shows current value (subtitle shows full text)
    expect(find.text(getL10n(tester).editMedicationMenuFrequency), findsWidgets);
    expect(find.text(getL10n(tester).editMedicationMenuFreqUntilFinished), findsWidgets);
  });
}
