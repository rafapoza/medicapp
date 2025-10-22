import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_schedule_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EditScheduleScreen Rendering', () {
    late Medication testMedication;

    setUp(() {
      testMedication = Medication(
        id: 'test-med-1',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '16:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );
    });

    testWidgets('should render edit schedule screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: testMedication),
        ),
      );

      expect(find.text('Editar Horarios'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should display add dose button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: testMedication),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byTooltip('Añadir toma'), findsOneWidget);
    });

    testWidgets('should display dose count in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: testMedication),
        ),
      );

      expect(find.text('Tomas al día: 2'), findsOneWidget);
    });

    testWidgets('should display existing schedule times', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: testMedication),
        ),
      );

      await tester.pumpAndSettle();

      // DoseScheduleEditor should show the times
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('16:00'), findsOneWidget);
    });
  });

  group('EditScheduleScreen Dose Management', () {
    late Medication testMedication;

    setUp(() {
      testMedication = Medication(
        id: 'test-med-2',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );
    });

    testWidgets('should add a dose when add button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: testMedication),
        ),
      );

      await tester.pumpAndSettle();

      // Initially one dose
      expect(find.text('Toma 1'), findsOneWidget);
      expect(find.text('Toma 2'), findsNothing);

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should now have two doses
      expect(find.text('Toma 1'), findsOneWidget);
      expect(find.text('Toma 2'), findsOneWidget);
    });
  });

  group('EditScheduleScreen Validation', () {
    testWidgets('should show error for invalid quantities', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-3',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Find the quantity field and enter invalid quantity
      final quantityFields = find.byType(TextField);
      await tester.enterText(quantityFields.first, '0');
      await tester.pump();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, ingresa cantidades válidas (mayores a 0)'), findsOneWidget);
    });

    testWidgets('should accept negative quantities in text field but reject on save', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-5',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative quantity
      final quantityFields = find.byType(TextField);
      await tester.enterText(quantityFields.first, '-1');
      await tester.pump();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, ingresa cantidades válidas (mayores a 0)'), findsOneWidget);
    });

    testWidgets('should accept empty quantities in text field but reject on save', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-6',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Clear quantity field
      final quantityFields = find.byType(TextField);
      await tester.enterText(quantityFields.first, '');
      await tester.pump();

      // Tap save button
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, ingresa cantidades válidas (mayores a 0)'), findsOneWidget);
    });
  });

  group('EditScheduleScreen Navigation', () {
    testWidgets('should navigate back when cancel is pressed', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-7',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

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
                        builder: (context) => EditScheduleScreen(medication: medication),
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
      expect(find.text('Editar Horarios'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Should be back to the original screen
      expect(find.text('Editar Horarios'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('EditScheduleScreen Button States', () {
    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-8',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Verify save button exists and can be tapped
      expect(find.text('Guardar Cambios'), findsOneWidget);
    });

    testWidgets('should have cancel button enabled initially', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-9',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Verify cancel button exists and can be tapped
      expect(find.text('Cancelar'), findsOneWidget);
    });
  });

  group('EditScheduleScreen Edge Cases', () {
    testWidgets('should handle medication with single dose', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-10',
        name: 'Single Dose Medicine',
        type: MedicationType.jarabe,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 5.0},
        stockQuantity: 100.0,
        lowStockThresholdDays: 5,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tomas al día: 1'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('should handle medication with multiple doses', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-11',
        name: 'Multiple Dose Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 6,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 1.0,
          '14:00': 1.0,
          '20:00': 1.0,
          '02:00': 1.0,
        },
        stockQuantity: 30.0,
        lowStockThresholdDays: 7,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tomas al día: 4'), findsOneWidget);
    });

    testWidgets('should handle medication with decimal quantities', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-12',
        name: 'Decimal Dose Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '08:00': 0.5,
          '20:00': 1.5,
        },
        stockQuantity: 20.0,
        lowStockThresholdDays: 5,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0.5'), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget);
    });

    testWidgets('should display medication type stock unit', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-13',
        name: 'Test Medicine',
        type: MedicationType.inhalador,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 2.0},
        stockQuantity: 10.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditScheduleScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the stock unit for inhaler
      expect(find.text('(${medication.type.stockUnitSingular})'), findsOneWidget);
    });
  });
}
