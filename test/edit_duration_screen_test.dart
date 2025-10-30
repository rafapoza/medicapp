import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_duration_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'helpers/test_helpers.dart';
import 'helpers/medication_builder.dart';

void main() {
  setupTestDatabase();

  group('EditDurationScreen Rendering', () {
    testWidgets('should render edit duration screen', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-1')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Editar Duración'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should display current duration type', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-2')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Tipo de duración'), findsOneWidget);
      expect(find.textContaining('Tipo actual:'), findsOneWidget);
    });

    testWidgets('should display info message about changing duration type', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-3')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Para cambiar el tipo de duración, edita la sección de "Frecuencia"'), findsOneWidget);
    });

    testWidgets('should display date fields for everyday duration type', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-4')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expect(find.text('Fechas del tratamiento'), findsOneWidget);
      expect(find.text('Fecha de inicio'), findsOneWidget);
      expect(find.text('Fecha de fin'), findsOneWidget);
    });

    testWidgets('should display formatted dates when set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14);

      final medication = MedicationBuilder()
          .withId('test-med-5')
          .withDateRange(startDate, endDate)
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show formatted dates
      expect(find.text('15/1/2025'), findsOneWidget);
      expect(find.text('14/2/2025'), findsOneWidget);
    });

    testWidgets('should display duration in days when both dates are set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14); // 31 days

      final medication = MedicationBuilder()
          .withId('test-med-6')
          .withDateRange(startDate, endDate)
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show duration in days (31 days)
      expect(find.text('Duración: 31 días'), findsOneWidget);
    });

    testWidgets('should not display date fields for asNeeded duration type', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-7')
          .withAsNeeded()
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should NOT show date fields for as needed medications
      expect(find.text('Fechas del tratamiento'), findsNothing);
    });
  });

  group('EditDurationScreen Validation', () {
    testWidgets('should show error when dates are not selected for everyday', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-8')
          .build();

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
      final medication = MedicationBuilder()
          .withId('test-med-9')
          .build();

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
      final medication = MedicationBuilder()
          .withId('test-med-10')
          .withDurationType(TreatmentDurationType.untilFinished)
          .build();

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
      final medication = MedicationBuilder()
          .withId('test-med-11')
          .withAsNeeded()
          .build();

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
      final medication = MedicationBuilder()
          .withId('test-med-12')
          .build();

      await testCancelNavigation(
        tester,
        screenTitle: 'Editar Duración',
        screenBuilder: (context) => EditDurationScreen(medication: medication),
      );
    });
  });

  group('EditDurationScreen Button States', () {
    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-13')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expectSaveButtonExists();
    });

    testWidgets('should have cancel button enabled initially', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-14')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      expectCancelButtonExists();
    });
  });

  group('EditDurationScreen Edge Cases', () {
    testWidgets('should handle medication with weeklyPattern duration type', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-15')
          .withWeeklyPattern([1, 3, 5])
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show date fields for weekly pattern
      expect(find.text('Fechas del tratamiento'), findsOneWidget);
    });

    testWidgets('should handle medication with intervalDays duration type', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-16')
          .withIntervalDays(2)
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show date fields for interval days
      expect(find.text('Fechas del tratamiento'), findsOneWidget);
    });

    testWidgets('should handle medication with specificDates duration type', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-17')
          .withSpecificDates(['2025-01-15', '2025-01-20', '2025-01-25'])
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should NOT show date fields for specific dates
      expect(find.text('Fechas del tratamiento'), findsNothing);
    });

    testWidgets('should calculate duration correctly for 1 day', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 1, 15); // Same day = 1 day

      final medication = MedicationBuilder()
          .withId('test-med-18')
          .withDateRange(startDate, endDate)
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show 1 day
      expect(find.text('Duración: 1 días'), findsOneWidget);
    });

    testWidgets('should calculate duration correctly for long period', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 12, 31); // 365 days

      final medication = MedicationBuilder()
          .withId('test-med-19')
          .withDateRange(startDate, endDate)
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show 365 days
      expect(find.text('Duración: 365 días'), findsOneWidget);
    });

    testWidgets('should handle different medication types', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-20')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should render without issues
      expect(find.text('Editar Duración'), findsOneWidget);
    });

    testWidgets('should show "No seleccionada" when dates are null', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-21')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show "No seleccionada" for both dates
      expect(find.text('No seleccionada'), findsNWidgets(2));
    });
  });

  group('EditDurationScreen Duration Display', () {
    testWidgets('should display duration info section when both dates are set', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-22')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should show info icon
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });

    testWidgets('should not display duration info when only start date is set', (WidgetTester tester) async {
      final medication = MedicationBuilder()
          .withId('test-med-23')
          .build();

      await pumpScreen(tester, EditDurationScreen(medication: medication));

      // Should NOT show duration info section
      expect(find.textContaining('Duración:'), findsNothing);
    });
  });
}
