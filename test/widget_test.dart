import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:medicapp/main.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/notification_service.dart';

// Helper function to wait for database operations to complete
Future<void> waitForDatabase(WidgetTester tester) async {
  // Use runAsync to allow async operations to complete
  await tester.runAsync(() async {
    // Give time for database operations
    await Future.delayed(const Duration(milliseconds: 100));
  });

  // Pump frames to rebuild UI after async operations
  await tester.pump();
  await tester.pump();
}

// Helper function to scroll to a widget if needed
Future<void> scrollToWidget(WidgetTester tester, Finder finder) async {
  final scrollView = find.byType(SingleChildScrollView);
  if (scrollView.evaluate().isNotEmpty) {
    try {
      await tester.dragUntilVisible(
        finder,
        scrollView.first,
        const Offset(0, -50),
      );
    } catch (e) {
      // If dragUntilVisible fails, try manual scroll
      await tester.drag(scrollView.first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
  }
}

// Helper function to add a medication through the complete flow
// Note: This uses MedicationScheduleScreen's autoFillForTesting mode to avoid
// complex time picker interactions during automated testing
Future<void> addMedicationWithDuration(
  WidgetTester tester,
  String name, {
  String? type,
  String? durationType,
  String? customDays,
  int dosageIntervalHours = 8, // Default to 8 hours
}) async {
  // Tap the add button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Enter medication name
  await tester.enterText(find.byType(TextFormField).first, name);
  await tester.pumpAndSettle();

  // Enter dosage interval if different from default
  if (dosageIntervalHours != 8) {
    final dosageFields = find.byType(TextFormField);
    if (dosageFields.evaluate().length >= 2) {
      await tester.enterText(dosageFields.at(1), dosageIntervalHours.toString());
      await tester.pumpAndSettle();
    }
  }

  // Select type if specified
  if (type != null) {
    await tester.tap(find.text(type));
    await tester.pumpAndSettle();
  }

  // Scroll to and tap continue button to go to duration screen
  await scrollToWidget(tester, find.text('Continuar'));
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();

  // Select duration type (default to "Todos los días" if not specified)
  if (durationType != null) {
    await tester.tap(find.text(durationType));
    await tester.pumpAndSettle();

    // If custom, enter the number of days
    if (durationType == 'Personalizado' && customDays != null) {
      await tester.enterText(find.byType(TextFormField).first, customDays);
      await tester.pumpAndSettle();
    }
  }

  // Scroll to and tap continue button to go to schedule screen
  await scrollToWidget(tester, find.text('Continuar'));
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();

  // Now we're on the medication schedule screen
  // The screen will auto-fill times in testing mode
  // Just verify we're there and save
  expect(find.text('Horario de tomas'), findsOneWidget);

  // Wait a moment for auto-fill to complete
  await tester.pump(const Duration(milliseconds: 100));

  // Scroll to and tap save schedule button
  await scrollToWidget(tester, find.text('Guardar horario'));
  await tester.tap(find.text('Guardar horario'));
  await tester.pumpAndSettle();

  // Wait for database save operation and notification scheduling to complete
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 200));
  });

  // Pump multiple times to ensure all async operations and UI updates complete
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

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
    // Close and reset the database to get a fresh in-memory instance
    await DatabaseHelper.resetDatabase();
    // Enable in-memory mode for this test
    DatabaseHelper.setInMemoryDatabase(true);
    // Enable test mode for notifications (disables actual notifications)
    NotificationService.instance.enableTestMode();
  });

  testWidgets('MedicApp should load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());

    // Initial pump to let initState run
    await tester.pump();

    // Wait for database operations to complete
    await waitForDatabase(tester);

    // Verify that the app shows the correct title.
    expect(find.text('Mis Medicamentos'), findsOneWidget);

    // Verify that the empty state is shown.
    expect(find.text('No hay medicamentos registrados'), findsOneWidget);

    // Verify that the add button is present.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });


  testWidgets('Should navigate to treatment duration screen after entering medication info', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter name (use .first to get the name field, not the frequency field)
    await tester.enterText(find.byType(TextFormField).first, 'Ibuprofeno');

    // Scroll to and tap continue
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verify we're on the treatment duration screen
    expect(find.text('Duración del tratamiento'), findsOneWidget);
    expect(find.text('¿Cuántos días vas a tomar este medicamento?'), findsOneWidget);
    expect(find.text('Todos los días'), findsOneWidget);
    expect(find.text('Hasta acabar la medicación'), findsOneWidget);
    expect(find.text('Personalizado'), findsOneWidget);
  });

  testWidgets('Should add medication with default type and everyday duration', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);
    await addMedicationWithDuration(tester, 'Paracetamol');

    // Wait for the main screen to complete its async operations after Navigator.pop
    await waitForDatabase(tester);

    expect(find.text('Paracetamol'), findsOneWidget);
    expect(find.text('Pastilla'), findsAtLeastNWidgets(1));
    expect(find.text('Todos los días'), findsAtLeastNWidgets(1));
  });

  testWidgets('Should add medication with "Hasta acabar la medicación" duration', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);
    await addMedicationWithDuration(
      tester,
      'Antibiótico',
      durationType: 'Hasta acabar la medicación',
    );
    await waitForDatabase(tester);

    expect(find.text('Antibiótico'), findsOneWidget);
    expect(find.text('Hasta acabar'), findsOneWidget);
  });

  testWidgets('Should add medication with custom duration', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);
    await addMedicationWithDuration(
      tester,
      'Tratamiento Corto',
      durationType: 'Personalizado',
      customDays: '7',
    );
    await waitForDatabase(tester);

    expect(find.text('Tratamiento Corto'), findsOneWidget);
    expect(find.text('7 días'), findsOneWidget);
  });

  testWidgets('Should validate custom days input', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Start adding medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Test Med');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Select custom duration
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();

    // Try to continue without entering days
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Por favor, introduce el número de días'), findsOneWidget);
  });

  testWidgets('Should not allow custom days greater than 365', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Start adding medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Test Med');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Select custom duration and enter invalid number
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '400');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('El número de días no puede ser mayor a 365'), findsOneWidget);
  });

  testWidgets('Should not allow custom days less than or equal to 0', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Start adding medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Test Med');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Select custom duration and enter invalid number
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '0');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('El número de días debe ser mayor a 0'), findsOneWidget);
  });

  testWidgets('Should select different medication type', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add medication with Jarabe type
    await addMedicationWithDuration(tester, 'Medicina X', type: 'Jarabe');
    await waitForDatabase(tester);

    // Verify medication was added with Jarabe type
    expect(find.text('Medicina X'), findsOneWidget);
    expect(find.text('Jarabe'), findsOneWidget);
  });

  testWidgets('Should show error when adding duplicate medication', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add first medication
    await addMedicationWithDuration(tester, 'Paracetamol');
    await waitForDatabase(tester);

    // Try to add the same medication again
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Paracetamol');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);
    expect(find.text('Añadir Medicamento'), findsOneWidget);
  });

  testWidgets('Duplicate validation should be case-insensitive', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add first medication
    await addMedicationWithDuration(tester, 'Ibuprofeno');
    await waitForDatabase(tester);

    // Try to add the same medication with different case
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'IBUPROFENO');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);
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
    expect(find.text('Eliminar medicamento'), findsOneWidget);
    expect(find.text('Editar medicamento'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    // The medication name should appear twice: once in the list and once in the modal
    expect(find.text('Aspirina'), findsNWidgets(2));
  });

  testWidgets('Modal should display treatment duration', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with custom duration
    await addMedicationWithDuration(
      tester,
      'Vitamina C',
      durationType: 'Personalizado',
      customDays: '30',
    );
    await waitForDatabase(tester);

    // Tap on the medication to open modal
    await tester.tap(find.text('Vitamina C'));
    await tester.pumpAndSettle();

    // Verify duration is displayed in modal
    expect(find.text('30 días'), findsNWidgets(2)); // Once in list, once in modal
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
    await scrollToWidget(tester, find.text('Eliminar medicamento'));
    await tester.tap(find.text('Eliminar medicamento'));
    await tester.pumpAndSettle();

    // Wait for database delete operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Verify medication is no longer in the list
    expect(find.text('Omeprazol'), findsNothing);

    // Verify confirmation message is shown
    expect(find.text('Omeprazol eliminado'), findsOneWidget);

    // Verify empty state is shown
    expect(find.text('No hay medicamentos registrados'), findsOneWidget);
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
    await scrollToWidget(tester, find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Verify medication is still in the list
    expect(find.text('Loratadina'), findsOneWidget);

    // Verify the modal is closed (delete button should not be visible)
    expect(find.text('Eliminar medicamento'), findsNothing);
  });

  testWidgets('Should delete correct medication when multiple medications exist', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add three medications
    await addMedicationWithDuration(tester, 'Medicamento A');
    await waitForDatabase(tester);
    await addMedicationWithDuration(tester, 'Medicamento B');
    await waitForDatabase(tester);
    await addMedicationWithDuration(tester, 'Medicamento C');
    await waitForDatabase(tester);

    // Verify all three medications are in the list
    expect(find.text('Medicamento A'), findsOneWidget);
    expect(find.text('Medicamento B'), findsOneWidget);
    expect(find.text('Medicamento C'), findsOneWidget);

    // Delete the second medication (Medicamento B)
    await tester.tap(find.text('Medicamento B'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text('Eliminar medicamento'));
    await tester.tap(find.text('Eliminar medicamento'));
    await tester.pumpAndSettle();

    // Wait for database delete operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Verify only Medicamento B was deleted
    expect(find.text('Medicamento A'), findsOneWidget);
    expect(find.text('Medicamento B'), findsNothing);
    expect(find.text('Medicamento C'), findsOneWidget);

    // Verify confirmation message
    expect(find.text('Medicamento B eliminado'), findsOneWidget);
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
    expect(find.text('Editar medicamento'), findsOneWidget);
    expect(find.text('Eliminar medicamento'), findsOneWidget);
  });

  testWidgets('Should open edit screen when edit button is pressed', (WidgetTester tester) async {
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
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Verify we're on the edit screen
    expect(find.text('Editar Medicamento'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget); // Edit screen has Continuar button

    // Verify the text field is pre-filled with the medication name
    expect(find.text('Atorvastatina'), findsOneWidget);
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

    // Tap on the medication to open modal
    await tester.tap(find.text('Simvastatina'));
    await tester.pumpAndSettle();

    // Scroll to and tap edit button
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Clear the text field and enter new name
    await tester.enterText(find.byType(TextFormField).first, 'Rosuvastatina');

    // Continue to duration screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Continue to schedule screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Save schedule (times should already be filled from original medication)
    await scrollToWidget(tester, find.text('Guardar horario'));
    await tester.tap(find.text('Guardar horario'));
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify old name is gone and new name is in the list
    expect(find.text('Simvastatina'), findsNothing);
    expect(find.text('Rosuvastatina'), findsOneWidget);

    // Verify confirmation message
    expect(find.text('Rosuvastatina actualizado'), findsOneWidget);
  });

  testWidgets('Should update medication type when editing', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with default type (Pastilla)
    await addMedicationWithDuration(tester, 'Medicina');
    await waitForDatabase(tester);

    // Tap on medication to open modal
    await tester.tap(find.text('Medicina'));
    await tester.pumpAndSettle();

    // Scroll to and tap edit button
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Change type to Cápsula
    await tester.tap(find.text('Cápsula'));
    await tester.pumpAndSettle();

    // Continue to duration screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Continue to schedule screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Save schedule
    await scrollToWidget(tester, find.text('Guardar horario'));
    await tester.tap(find.text('Guardar horario'));
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify type was updated - should now show Cápsula
    expect(find.text('Cápsula'), findsOneWidget);
  });

  testWidgets('Should update medication duration when editing', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with "Todos los días" duration
    await addMedicationWithDuration(tester, 'Vitaminas');
    await waitForDatabase(tester);

    // Verify initial duration
    expect(find.text('Todos los días'), findsAtLeastNWidgets(1));

    // Edit the medication
    await tester.tap(find.text('Vitaminas'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Continue to duration screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Change duration to custom
    await tester.tap(find.text('Personalizado'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '15');
    await tester.pumpAndSettle();

    // Continue to schedule screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Save schedule
    await scrollToWidget(tester, find.text('Guardar horario'));
    await tester.tap(find.text('Guardar horario'));
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify duration was updated
    expect(find.text('15 días'), findsOneWidget);
  });

  testWidgets('Should not save when edit is cancelled', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Levotiroxina');
    await waitForDatabase(tester);

    // Tap on the medication to open modal
    await tester.tap(find.text('Levotiroxina'));
    await tester.pumpAndSettle();

    // Scroll to and tap edit button (this will close the modal and navigate to edit screen)
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Change the name
    await tester.enterText(find.byType(TextFormField).first, 'Otro Medicamento');

    // Cancel the edit (this returns directly to the main list, modal was already closed)
    await scrollToWidget(tester, find.text('Cancelar').first);
    await tester.tap(find.text('Cancelar').first);
    await tester.pumpAndSettle();

    // Verify we're back on the main screen and original name is still in the list
    expect(find.text('Levotiroxina'), findsOneWidget);
    expect(find.text('Otro Medicamento'), findsNothing);

    // Verify we're on the main screen (no edit screen elements visible)
    expect(find.text('Editar Medicamento'), findsNothing);
  });

  testWidgets('Should not allow duplicate names when editing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add two medications
    await addMedicationWithDuration(tester, 'Amoxicilina');
    await waitForDatabase(tester);
    await addMedicationWithDuration(tester, 'Azitromicina');
    await waitForDatabase(tester);

    // Edit the second medication
    await tester.tap(find.text('Azitromicina'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Try to change it to the name of the first medication
    await tester.enterText(find.byType(TextFormField).first, 'Amoxicilina');
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);

    // Verify we're still on the edit screen
    expect(find.text('Editar Medicamento'), findsOneWidget);
  });

  testWidgets('Should allow keeping the same name when editing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Insulina');
    await waitForDatabase(tester);

    // Edit the medication
    await tester.tap(find.text('Insulina'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Keep the same name and continue to duration screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Continue to schedule screen
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Save schedule
    await scrollToWidget(tester, find.text('Guardar horario'));
    await tester.tap(find.text('Guardar horario'));
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Wait for main screen to complete its async operations (reload from DB)
    await waitForDatabase(tester);

    // Verify the medication is still there with the same name
    expect(find.text('Insulina'), findsOneWidget);

    // Verify confirmation message
    expect(find.text('Insulina actualizado'), findsOneWidget);
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

    // Edit the second medication
    await tester.tap(find.text('Enalapril'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Try to change it to the first medication's name with different case
    await tester.enterText(find.byType(TextFormField).first, 'CAPTOPRIL');
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);
  });

  testWidgets('Edit screen should preserve existing duration values', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with custom duration
    await addMedicationWithDuration(
      tester,
      'Probiótico',
      durationType: 'Personalizado',
      customDays: '21',
    );
    await waitForDatabase(tester);

    // Edit the medication
    await tester.tap(find.text('Probiótico'));
    await tester.pumpAndSettle();
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Continue to duration screen without changing name
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Verify the duration screen shows the existing values
    // The Personalizado option should be selected
    expect(find.text('Personalizado'), findsOneWidget);
    // The text field should show '21'
    expect(find.text('21'), findsOneWidget);
  });

  testWidgets('Should cancel adding medication from duration screen', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Start adding a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'TestMed');
    await scrollToWidget(tester, find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Cancel from duration screen
    await tester.tap(find.text('Cancelar').first);
    await tester.pumpAndSettle();

    // Verify we're back on the add medication screen
    expect(find.text('Añadir Medicamento'), findsOneWidget);
  });
}
