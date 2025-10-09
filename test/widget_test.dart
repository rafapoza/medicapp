import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medicapp/main.dart';

void main() {
  testWidgets('MedicApp should load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());

    // Verify that the app shows the correct title.
    expect(find.text('Mis Medicamentos'), findsOneWidget);

    // Verify that the empty state is shown.
    expect(find.text('No hay medicamentos registrados'), findsOneWidget);

    // Verify that the add button is present.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Should add medication with default type', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());

    // Tap the add button to open add medication screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify we're on the add medication screen
    expect(find.text('Añadir Medicamento'), findsOneWidget);

    // Enter medication name
    await tester.enterText(find.byType(TextFormField).first, 'Paracetamol');

    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Tap save button
    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify we're back to the list screen and medication was added
    expect(find.text('Paracetamol'), findsOneWidget);
    expect(find.text('Pastilla'), findsAtLeastNWidgets(1)); // Default type
  });

  testWidgets('Should select different medication type', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter name
    await tester.enterText(find.byType(TextFormField).first, 'Medicina X');

    // Tap on Jarabe type
    await tester.tap(find.text('Jarabe'));
    await tester.pumpAndSettle();

    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify medication was added with Jarabe type
    expect(find.text('Medicina X'), findsOneWidget);
    expect(find.text('Jarabe'), findsOneWidget);
  });

  testWidgets('Should show error when adding duplicate medication', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());

    // Add first medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Paracetamol');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Try to add the same medication again
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Paracetamol');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);
    expect(find.text('Añadir Medicamento'), findsOneWidget);
  });

  testWidgets('Duplicate validation should be case-insensitive', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedicApp());

    // Add first medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Ibuprofeno');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Try to add the same medication with different case
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'IBUPROFENO');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);
  });

  testWidgets('Should open modal when tapping a medication', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add a medication first
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Aspirina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

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

  testWidgets('Should delete medication when delete button is pressed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Omeprazol');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify medication is in the list
    expect(find.text('Omeprazol'), findsOneWidget);

    // Tap on the medication to open modal
    await tester.tap(find.text('Omeprazol'));
    await tester.pumpAndSettle();

    // Tap the delete button
    await tester.tap(find.text('Eliminar medicamento'));
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

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Loratadina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify medication is in the list
    expect(find.text('Loratadina'), findsOneWidget);

    // Tap on the medication to open modal
    await tester.tap(find.text('Loratadina'));
    await tester.pumpAndSettle();

    // Verify medication appears in both list and modal
    expect(find.text('Loratadina'), findsNWidgets(2));

    // Scroll to make the cancel button visible
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Tap the cancel button
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

    // Add first medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Medicamento A');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Add second medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Medicamento B');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Add third medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Medicamento C');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify all three medications are in the list
    expect(find.text('Medicamento A'), findsOneWidget);
    expect(find.text('Medicamento B'), findsOneWidget);
    expect(find.text('Medicamento C'), findsOneWidget);

    // Delete the second medication (Medicamento B)
    await tester.tap(find.text('Medicamento B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar medicamento'));
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

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Metformina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Tap on the medication to open modal
    await tester.tap(find.text('Metformina'));
    await tester.pumpAndSettle();

    // Verify edit button is shown
    expect(find.text('Editar medicamento'), findsOneWidget);
    expect(find.text('Eliminar medicamento'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('Should open edit screen when edit button is pressed', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Atorvastatina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Tap on the medication to open modal
    await tester.tap(find.text('Atorvastatina'));
    await tester.pumpAndSettle();

    // Tap edit button
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Verify we're on the edit screen
    expect(find.text('Editar Medicamento'), findsOneWidget);
    expect(find.text('Guardar Cambios'), findsOneWidget);

    // Verify the text field is pre-filled with the medication name
    expect(find.text('Atorvastatina'), findsOneWidget);
  });

  testWidgets('Should update medication name when changes are saved', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Simvastatina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify medication is in the list
    expect(find.text('Simvastatina'), findsOneWidget);

    // Tap on the medication to open modal
    await tester.tap(find.text('Simvastatina'));
    await tester.pumpAndSettle();

    // Tap edit button
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Clear the text field and enter new name
    await tester.enterText(find.byType(TextFormField).first, 'Rosuvastatina');

    // Save changes
    // Scroll to make button visible
    await tester.ensureVisible(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Cambios'));
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

    // Add a medication with default type (Pastilla)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Medicina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Tap on medication to open modal
    await tester.tap(find.text('Medicina'));
    await tester.pumpAndSettle();

    // Tap edit button
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Change type to Cápsula
    await tester.tap(find.text('Cápsula'));
    await tester.pumpAndSettle();

    // Save
    // Scroll to make button visible
    await tester.ensureVisible(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    // Verify type was updated - should now show Cápsula
    expect(find.text('Cápsula'), findsOneWidget);
  });

  testWidgets('Should not save when edit is cancelled', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Levotiroxina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Tap on the medication to open modal
    await tester.tap(find.text('Levotiroxina'));
    await tester.pumpAndSettle();

    // Tap edit button
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Change the name
    await tester.enterText(find.byType(TextFormField).first, 'Otro Medicamento');

    // Cancel the edit by tapping the back button in the AppBar
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // This returns us to the modal, close it by tapping outside
    await tester.tapAt(const Offset(10, 10)); // Tap outside the modal
    await tester.pumpAndSettle();

    // Verify original name is still in the list
    expect(find.text('Levotiroxina'), findsOneWidget);
    expect(find.text('Otro Medicamento'), findsNothing);
  });

  testWidgets('Should not allow duplicate names when editing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add first medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Amoxicilina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Add second medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Azitromicina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Edit the second medication
    await tester.tap(find.text('Azitromicina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Try to change it to the name of the first medication
    await tester.enterText(find.byType(TextFormField).first, 'Amoxicilina');
    // Scroll to make button visible
    await tester.ensureVisible(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);

    // Verify we're still on the edit screen
    expect(find.text('Editar Medicamento'), findsOneWidget);
  });

  testWidgets('Should allow keeping the same name when editing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Insulina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Edit the medication
    await tester.tap(find.text('Insulina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Keep the same name (just trigger save without changing anything)
    // Scroll to make button visible
    await tester.ensureVisible(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    // Verify the medication is still there with the same name
    expect(find.text('Insulina'), findsOneWidget);

    // Verify confirmation message
    expect(find.text('Insulina actualizado'), findsOneWidget);
  });

  testWidgets('Edit validation should be case-insensitive', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MedicApp());

    // Add first medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Captopril');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Add second medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Enalapril');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Edit the second medication
    await tester.tap(find.text('Enalapril'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Try to change it to the first medication's name with different case
    await tester.enterText(find.byType(TextFormField).first, 'CAPTOPRIL');
    // Scroll to make button visible
    await tester.ensureVisible(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Este medicamento ya existe en tu lista'), findsOneWidget);
  });

  testWidgets('Should add medication with default dosage interval', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter medication name
    await tester.enterText(find.byType(TextFormField).first, 'Aspirina');

    // Verify default interval is 8 hours
    expect(find.text('8'), findsOneWidget);

    // Save medication
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify medication was added and interval is shown in list
    expect(find.text('Aspirina'), findsOneWidget);
    expect(find.text('Cada 8 horas'), findsOneWidget);
  });

  testWidgets('Should add medication with custom dosage interval', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter medication name
    await tester.enterText(find.byType(TextFormField).first, 'Ibuprofeno');

    // Change interval to 6 hours
    await tester.enterText(find.byType(TextFormField).last, '6');

    // Save medication
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify medication was added with custom interval
    expect(find.text('Ibuprofeno'), findsOneWidget);
    expect(find.text('Cada 6 horas'), findsOneWidget);
  });

  testWidgets('Should show interval in modal', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Add a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Omeprazol');
    await tester.enterText(find.byType(TextFormField).last, '24');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Tap on medication to open modal
    await tester.tap(find.text('Omeprazol'));
    await tester.pumpAndSettle();

    // Verify interval is shown in modal
    expect(find.text('Cada 24 horas'), findsNWidgets(2)); // Once in list, once in modal
  });

  testWidgets('Should validate dosage interval is required', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter medication name
    await tester.enterText(find.byType(TextFormField).first, 'Paracetamol');

    // Clear the interval field
    await tester.enterText(find.byType(TextFormField).last, '');

    // Try to save
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Por favor, introduce el intervalo entre dosis'), findsOneWidget);
    expect(find.text('Añadir Medicamento'), findsOneWidget); // Still on add screen
  });

  testWidgets('Should validate dosage interval is greater than 0', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter medication name
    await tester.enterText(find.byType(TextFormField).first, 'Losartan');

    // Set interval to 0
    await tester.enterText(find.byType(TextFormField).last, '0');

    // Try to save
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('El intervalo debe ser un número mayor a 0'), findsOneWidget);
    expect(find.text('Añadir Medicamento'), findsOneWidget);
  });

  testWidgets('Should validate dosage interval is not greater than 24', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Open add screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter medication name
    await tester.enterText(find.byType(TextFormField).first, 'Metformina');

    // Set interval to 25 hours
    await tester.enterText(find.byType(TextFormField).last, '25');

    // Try to save
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('El intervalo no puede ser mayor a 24 horas'), findsOneWidget);
    expect(find.text('Añadir Medicamento'), findsOneWidget);
  });

  testWidgets('Should update dosage interval when editing', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());

    // Add a medication with 8 hour interval
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Amoxicilina');
    // Scroll to make the save button visible
    await tester.ensureVisible(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Medicamento'));
    await tester.pumpAndSettle();

    // Verify initial interval
    expect(find.text('Cada 8 horas'), findsOneWidget);

    // Open edit screen
    await tester.tap(find.text('Amoxicilina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar medicamento'));
    await tester.pumpAndSettle();

    // Change interval to 12 hours
    await tester.enterText(find.byType(TextFormField).last, '12');

    // Save changes
    // Scroll to make button visible
    await tester.ensureVisible(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Cambios'));
    await tester.pumpAndSettle();

    // Verify interval was updated
    expect(find.text('Cada 12 horas'), findsOneWidget);
  });
}
