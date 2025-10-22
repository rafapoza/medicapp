import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_duration_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/test_helpers.dart';

void main() {
  setupTestDatabase();

  group('EditDurationScreen Rendering', () {
    testWidgets('should render edit duration screen', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-1',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Editar Duración'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should display current duration type', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-2',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Tipo de duración'), findsOneWidget);
      expect(find.textContaining('Tipo actual:'), findsOneWidget);
    });

    testWidgets('should display info message about changing duration type', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-3',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Para cambiar el tipo de duración, edita la sección de "Frecuencia"'), findsOneWidget);
    });

    testWidgets('should display date fields for everyday duration type', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-4',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Fechas del tratamiento'), findsOneWidget);
      expect(find.text('Fecha de inicio'), findsOneWidget);
      expect(find.text('Fecha de fin'), findsOneWidget);
    });

    testWidgets('should display formatted dates when set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14);

      final medication = createTestMedication(
        id: 'test-med-5',
        startDate: startDate,
        endDate: endDate,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show formatted dates
      expect(find.text('15/1/2025'), findsOneWidget);
      expect(find.text('14/2/2025'), findsOneWidget);
    });

    testWidgets('should display duration in days when both dates are set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14); // 31 days

      final medication = createTestMedication(
        id: 'test-med-6',
        startDate: startDate,
        endDate: endDate,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show duration in days (31 days)
      expect(find.text('Duración: 31 días'), findsOneWidget);
    });

    testWidgets('should not display date fields for asNeeded duration type', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-7',
        durationType: TreatmentDurationType.asNeeded,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should NOT show date fields for as needed medications
      expect(find.text('Fechas del tratamiento'), findsNothing);
    });
  });

  group('EditDurationScreen Validation', () {
    testWidgets('should show error when dates are not selected for everyday', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-8',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save without dates
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, selecciona las fechas de inicio y fin'), findsOneWidget);
    });

    testWidgets('should show error when only start date is selected', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-9',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save with only start date
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, selecciona las fechas de inicio y fin'), findsOneWidget);
    });

    testWidgets('should show error for untilFinished without dates', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-10',
        durationType: TreatmentDurationType.untilFinished,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save without dates
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, selecciona las fechas de inicio y fin'), findsOneWidget);
    });

    testWidgets('should not require dates for asNeeded', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-11',
        durationType: TreatmentDurationType.asNeeded,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save - should not show error
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should NOT show validation error
      expect(find.text('Por favor, selecciona las fechas de inicio y fin'), findsNothing);
    });
  });

  group('EditDurationScreen Navigation', () {
    testWidgets('should navigate back when cancel is pressed', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-12',
      );

      await testCancelNavigation(
        tester,
        screenTitle: 'Editar Duración',
        screenBuilder: (context) => EditDurationScreen(medication: medication),
      );
    });
  });

  group('EditDurationScreen Button States', () {
    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-13',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expectSaveButtonExists();
    });

    testWidgets('should have cancel button enabled initially', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-14',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expectCancelButtonExists();
    });
  });

  group('EditDurationScreen Edge Cases', () {
    testWidgets('should handle medication with weeklyPattern duration type', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-15',
        durationType: TreatmentDurationType.weeklyPattern,
        weeklyDays: [1, 3, 5],
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show date fields for weekly pattern
      expect(find.text('Fechas del tratamiento'), findsOneWidget);
    });

    testWidgets('should handle medication with intervalDays duration type', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-16',
        durationType: TreatmentDurationType.intervalDays,
        dayInterval: 2,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show date fields for interval days
      expect(find.text('Fechas del tratamiento'), findsOneWidget);
    });

    testWidgets('should handle medication with specificDates duration type', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-17',
        durationType: TreatmentDurationType.specificDates,
        selectedDates: ['2025-01-15', '2025-01-20', '2025-01-25'],
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should NOT show date fields for specific dates
      expect(find.text('Fechas del tratamiento'), findsNothing);
    });

    testWidgets('should calculate duration correctly for 1 day', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 1, 15); // Same day = 1 day

      final medication = createTestMedication(
        id: 'test-med-18',
        startDate: startDate,
        endDate: endDate,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show 1 day
      expect(find.text('Duración: 1 días'), findsOneWidget);
    });

    testWidgets('should calculate duration correctly for long period', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 12, 31); // 365 days

      final medication = createTestMedication(
        id: 'test-med-19',
        startDate: startDate,
        endDate: endDate,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show 365 days
      expect(find.text('Duración: 365 días'), findsOneWidget);
    });

    testWidgets('should handle different medication types', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-20',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should render without issues
      expect(find.text('Editar Duración'), findsOneWidget);
    });

    testWidgets('should show "No seleccionada" when dates are null', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-21',
        startDate: null,
        endDate: null,
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show "No seleccionada" for both dates
      expect(find.text('No seleccionada'), findsNWidgets(2));
    });
  });

  group('EditDurationScreen Duration Display', () {
    testWidgets('should display duration info section when both dates are set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14);

      final medication = createTestMedication(
        id: 'test-med-22',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show info icon
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });

    testWidgets('should not display duration info when only start date is set', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-23',
      );

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should NOT show duration info section
      expect(find.textContaining('Duración:'), findsNothing);
    });
  });
}
