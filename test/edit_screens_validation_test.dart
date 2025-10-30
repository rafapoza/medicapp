import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_quantity_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'helpers/test_helpers.dart';
import 'helpers/medication_builder.dart';

void main() {
  setupTestDatabase();

  group('EditQuantityScreen Validation', () {
    late Medication testMedication;

    setUp(() {
      testMedication = MedicationBuilder()
          .withId('test-med-1')
          .withStock(20.0)
          .withLowStockThreshold(3)
          .build();
    });

    testWidgets('should render edit quantity screen', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      expect(find.text('Editar Cantidad'), findsOneWidget);
      expect(find.text('Cantidad disponible'), findsOneWidget);
      expect(find.text('Avisar cuando queden'), findsOneWidget);
    });

    testWidgets('should initialize with current stock quantity', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Find the stock quantity field
      final stockField = find.widgetWithText(TextFormField, '20.0');
      expect(stockField, findsOneWidget);
    });

    testWidgets('should initialize with current threshold days', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Find the threshold field
      final thresholdField = find.widgetWithText(TextFormField, '3');
      expect(thresholdField, findsOneWidget);
    });

    testWidgets('should show error for empty stock quantity', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Clear stock field and try to save
      final stockField = find.widgetWithText(TextFormField, '20.0');
      await tester.enterText(stockField, '');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Por favor, introduce la cantidad disponible'), findsOneWidget);
    });

    testWidgets('should show error for negative stock quantity', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Enter negative value
      final stockField = find.widgetWithText(TextFormField, '20.0');
      await tester.enterText(stockField, '-5');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('La cantidad debe ser mayor o igual a 0'), findsOneWidget);
    });

    testWidgets('should accept zero stock quantity', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Enter zero value - should be valid
      final stockField = find.widgetWithText(TextFormField, '20.0');
      await tester.enterText(stockField, '0');
      await tester.pump();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump(); // Just trigger validation, don't wait for save

      // Should not show stock quantity validation error
      expect(find.text('La cantidad debe ser mayor o igual a 0'), findsNothing);
    });

    testWidgets('should show error for empty threshold days', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Clear threshold field
      final thresholdFields = find.byType(TextFormField);
      await tester.enterText(thresholdFields.at(1), '');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Por favor, introduce los días de antelación'), findsOneWidget);
    });

    testWidgets('should show error for threshold less than 1 day', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Enter invalid value
      final thresholdFields = find.byType(TextFormField);
      await tester.enterText(thresholdFields.at(1), '0');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Debe ser al menos 1 día'), findsOneWidget);
    });

    testWidgets('should show error for threshold greater than 30 days', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Enter invalid value
      final thresholdFields = find.byType(TextFormField);
      await tester.enterText(thresholdFields.at(1), '31');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('No puede ser mayor a 30 días'), findsOneWidget);
    });

    testWidgets('should accept valid threshold values (1-30)', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Test a valid value within range
      final thresholdFields = find.byType(TextFormField);
      await tester.enterText(thresholdFields.at(1), '15');
      await tester.pumpAndSettle();

      // Tap save button - this will try to save but we just check no validation errors appear
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump(); // Just one pump to trigger validation

      // Should not show validation errors for threshold
      expect(find.text('Debe ser al menos 1 día'), findsNothing);
      expect(find.text('No puede ser mayor a 30 días'), findsNothing);
    });

    testWidgets('should show cancel button', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      expectCancelButtonExists();
    });

    testWidgets('should navigate back when cancel is pressed', (WidgetTester tester) async {
      await testCancelNavigation(
        tester,
        screenTitle: 'Editar Cantidad',
        screenBuilder: (context) => EditQuantityScreen(medication: testMedication),
      );
    });

    testWidgets('should display medication type stock unit', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Should show the stock unit for pills
      expect(find.text('(${testMedication.type.stockUnit})'), findsOneWidget);
    });

    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      expectSaveButtonExists();
    });
  });

  group('EditQuantityScreen Input Parsing', () {
    late Medication testMedication;

    setUp(() {
      testMedication = MedicationBuilder()
          .withId('test-med-2')
          .withName('Test Medicine 2')
          .withType(MedicationType.capsule)
          .withDosageInterval(12)
          .withDoseSchedule({'08:00': 1.0, '20:00': 1.0})
          .withStock(50.5)
          .withLowStockThreshold(5)
          .build();
    });

    testWidgets('should accept decimal stock quantities', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Enter decimal value
      final stockField = find.byType(TextFormField).first;
      await tester.enterText(stockField, '15.5');
      await tester.pump();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump(); // Just trigger validation, don't wait for save

      // Should not show validation error
      expect(find.text('La cantidad debe ser mayor o igual a 0'), findsNothing);
    });

    testWidgets('should handle invalid number format gracefully', (WidgetTester tester) async {
      await pumpScreen(tester, EditQuantityScreen(medication: testMedication));

      // Enter invalid format
      final stockField = find.byType(TextFormField).first;
      await tester.enterText(stockField, 'abc');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Should show validation error (tryParse returns null, treated as invalid)
      expect(find.text('La cantidad debe ser mayor o igual a 0'), findsOneWidget);
    });
  });

  group('EditQuantityScreen Edge Cases', () {
    testWidgets('should handle medication with large stock quantity', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-3')
          .withName('Test Medicine 3')
          .withType(MedicationType.syrup)
          .withDoseSchedule({'08:00': 5.0})
          .withStock(999.99)
          .withLowStockThreshold(10)
          .build();

      await pumpScreen(tester, EditQuantityScreen(medication: medication));

      expect(find.text('999.99'), findsOneWidget);
    });

    testWidgets('should handle medication with threshold at boundaries', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-4')
          .withName('Test Medicine 4')
          .withType(MedicationType.inhaler)
          .withDosageInterval(12)
          .withDoseSchedule({'08:00': 2.0})
          .withStock(10.0)
          .withLowStockThreshold(1) // Minimum valid value
          .build();

      await pumpScreen(tester, EditQuantityScreen(medication: medication));

      expect(find.text('1'), findsOneWidget);
    });
  });
}
