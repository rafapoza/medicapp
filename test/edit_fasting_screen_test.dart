import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/screens/edit_sections/edit_fasting_screen.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'helpers/test_helpers.dart';

void main() {
  setupTestDatabase();

  group('EditFastingScreen Rendering', () {
    testWidgets('should render edit fasting screen', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-1',
        requiresFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      expect(find.text('Editar Configuración de Ayuno'), findsOneWidget);
      expectSaveButtonExists();
      expectCancelButtonExists();
    });

    testWidgets('should display fasting configuration form', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-2',
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // Should render the fasting configuration form
      expect(find.text('¿Este medicamento requiere ayuno?'), findsOneWidget);
    });

    testWidgets('should initialize with no fasting', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-3',
        requiresFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // "No" button should be selected (has radio_button_checked icon)
      expect(find.text('No'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });

    testWidgets('should initialize with existing fasting configuration', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-4',
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 90, // 1 hour 30 minutes
        notifyFasting: true,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // "Sí" button should be selected
      expect(find.text('Sí'), findsOneWidget);

      // Should show duration fields with correct values (1 hour, 30 minutes)
      expect(find.text('1'), findsWidgets); // Hour field
      expect(find.text('30'), findsOneWidget); // Minutes field
    });
  });

  group('EditFastingScreen Validation', () {
    testWidgets('should allow saving when fasting is disabled', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-5',
        requiresFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // Tap save - should not show validation errors
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pump();

      // No validation error should appear
      expect(find.text('Por favor, selecciona cuándo es el ayuno'), findsNothing);
      expect(find.text('La duración del ayuno debe ser al menos 1 minuto'), findsNothing);
    });

    testWidgets('should show error when fasting type is not selected', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-6',
        requiresFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

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
      final medication = createTestMedication(
        id: 'test-med-7',
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 0,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

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
      final medication = createTestMedication(
        id: 'test-med-8',
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 60,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

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
      final medication = createTestMedication(
        id: 'test-med-9',
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

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
      final medication = createTestMedication(
        id: 'test-med-10',
        requiresFasting: false,
      );

      await testCancelNavigation(
        tester,
        screenTitle: 'Editar Configuración de Ayuno',
        screenBuilder: (context) => EditFastingScreen(medication: medication),
      );
    });
  });

  group('EditFastingScreen Button States', () {
    testWidgets('should have save button enabled initially', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-11',
        requiresFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      expectSaveButtonExists();
    });

    testWidgets('should have cancel button enabled initially', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-12',
        requiresFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      expectCancelButtonExists();
    });
  });

  group('EditFastingScreen Edge Cases', () {
    testWidgets('should handle medication with long fasting duration', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-13',
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 480, // 8 hours,
        notifyFasting: true,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // Should display 8 hours, 0 minutes
      expect(find.text('8'), findsWidgets); // Hour field
      expect(find.text('0'), findsWidgets); // Minutes field
    });

    testWidgets('should handle medication with only minutes', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-14',
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 45, // 0 hours, 45 minutes,
        notifyFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // Should display 0 hours, 45 minutes
      expect(find.text('0'), findsWidgets); // Hour field
      expect(find.text('45'), findsOneWidget); // Minutes field
    });

    testWidgets('should handle different medication types', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-15',
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 30,
        notifyFasting: true,
        type: MedicationType.syrup,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // Should render without issues
      expect(find.text('Editar Configuración de Ayuno'), findsOneWidget);
    });

    testWidgets('should handle null fasting configuration', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-16',
        requiresFasting: false,
        notifyFasting: false,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // Should render with default values (0 hours, 0 minutes)
      expect(find.text('Editar Configuración de Ayuno'), findsOneWidget);
    });

    testWidgets('should handle complex time combinations', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-17',
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 125, // 2 hours, 5 minutes,
        notifyFasting: true,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

      // Should display 2 hours, 5 minutes
      expect(find.text('2'), findsWidgets); // Hour field
      expect(find.text('5'), findsWidgets); // Minutes field
    });
  });

  group('EditFastingScreen State Management', () {
    testWidgets('should reset fasting configuration when switching off requiresFasting', (WidgetTester tester) async {
      final medication = createTestMedication(
        id: 'test-med-18',
        requiresFasting: true,
        fastingType: 'before',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await pumpScreen(tester, EditFastingScreen(medication: medication));

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
