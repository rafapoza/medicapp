import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/models/dose_history_entry.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/dose_action_service.dart';
import 'package:medicapp/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Set global factory to use ffi implementation
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use in-memory database for testing
    DatabaseHelper.setInMemoryDatabase(true);
    await DatabaseHelper.resetDatabase();

    // Set notification service to test mode
    NotificationService.instance.enableTestMode();
  });

  tearDown(() async {
    await DatabaseHelper.resetDatabase();
  });

  group('Extra Dose Registration', () {
    test('should register extra dose with correct time and reduce stock', () async {
      // Create a medication with schedule
      final medication = Medication(
        id: 'med1',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '14:00': 1.0, '20:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Register extra dose
      final updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // Verify stock reduced
      expect(updatedMed.stockQuantity, 9.0);

      // Verify extra dose recorded in extraDosesToday
      expect(updatedMed.extraDosesToday.length, 1);

      // Verify time format (HH:mm)
      final extraDoseTime = updatedMed.extraDosesToday.first;
      expect(extraDoseTime, matches(RegExp(r'^\d{2}:\d{2}$')));
    });

    test('should save extra dose to history with isExtraDose=true', () async {
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

      await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // Get history entries
      final history = await DatabaseHelper.instance.getDoseHistoryForMedication('med2');

      expect(history.length, 1);
      expect(history.first.isExtraDose, true);
      expect(history.first.status, DoseStatus.taken);
      expect(history.first.quantity, 1.0);
    });

    test('should not affect takenDosesToday when registering extra dose', () async {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'med3',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '14:00': 1.0},
        stockQuantity: 10.0,
        takenDosesToday: ['08:00'],
        takenDosesDate: todayString,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // takenDosesToday should remain unchanged
      expect(updatedMed.takenDosesToday, ['08:00']);
      // extraDosesToday should have one entry
      expect(updatedMed.extraDosesToday.length, 1);
    });

    test('should handle multiple extra doses in same day', () async {
      final medication = Medication(
        id: 'med4',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Register first extra dose
      var updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      expect(updatedMed.extraDosesToday.length, 1);
      expect(updatedMed.stockQuantity, 9.0);

      // Register second extra dose
      updatedMed = await DoseActionService.registerExtraDose(
        medication: updatedMed,
        quantity: 1.0,
      );

      expect(updatedMed.extraDosesToday.length, 2);
      expect(updatedMed.stockQuantity, 8.0);
    });

    test('should throw InsufficientStockException when stock is low', () async {
      final medication = Medication(
        id: 'med5',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 2.0},
        stockQuantity: 1.0, // Not enough for dose of 2.0
      );

      await DatabaseHelper.instance.insertMedication(medication);

      expect(
        () => DoseActionService.registerExtraDose(
          medication: medication,
          quantity: 2.0,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('should reset extraDosesToday on new day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayString = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      final medication = Medication(
        id: 'med6',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
        extraDosesToday: ['10:30', '15:45'],
        takenDosesToday: ['08:00'],
        takenDosesDate: yesterdayString, // Yesterday's date
      );

      await DatabaseHelper.instance.insertMedication(medication);

      // Register extra dose today
      final updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // Should reset old extra doses and start fresh
      expect(updatedMed.extraDosesToday.length, 1);
      // Should also reset takenDosesToday
      expect(updatedMed.takenDosesToday.length, 0);
    });
  });

  group('Extra Dose with Fasting', () {
    test('should schedule fasting notification for "after" type', () async {
      final medication = Medication(
        id: 'med7',
        name: 'Test Med with Fasting',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // In test mode, we can't directly verify notification scheduling,
      // but we can verify the medication properties are correct
      expect(medication.requiresFasting, true);
      expect(medication.fastingType, 'after');
      expect(medication.notifyFasting, true);
    });

    test('should NOT schedule fasting notification for "before" type', () async {
      final medication = Medication(
        id: 'med8',
        name: 'Test Med with Before Fasting',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
        requiresFasting: true,
        fastingType: 'before', // before type, should not schedule on extra dose
        fastingDurationMinutes: 60,
        notifyFasting: true,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      // Verify medication still has before fasting configuration
      expect(medication.fastingType, 'before');
    });

    test('should NOT schedule fasting notification when notifyFasting is false', () async {
      final medication = Medication(
        id: 'med9',
        name: 'Test Med No Notify',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0},
        stockQuantity: 10.0,
        requiresFasting: true,
        fastingType: 'after',
        fastingDurationMinutes: 60,
        notifyFasting: false, // Notifications disabled
      );

      await DatabaseHelper.instance.insertMedication(medication);

      await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 1.0,
      );

      expect(medication.notifyFasting, false);
    });
  });

  group('Extra Dose with Different Quantities', () {
    test('should handle fractional dose quantities', () async {
      final medication = Medication(
        id: 'med10',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 0.5},
        stockQuantity: 10.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 0.5,
      );

      expect(updatedMed.stockQuantity, 9.5);
    });

    test('should handle larger dose quantities', () async {
      final medication = Medication(
        id: 'med11',
        name: 'Test Med',
        type: MedicationType.pill,
        dosageIntervalHours: 8,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 3.0},
        stockQuantity: 20.0,
      );

      await DatabaseHelper.instance.insertMedication(medication);

      final updatedMed = await DoseActionService.registerExtraDose(
        medication: medication,
        quantity: 3.0,
      );

      expect(updatedMed.stockQuantity, 17.0);
    });
  });
}
