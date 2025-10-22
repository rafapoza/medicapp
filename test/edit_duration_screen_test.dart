import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_duration_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EditDurationScreen Rendering', () {
    testWidgets('should render edit duration screen', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-1',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Editar Duración'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should display current duration type', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-2',
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
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tipo de duración'), findsOneWidget);
      expect(find.textContaining('Tipo actual:'), findsOneWidget);
    });

    testWidgets('should display info message about changing duration type', (WidgetTester tester) async {
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
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Para cambiar el tipo de duración, edita la sección de "Frecuencia"'), findsOneWidget);
    });

    testWidgets('should display date fields for everyday duration type', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-4',
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
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Fechas del tratamiento'), findsOneWidget);
      expect(find.text('Fecha de inicio'), findsOneWidget);
      expect(find.text('Fecha de fin'), findsOneWidget);
    });

    testWidgets('should display formatted dates when set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14);

      final medication = Medication(
        id: 'test-med-5',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: startDate,
        endDate: endDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show formatted dates
      expect(find.text('15/1/2025'), findsOneWidget);
      expect(find.text('14/2/2025'), findsOneWidget);
    });

    testWidgets('should display duration in days when both dates are set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14); // 31 days

      final medication = Medication(
        id: 'test-med-6',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: startDate,
        endDate: endDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show duration in days (31 days)
      expect(find.text('Duración: 31 días'), findsOneWidget);
    });

    testWidgets('should not display date fields for asNeeded duration type', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-7',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.asNeeded,
        doseSchedule: {},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should NOT show date fields for as needed medications
      expect(find.text('Fechas del tratamiento'), findsNothing);
    });
  });

  group('EditDurationScreen Validation', () {
    testWidgets('should show error when dates are not selected for everyday', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-8',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: null,
        endDate: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

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
        endDate: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

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
      final medication = Medication(
        id: 'test-med-10',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.untilFinished,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: null,
        endDate: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

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
      final medication = Medication(
        id: 'test-med-11',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.asNeeded,
        doseSchedule: {},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: null,
        endDate: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

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
      final medication = Medication(
        id: 'test-med-12',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
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
                        builder: (context) => EditDurationScreen(medication: medication),
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
      expect(find.text('Editar Duración'), findsOneWidget);

      // Scroll to cancel button
      await tester.ensureVisible(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Should be back to the original screen
      expect(find.text('Editar Duración'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('EditDurationScreen Button States', () {
    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-13',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Verify save button exists
      expect(find.text('Guardar Cambios'), findsOneWidget);
    });

    testWidgets('should have cancel button enabled initially', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-14',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Verify cancel button exists
      expect(find.text('Cancelar'), findsOneWidget);
    });
  });

  group('EditDurationScreen Edge Cases', () {
    testWidgets('should handle medication with weeklyPattern duration type', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-15',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.weeklyPattern,
        weeklyDays: [1, 3, 5],
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 60)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show date fields for weekly pattern
      expect(find.text('Fechas del tratamiento'), findsOneWidget);
    });

    testWidgets('should handle medication with intervalDays duration type', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-16',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.intervalDays,
        dayInterval: 2,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show date fields for interval days
      expect(find.text('Fechas del tratamiento'), findsOneWidget);
    });

    testWidgets('should handle medication with specificDates duration type', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-17',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.specificDates,
        selectedDates: ['2025-01-15', '2025-01-20', '2025-01-25'],
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should NOT show date fields for specific dates
      expect(find.text('Fechas del tratamiento'), findsNothing);
    });

    testWidgets('should calculate duration correctly for 1 day', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 1, 15); // Same day = 1 day

      final medication = Medication(
        id: 'test-med-18',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: startDate,
        endDate: endDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show 1 day
      expect(find.text('Duración: 1 días'), findsOneWidget);
    });

    testWidgets('should calculate duration correctly for long period', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 12, 31); // 365 days

      final medication = Medication(
        id: 'test-med-19',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: startDate,
        endDate: endDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show 365 days
      expect(find.text('Duración: 365 días'), findsOneWidget);
    });

    testWidgets('should handle different medication types', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-20',
        name: 'Test Medicine',
        type: MedicationType.jarabe,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 5.0},
        stockQuantity: 100.0,
        lowStockThresholdDays: 5,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without issues
      expect(find.text('Editar Duración'), findsOneWidget);
    });

    testWidgets('should show "No seleccionada" when dates are null', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-21',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: null,
        endDate: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "No seleccionada" for both dates
      expect(find.text('No seleccionada'), findsNWidgets(2));
    });
  });

  group('EditDurationScreen Duration Display', () {
    testWidgets('should display duration info section when both dates are set', (WidgetTester tester) async {
      final startDate = DateTime(2025, 1, 15);
      final endDate = DateTime(2025, 2, 14);

      final medication = Medication(
        id: 'test-med-22',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: startDate,
        endDate: endDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should show info icon
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });

    testWidgets('should not display duration info when only start date is set', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-23',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        endDate: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditDurationScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should NOT show duration info section
      expect(find.textContaining('Duración:'), findsNothing);
    });
  });
}
