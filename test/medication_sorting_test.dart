import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/utils/medication_sorter.dart';

void main() {
  group('Medication Sorting', () {
    test('should sort pending doses first (most overdue first)', () {
      final now = DateTime(2025, 10, 16, 15, 0); // 3:00 PM
      final today = '2025-10-16';

      // Medication A: pending dose at 14:00 (1 hour overdue)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'14:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication B: pending dose at 13:00 (2 hours overdue)
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'13:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication C: future dose at 16:00 (1 hour ahead)
      final medC = Medication(
        id: 'med_c',
        name: 'Medication C',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'16:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final medications = [medC, medA, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B should be first (most overdue), then A, then C
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_a');
      expect(medications[2].id, 'med_c');
    });

    test('should sort future doses by proximity', () {
      final now = DateTime(2025, 10, 16, 10, 0); // 10:00 AM
      final today = '2025-10-16';

      // Medication A: dose at 16:00 (6 hours ahead)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'16:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication B: dose at 11:00 (1 hour ahead)
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'11:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication C: dose at 12:00 (2 hours ahead)
      final medC = Medication(
        id: 'med_c',
        name: 'Medication C',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'12:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final medications = [medA, medC, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B (11:00) should be first, then C (12:00), then A (16:00)
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_c');
      expect(medications[2].id, 'med_a');
    });

    test('should place medications without next dose at the end', () {
      final now = DateTime(2025, 10, 16, 15, 0);
      final today = '2025-10-16';

      // Medication A: has future dose
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'16:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication B: no dose times configured
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication C: all doses already taken
      final medC = Medication(
        id: 'med_c',
        name: 'Medication C',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'14:00': 1.0},
        takenDosesToday: ['14:00'],
        takenDosesDate: today,
      );

      final medications = [medB, medA, medC];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // A should be first (has future dose), B and C at the end (no next dose)
      expect(medications[0].id, 'med_a');
      // B and C can be in any order, but should be at the end
      expect([medications[1].id, medications[2].id], containsAll(['med_b', 'med_c']));
    });

    test('should prioritize pending over future doses', () {
      final now = DateTime(2025, 10, 16, 15, 0);
      final today = '2025-10-16';

      // Medication A: pending dose (overdue)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'14:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication B: future dose (very close, in 5 minutes)
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'15:05': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final medications = [medB, medA];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // A (pending) should be first, even though B is closer in absolute time
      expect(medications[0].id, 'med_a');
      expect(medications[1].id, 'med_b');
    });

    test('should handle medications with multiple doses (find next available)', () {
      final now = DateTime(2025, 10, 16, 12, 0);
      final today = '2025-10-16';

      // Medication A: has doses at 08:00 (taken), 12:00 (pending), 18:00 (future)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 6,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'08:00': 1.0, '12:00': 1.0, '18:00': 1.0},
        takenDosesToday: ['08:00'],
        takenDosesDate: today,
      );

      // Medication B: has dose at 13:00 (future, 1 hour ahead)
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'13:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final medications = [medB, medA];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // A (pending at 12:00) should be first
      expect(medications[0].id, 'med_a');
      expect(medications[1].id, 'med_b');
    });

    test('should handle weekly pattern medications', () {
      final now = DateTime(2025, 10, 16, 10, 0); // Thursday
      final todayString = '2025-10-16';

      // Medication A: weekly on Monday, Wednesday, Friday (next is Friday)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.weeklyPattern,
        doseSchedule: {'08:00': 1.0},
        weeklyDays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
        takenDosesToday: [],
        takenDosesDate: todayString,
      );

      // Medication B: everyday with dose at 11:00 (1 hour ahead today)
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'11:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: todayString,
      );

      final medications = [medA, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B (today at 11:00) should be first, A (Friday) should be second
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_a');
    });

    test('should get correct next dose DateTime', () {
      final now = DateTime(2025, 10, 16, 10, 0);
      final today = '2025-10-16';

      final medication = Medication(
        id: 'med_test',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'14:30': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final nextDose = MedicationSorter.getNextDoseDateTime(medication, now);

      expect(nextDose, isNotNull);
      expect(nextDose!.year, 2025);
      expect(nextDose.month, 10);
      expect(nextDose.day, 16);
      expect(nextDose.hour, 14);
      expect(nextDose.minute, 30);
    });

    test('should return null for medication without doses', () {
      final now = DateTime(2025, 10, 16, 10, 0);
      final today = '2025-10-16';

      final medication = Medication(
        id: 'med_test',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final nextDose = MedicationSorter.getNextDoseDateTime(medication, now);

      expect(nextDose, isNull);
    });
  });
}
