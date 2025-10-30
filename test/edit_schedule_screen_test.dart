import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_schedule_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'helpers/test_helpers.dart';
import 'helpers/medication_builder.dart';

void main() {
  setupTestDatabase();

  group('EditScheduleScreen Rendering', () {
    late Medication testMedication;

    setUp(() {
      testMedication = MedicationBuilder()
          .withId('test-med-1')
          .withMultipleDoses(['08:00', '16:00'], 1.0)
          .build();
    });

    testWidgets('should render edit schedule screen', (WidgetTester tester) async {
      await pumpScreen(tester, EditScheduleScreen(medication: testMedication));

      expect(find.text('Editar Horarios'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should display add dose button in app bar', (WidgetTester tester) async {
      await pumpScreen(tester, EditScheduleScreen(medication: testMedication));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byTooltip('Añadir toma'), findsOneWidget);
    });

    testWidgets('should display dose count in header', (WidgetTester tester) async {
      await pumpScreen(tester, EditScheduleScreen(medication: testMedication));

      expect(find.text('Tomas al día: 2'), findsOneWidget);
    });

    testWidgets('should display existing schedule times', (WidgetTester tester) async {
      await pumpScreen(tester, EditScheduleScreen(medication: testMedication));

      await tester.pumpAndSettle();

      // DoseScheduleEditor should show the times
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('16:00'), findsOneWidget);
    });
  });

  group('EditScheduleScreen Dose Management', () {
    late Medication testMedication;

    setUp(() {
      testMedication = MedicationBuilder()
          .withId('test-med-2')
          .withDosageInterval(12)
          .build();
    });

    testWidgets('should add a dose when add button is pressed', (WidgetTester tester) async {
      await pumpScreen(tester, EditScheduleScreen(medication: testMedication));

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
      final medication = MedicationBuilder()
          .withId('test-med-3')
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

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
      final medication = MedicationBuilder()
          .withId('test-med-5')
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

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
      final medication = MedicationBuilder()
          .withId('test-med-6')
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

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
      final medication = MedicationBuilder()
          .withId('test-med-7')
          .build();

      await testCancelNavigation(
        tester,
        screenTitle: 'Editar Horarios',
        screenBuilder: (context) => EditScheduleScreen(medication: medication),
      );
    });
  });

  group('EditScheduleScreen Button States', () {
    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-8')
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

      expectSaveButtonExists();
    });

    testWidgets('should have cancel button enabled initially', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-9')
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

      expectCancelButtonExists();
    });
  });

  group('EditScheduleScreen Edge Cases', () {
    testWidgets('should handle medication with single dose', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-10')
          .withName('Single Dose Medicine')
          .withType(MedicationType.syrup)
          .withDosageInterval(24)
          .withSingleDose('08:00', 5.0)
          .withStock(100.0)
          .withLowStockThreshold(5)
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

      expect(find.text('Tomas al día: 1'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('should handle medication with multiple doses', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-11')
          .withName('Multiple Dose Medicine')
          .withDosageInterval(6)
          .withMultipleDoses(['08:00', '14:00', '20:00', '02:00'], 1.0)
          .withStock(30.0)
          .withLowStockThreshold(7)
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

      expect(find.text('Tomas al día: 4'), findsOneWidget);
    });

    testWidgets('should handle medication with decimal quantities', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-12')
          .withName('Decimal Dose Medicine')
          .withDosageInterval(12)
          .withDoseSchedule({'08:00': 0.5, '20:00': 1.5})
          .withLowStockThreshold(5)
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

      expect(find.text('0.5'), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget);
    });

    testWidgets('should display medication type stock unit', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-13')
          .withType(MedicationType.inhaler)
          .withDosageInterval(12)
          .withSingleDose('08:00', 2.0)
          .withStock(10.0)
          .build();

      await pumpScreen(tester, EditScheduleScreen(medication: medication));

      // Should show the stock unit for inhaler
      expect(find.text('(${medication.type.stockUnitSingular})'), findsOneWidget);
    });
  });
}
