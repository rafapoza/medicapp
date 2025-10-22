import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_fasting_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EditFastingScreen Rendering', () {
    testWidgets('should render edit fasting screen', (WidgetTester tester) async {
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
        requiresFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Editar Configuración de Ayuno'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should display fasting configuration form', (WidgetTester tester) async {
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
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should render the fasting configuration form
      expect(find.text('¿Este medicamento requiere ayuno?'), findsOneWidget);
    });

    testWidgets('should initialize with no fasting', (WidgetTester tester) async {
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
        requiresFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // "No" button should be selected (has radio_button_checked icon)
      expect(find.text('No'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });

    testWidgets('should initialize with existing fasting configuration', (WidgetTester tester) async {
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
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 90, // 1 hour 30 minutes
        notifyFasting: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // "Sí" button should be selected
      expect(find.text('Sí'), findsOneWidget);

      // Should show duration fields with correct values (1 hour, 30 minutes)
      expect(find.text('1'), findsWidgets); // Hour field
      expect(find.text('30'), findsOneWidget); // Minutes field
    });
  });

  group('EditFastingScreen Validation', () {
    testWidgets('should allow saving when fasting is disabled', (WidgetTester tester) async {
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
        requiresFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save - should not show validation errors
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // No validation error should appear
      expect(find.text('Por favor, selecciona cuándo es el ayuno'), findsNothing);
      expect(find.text('La duración del ayuno debe ser al menos 1 minuto'), findsNothing);
    });

    testWidgets('should show error when fasting type is not selected', (WidgetTester tester) async {
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
        requiresFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Enable fasting by tapping "Sí" button
      await tester.tap(find.text('Sí'));
      await tester.pumpAndSettle();

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save without selecting fasting type
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, selecciona cuándo es el ayuno'), findsOneWidget);
    });

    testWidgets('should show error when duration is zero', (WidgetTester tester) async {
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
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save with zero duration
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('La duración del ayuno debe ser al menos 1 minuto'), findsOneWidget);
    });

    testWidgets('should show error when hours and minutes are both empty', (WidgetTester tester) async {
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
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Clear hour and minute fields
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '0'); // Hours
      await tester.enterText(textFields.at(1), '0'); // Minutes
      await tester.pump();

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should show validation error
      expect(find.text('La duración del ayuno debe ser al menos 1 minuto'), findsOneWidget);
    });

    testWidgets('should accept minimum valid duration (1 minute)', (WidgetTester tester) async {
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
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Set minimum duration (0 hours, 1 minute)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '0'); // Hours
      await tester.enterText(textFields.at(1), '1'); // Minutes
      await tester.pump();

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should NOT show validation error
      expect(find.text('La duración del ayuno debe ser al menos 1 minuto'), findsNothing);
    });
  });

  group('EditFastingScreen Navigation', () {
    testWidgets('should navigate back when cancel is pressed', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-10',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        requiresFasting: false,
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
                        builder: (context) => EditFastingScreen(medication: medication),
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
      expect(find.text('Editar Configuración de Ayuno'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Should be back to the original screen
      expect(find.text('Editar Configuración de Ayuno'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('EditFastingScreen Button States', () {
    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-11',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        requiresFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Verify save button exists
      expect(find.text('Guardar Cambios'), findsOneWidget);
    });

    testWidgets('should have cancel button enabled initially', (WidgetTester tester) async {
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
        requiresFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Verify cancel button exists
      expect(find.text('Cancelar'), findsOneWidget);
    });
  });

  group('EditFastingScreen Edge Cases', () {
    testWidgets('should handle medication with long fasting duration', (WidgetTester tester) async {
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
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 480, // 8 hours
        notifyFasting: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should display 8 hours, 0 minutes
      expect(find.text('8'), findsWidgets); // Hour field
      expect(find.text('0'), findsWidgets); // Minutes field
    });

    testWidgets('should handle medication with only minutes', (WidgetTester tester) async {
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
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 45, // 0 hours, 45 minutes
        notifyFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should display 0 hours, 45 minutes
      expect(find.text('0'), findsWidgets); // Hour field
      expect(find.text('45'), findsOneWidget); // Minutes field
    });

    testWidgets('should handle different medication types', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-15',
        name: 'Test Medicine',
        type: MedicationType.jarabe,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 5.0},
        stockQuantity: 100.0,
        lowStockThresholdDays: 5,
        startDate: DateTime.now(),
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 30,
        notifyFasting: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without issues
      expect(find.text('Editar Configuración de Ayuno'), findsOneWidget);
    });

    testWidgets('should handle null fasting configuration', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-16',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        requiresFasting: false,
        fastingType: null,
        fastingDurationMinutes: null,
        notifyFasting: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should render with default values (0 hours, 0 minutes)
      expect(find.text('Editar Configuración de Ayuno'), findsOneWidget);
    });

    testWidgets('should handle complex time combinations', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-17',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 125, // 2 hours, 5 minutes
        notifyFasting: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // Should display 2 hours, 5 minutes
      expect(find.text('2'), findsWidgets); // Hour field
      expect(find.text('5'), findsWidgets); // Minutes field
    });
  });

  group('EditFastingScreen State Management', () {
    testWidgets('should reset fasting configuration when switching off requiresFasting', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-med-18',
        name: 'Test Medicine',
        type: MedicationType.pastilla,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 20.0,
        lowStockThresholdDays: 3,
        startDate: DateTime.now(),
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditFastingScreen(medication: medication),
        ),
      );

      await tester.pumpAndSettle();

      // "Sí" button should be selected initially
      expect(find.text('Sí'), findsOneWidget);

      // Turn off fasting by tapping "No" button
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      // Scroll to save button
      await tester.ensureVisible(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Now try to save - should not require validation
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // Should NOT show validation errors
      expect(find.text('Por favor, selecciona cuándo es el ayuno'), findsNothing);
    });
  });
}
