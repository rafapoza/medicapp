import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_quantity_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EditQuantityScreen Validation', () {
    late Medication testMedication;

    setUp(() {
      testMedication = Medication(
        id: 'test-med-1',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );
    });

    testWidgets('should render edit quantity screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

      expect(find.text('Editar Cantidad'), findsOneWidget);
      expect(find.text('Cantidad disponible'), findsOneWidget);
      expect(find.text('Avisar cuando queden'), findsOneWidget);
    });

    testWidgets('should initialize with current stock quantity', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

      // Find the stock quantity field
      final stockField = find.widgetWithText(TextFormField, '20.0');
      expect(stockField, findsOneWidget);
    });

    testWidgets('should initialize with current threshold days', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

      // Find the threshold field
      final thresholdField = find.widgetWithText(TextFormField, '3');
      expect(thresholdField, findsOneWidget);
    });

    testWidgets('should show error for empty stock quantity', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should navigate back when cancel is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditQuantityScreen(medication: testMedication),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the edit screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify we're on the edit screen
      expect(find.text('Editar Cantidad'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Should be back to the original screen
      expect(find.text('Editar Cantidad'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('should display medication type stock unit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

      // Should show the stock unit for pills
      expect(find.text('(${testMedication.type.stockUnit})'), findsOneWidget);
    });

    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

      // Verify save button exists
      expect(find.text('Guardar Cambios'), findsOneWidget);
    });
  });

  group('EditQuantityScreen Input Parsing', () {
    late Medication testMedication;

    setUp(() {
      testMedication = Medication(
        id: 'test-med-2',
        name: 'Test Medicine 2',
        type: MedicationType.capsula,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '20:00': 1.0},
        stockQuantity: 50.5,
        lowStockThresholdDays: 5,
        startDate: DateTime.now(),
      );
    });

    testWidgets('should accept decimal stock quantities', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: testMedication),
        ),
      );

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
      final medication = Medication(
        id: 'test-med-3',
        name: 'Test Medicine 3',
        type: MedicationType.jarabe,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 5.0},
        stockQuantity: 999.99,
        lowStockThresholdDays: 10,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: medication),
        ),
      );

      expect(find.text('999.99'), findsOneWidget);
    });

    testWidgets('should handle medication with threshold at boundaries', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-4',
        name: 'Test Medicine 4',
        type: MedicationType.inhalador,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 2.0},
        stockQuantity: 10.0,
        lowStockThresholdDays: 1, // Minimum valid value
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditQuantityScreen(medication: medication),
        ),
      );

      expect(find.text('1'), findsOneWidget);
    });
  });
}
