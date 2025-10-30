import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/notification_service.dart';
import 'package:medicapp/screens/dose_action_screen.dart';
import 'package:medicapp/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseHelper.setInMemoryDatabase(true);
    await DatabaseHelper.resetDatabase();
    NotificationService.instance.enableTestMode();
  });

  tearDown(() async {
    await DatabaseHelper.resetDatabase();
  });

  Widget createTestApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('DoseActionScreen - Loading and Error States', () {
    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      // Create medication
      final medication = Medication(
        id: 'med1',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Build the screen
      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med1',
            doseTime: '08:00',
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error when medication not found', (WidgetTester tester) async {
      // Build the screen with non-existent medication
      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'nonexistent',
            doseTime: '08:00',
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Should show error icon and message
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Medicamento no encontrado'), findsOneWidget);
      expect(find.text('Volver'), findsOneWidget);
    });

    testWidgets('should navigate back when pressing back button in error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'nonexistent',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();

      // Should have popped the screen
      expect(find.byType(DoseActionScreen), findsNothing);
    });
  });

  group('DoseActionScreen - UI Rendering', () {
    testWidgets('should render all action buttons when medication loaded', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med2',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med2',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show medication name
      expect(find.text('Test Med'), findsOneWidget);

      // Should show all action buttons
      expect(find.text('Registrar toma'), findsOneWidget);
      expect(find.text('No tomada'), findsOneWidget);
      expect(find.text('Posponer 15 min'), findsOneWidget);
      expect(find.text('Posponer'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should show dose time in header', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med3',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'14:30': 1.5},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med3',
            doseTime: '14:30',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the specific dose time
      expect(find.textContaining('14:30'), findsOneWidget);
    });
  });

  group('DoseActionScreen - Register Taken Dose', () {
    testWidgets('should register taken dose and show success message', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med4',
        name: 'Paracetamol',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med4',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Registrar toma" button
      await tester.tap(find.text('Registrar toma'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Paracetamol'), findsOneWidget);
      expect(find.textContaining('08:00'), findsOneWidget);

      // Verify medication was updated in database
      final updatedMed = await DatabaseHelper.instance.getMedication('med4');
      expect(updatedMed!.stockQuantity, 9.0);
      expect(updatedMed.takenDosesToday, ['08:00']);
    });

    testWidgets('should show error when insufficient stock', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med5',
        name: 'Low Stock Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 5.0}, // Needs 5 pills
        stockQuantity: 2.0, // Only has 2 pills
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med5',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Registrar toma" button
      await tester.tap(find.text('Registrar toma'));
      await tester.pumpAndSettle();

      // Should show error snackbar about insufficient stock
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Stock insuficiente'), findsOneWidget);
      expect(find.textContaining('5'), findsOneWidget); // Needed quantity
      expect(find.textContaining('2'), findsOneWidget); // Available stock

      // Stock should remain unchanged
      final updatedMed = await DatabaseHelper.instance.getMedication('med5');
      expect(updatedMed!.stockQuantity, 2.0);
    });

    testWidgets('should navigate back after successful registration', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med6',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med6',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Registrar toma" button
      await tester.tap(find.text('Registrar toma'));
      await tester.pumpAndSettle();

      // Should have navigated back
      expect(find.byType(DoseActionScreen), findsNothing);
    });
  });

  group('DoseActionScreen - Register Skipped Dose', () {
    testWidgets('should register skipped dose without reducing stock', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med7',
        name: 'Skipped Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med7',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "No tomada" button
      await tester.tap(find.text('No tomada'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Skipped Med'), findsOneWidget);
      expect(find.textContaining('no tomada'), findsOneWidget);

      // Verify medication was updated in database
      final updatedMed = await DatabaseHelper.instance.getMedication('med7');
      expect(updatedMed!.stockQuantity, 10.0); // Stock unchanged
      expect(updatedMed.skippedDosesToday, ['08:00']);
    });

    testWidgets('should navigate back after skipping dose', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med8',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med8',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "No tomada" button
      await tester.tap(find.text('No tomada'));
      await tester.pumpAndSettle();

      // Should have navigated back
      expect(find.byType(DoseActionScreen), findsNothing);
    });
  });

  group('DoseActionScreen - Postpone Dose', () {
    testWidgets('should show success message when postponing 15 minutes', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med9',
        name: 'Postponed Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med9',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Posponer 15 min" button
      await tester.tap(find.text('Posponer 15 min'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Postponed Med'), findsOneWidget);
      expect(find.textContaining('pospuesta'), findsOneWidget);
    });

    testWidgets('should navigate back after postponing 15 minutes', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med10',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med10',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Posponer 15 min" button
      await tester.tap(find.text('Posponer 15 min'));
      await tester.pumpAndSettle();

      // Should have navigated back
      expect(find.byType(DoseActionScreen), findsNothing);
    });

    testWidgets('should show time picker when tapping custom postpone', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med11',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med11',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Posponer" button (custom time)
      await tester.tap(find.text('Posponer').last); // Last one is custom postpone
      await tester.pumpAndSettle();

      // Should show time picker dialog
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('should cancel postpone when dismissing time picker', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med12',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med12',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Posponer" button
      await tester.tap(find.text('Posponer').last);
      await tester.pumpAndSettle();

      // Dismiss time picker
      await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
      await tester.pumpAndSettle();

      // Should still be on DoseActionScreen
      expect(find.byType(DoseActionScreen), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('DoseActionScreen - Cancel Button', () {
    testWidgets('should navigate back when pressing cancel', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med13',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med13',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Should have navigated back without changes
      expect(find.byType(DoseActionScreen), findsNothing);

      // Verify no changes were made
      final reloadedMed = await DatabaseHelper.instance.getMedication('med13');
      expect(reloadedMed!.stockQuantity, 10.0);
      expect(reloadedMed.takenDosesToday, isEmpty);
      expect(reloadedMed.skippedDosesToday, isEmpty);
    });
  });

  group('DoseActionScreen - Different Medication Types', () {
    testWidgets('should work with injection type medication', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med14',
        name: 'Insulin',
        type: MedicationType.injection,
        dosageIntervalHours: 12,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 10.0}, // 10 mL
        stockQuantity: 50.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med14',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Insulin'), findsOneWidget);

      // Register taken
      await tester.tap(find.text('Registrar toma'));
      await tester.pumpAndSettle();

      // Verify stock reduced
      final updatedMed = await DatabaseHelper.instance.getMedication('med14');
      expect(updatedMed!.stockQuantity, 40.0);
    });

    testWidgets('should work with spray type medication', (WidgetTester tester) async {
      final medication = Medication(
        id: 'med15',
        name: 'Nasal Spray',
        type: MedicationType.spray,
        dosageIntervalHours: 6,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 2.0}, // 2 sprays
        stockQuantity: 20.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await tester.pumpWidget(
        createTestApp(
          const DoseActionScreen(
            medicationId: 'med15',
            doseTime: '08:00',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nasal Spray'), findsOneWidget);

      // Register taken
      await tester.tap(find.text('Registrar toma'));
      await tester.pumpAndSettle();

      // Verify stock reduced
      final updatedMed = await DatabaseHelper.instance.getMedication('med15');
      expect(updatedMed!.stockQuantity, 18.0);
    });
  });
}
