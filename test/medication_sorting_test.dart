import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/utils/medication_sorter.dart';

void main() {
  group('Medication Sorting', () {
    test('should sort pending doses first (most overdue first)', () {
      // Use real current time since Medication model uses DateTime.now()
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Calculate times: 2 hours ago, 1 hour ago, 1 hour ahead
      final twoHoursAgo = ((currentHour - 2) % 24).clamp(0, 23);
      final oneHourAgo = ((currentHour - 1) % 24).clamp(0, 23);
      final oneHourAhead = (currentHour + 1) % 24;

      // Medication A: pending dose (1 hour overdue)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${oneHourAgo.toString().padLeft(2, '0')}:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication B: pending dose (2 hours overdue)
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${twoHoursAgo.toString().padLeft(2, '0')}:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication C: future dose (1 hour ahead)
      final medC = Medication(
        id: 'med_c',
        name: 'Medication C',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${oneHourAhead.toString().padLeft(2, '0')}:00': 1.0},
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
      // Use real current time since Medication model uses DateTime.now()
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Calculate future times: 1, 2, and 6 hours ahead
      final oneHourAhead = (currentHour + 1) % 24;
      final twoHoursAhead = (currentHour + 2) % 24;
      final sixHoursAhead = (currentHour + 6) % 24;

      // Medication A: dose 6 hours ahead
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${sixHoursAhead.toString().padLeft(2, '0')}:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication B: dose 1 hour ahead
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${oneHourAhead.toString().padLeft(2, '0')}:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication C: dose 2 hours ahead
      final medC = Medication(
        id: 'med_c',
        name: 'Medication C',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${twoHoursAhead.toString().padLeft(2, '0')}:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final medications = [medA, medC, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B (1 hour ahead) should be first, then C (2 hours ahead), then A (6 hours ahead)
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_c');
      expect(medications[2].id, 'med_a');
    });

    test('should place medications without next dose at the end', () {
      // Use real current time for this test since Medication model uses DateTime.now()
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Calculate a future time (2 hours from now, but ensure it's before midnight)
      final futureHour = (currentHour + 2) % 24;
      final futureTime = '${futureHour.toString().padLeft(2, '0')}:00';

      // Medication A: has future dose (2 hours from now)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {futureTime: 1.0},
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

      // Medication C: all doses already taken today
      // Use a past time (2 hours ago, but ensure it's after midnight)
      final pastHour = (currentHour - 2).clamp(0, 23);
      final pastTime = '${pastHour.toString().padLeft(2, '0')}:00';
      final medC = Medication(
        id: 'med_c',
        name: 'Medication C',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {pastTime: 1.0},
        takenDosesToday: [pastTime],
        takenDosesDate: today,
      );

      final medications = [medB, medA, medC];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // A should be first (has future dose today)
      expect(medications[0].id, 'med_a');
      // C should be second (next dose is tomorrow, closer than B which has no doses)
      expect(medications[1].id, 'med_c');
      // B should be last (no dose times configured at all)
      expect(medications[2].id, 'med_b');
    });

    test('should prioritize pending over future doses', () {
      // Use real current time since Medication model uses DateTime.now()
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Calculate a past time (1 hour ago) and a very close future time (few minutes from now)
      final oneHourAgo = ((currentHour - 1) % 24).clamp(0, 23);
      final fewMinutesAhead = (currentMinute + 5) % 60;
      final fewMinutesAheadHour = (fewMinutesAhead < currentMinute) ? (currentHour + 1) % 24 : currentHour;

      // Medication A: pending dose (overdue by 1 hour)
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${oneHourAgo.toString().padLeft(2, '0')}:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      // Medication B: future dose (very close, in few minutes)
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${fewMinutesAheadHour.toString().padLeft(2, '0')}:${fewMinutesAhead.toString().padLeft(2, '0')}': 1.0},
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
      // Use real current time since Medication model uses DateTime.now()
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Calculate times: 4 hours ago (taken), current hour (pending), 2 hours ahead (future)
      final fourHoursAgo = ((currentHour - 4) % 24).clamp(0, 23);
      final twoHoursAhead = (currentHour + 2) % 24;

      // Medication A: has doses at multiple times, one already taken
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 6,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {
          '${fourHoursAgo.toString().padLeft(2, '0')}:00': 1.0,
          '${currentHour.toString().padLeft(2, '0')}:00': 1.0,
          '${twoHoursAhead.toString().padLeft(2, '0')}:00': 1.0,
        },
        takenDosesToday: ['${fourHoursAgo.toString().padLeft(2, '0')}:00'],
        takenDosesDate: today,
      );

      // Medication B: has dose 1 hour ahead
      final oneHourAhead = (currentHour + 1) % 24;
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {'${oneHourAhead.toString().padLeft(2, '0')}:00': 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final medications = [medB, medA];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // A (pending at current hour) should be first
      expect(medications[0].id, 'med_a');
      expect(medications[1].id, 'med_b');
    });

    test('should handle weekly pattern medications', () {
      // Use real current time since Medication model uses DateTime.now()
      final now = DateTime.now();
      final currentWeekday = now.weekday;
      final currentHour = now.hour;
      final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Find a weekday that is NOT today (for the weekly pattern medication)
      // This ensures med_a won't be taken today
      final otherWeekdays = [1, 2, 3, 4, 5, 6, 7].where((d) => d != currentWeekday).take(3).toList();

      // Calculate a future time for today
      final futureHour = (currentHour + 2) % 24;
      final futureTime = '${futureHour.toString().padLeft(2, '0')}:00';

      // Medication A: weekly pattern on days that are NOT today
      // So its next dose will be on a future day
      final medA = Medication(
        id: 'med_a',
        name: 'Medication A',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.weeklyPattern,
        doseSchedule: {'08:00': 1.0},
        weeklyDays: otherWeekdays,
        takenDosesToday: [],
        takenDosesDate: todayString,
      );

      // Medication B: everyday with dose in the future today
      final medB = Medication(
        id: 'med_b',
        name: 'Medication B',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {futureTime: 1.0},
        takenDosesToday: [],
        takenDosesDate: todayString,
      );

      final medications = [medA, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B (today in future) should be first, A (another day) should be second
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_a');
    });

    test('should get correct next dose DateTime', () {
      // Use real current time since Medication model uses DateTime.now()
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Create a future dose time (3 hours ahead)
      final futureHour = (currentHour + 3) % 24;
      final futureTime = '${futureHour.toString().padLeft(2, '0')}:30';

      final medication = Medication(
        id: 'med_test',
        name: 'Test Medication',
        type: MedicationType.pastilla,
        dosageIntervalHours: 24,
        durationType: TreatmentDurationType.everyday,
        doseSchedule: {futureTime: 1.0},
        takenDosesToday: [],
        takenDosesDate: today,
      );

      final nextDose = MedicationSorter.getNextDoseDateTime(medication, now);

      expect(nextDose, isNotNull);
      expect(nextDose!.year, now.year);
      expect(nextDose.month, now.month);
      expect(nextDose.day, now.day);
      expect(nextDose.hour, futureHour);
      expect(nextDose.minute, 30);
    });

    test('should return null for medication without doses', () {
      // Use real current time since Medication model uses DateTime.now()
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

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
