import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:medicapp/main.dart';
import 'package:medicapp/database/database_helper.dart';

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
Future<void> addMedicationWithDuration(
  WidgetTester tester,
  String name, {
  String? type,
  String? durationType,
  String? customDays,
}) async {
  // Tap the add button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Enter medication name
  await tester.enterText(find.byType(TextFormField).first, name);
  await tester.pumpAndSettle();

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

  // Scroll to and tap continue button to save the medication
  await scrollToWidget(tester, find.text('Continuar'));
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();

  // Wait for database save operation to complete
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump();
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

  testWidgets('Should add medication with default type and everyday duration', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());

    // Wait for database to load
    await waitForDatabase(tester);

    // Add medication with default values
    await addMedicationWithDuration(tester, 'Paracetamol');

    // Verify we're back to the list screen and medication was added
    expect(find.text('Paracetamol'), findsOneWidget);
    expect(find.text('Pastilla'), findsAtLeastNWidgets(1)); // Default type
    expect(find.text('Todos los días'), findsAtLeastNWidgets(1)); // Default duration
  });

  testWidgets('Should navigate to treatment duration screen after entering medication info', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter name
    await tester.enterText(find.byType(TextFormField), 'Ibuprofeno');

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

  testWidgets('Should add medication with "Hasta acabar la medicación" duration', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add medication with "until finished" duration
    await addMedicationWithDuration(
      tester,
      'Antibiótico',
      durationType: 'Hasta acabar la medicación',
    );

    // Verify medication was added with correct duration
    expect(find.text('Antibiótico'), findsOneWidget);
    expect(find.text('Hasta acabar'), findsOneWidget);
  });

  testWidgets('Should add medication with custom duration', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add medication with custom duration
    await addMedicationWithDuration(
      tester,
      'Tratamiento Corto',
      durationType: 'Personalizado',
      customDays: '7',
    );

    // Verify medication was added with correct duration
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

    // Try to add the same medication again
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Paracetamol');
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

    // Try to add the same medication with different case
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'IBUPROFENO');
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
    await addMedicationWithDuration(tester, 'Medicamento B');
    await addMedicationWithDuration(tester, 'Medicamento C');

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

    // Continue to save
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

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

    // Continue to save
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Verify type was updated - should now show Cápsula
    expect(find.text('Cápsula'), findsOneWidget);
  });

  testWidgets('Should update medication duration when editing', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication with "Todos los días" duration
    await addMedicationWithDuration(tester, 'Vitaminas');

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

    // Save changes
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

    // Verify duration was updated
    expect(find.text('15 días'), findsOneWidget);
  });

  testWidgets('Should not save when edit is cancelled', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add a medication
    await addMedicationWithDuration(tester, 'Levotiroxina');

    // Tap on the medication to open modal
    await tester.tap(find.text('Levotiroxina'));
    await tester.pumpAndSettle();

    // Scroll to and tap edit button
    await scrollToWidget(tester, find.text('Editar medicamento'));
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Change the name
    await tester.enterText(find.byType(TextFormField).first, 'Otro Medicamento');

    // Cancel the edit
    await scrollToWidget(tester, find.text('Cancelar').first);
    await tester.tap(find.text('Cancelar').first);
    await tester.pumpAndSettle();

    // Close the modal that's still open
    await scrollToWidget(tester, find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Verify original name is still in the list
    expect(find.text('Levotiroxina'), findsOneWidget);
    expect(find.text('Otro Medicamento'), findsNothing);
  });

  testWidgets('Should not allow duplicate names when editing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Add two medications
    await addMedicationWithDuration(tester, 'Amoxicilina');
    await addMedicationWithDuration(tester, 'Azitromicina');

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

    // Continue to save
    await scrollToWidget(tester, find.text('Continuar').first);
    await tester.tap(find.text('Continuar').first);
    await tester.pumpAndSettle();

    // Wait for database update operation to complete
    await waitForDatabase(tester);

    // Additional pump to ensure modal is fully closed
    await tester.pumpAndSettle();

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
    await addMedicationWithDuration(tester, 'Enalapril');

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
    await tester.enterText(find.byType(TextFormField), 'TestMed');
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
