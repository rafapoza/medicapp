import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:medicapp/utils/medication_sorter.dart';
import 'helpers/medication_builder.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('Medication Sorting', () {
    test('should sort pending doses first (most overdue first)', () {
      // Use a fixed time (10:00 AM) to ensure predictable results
      final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0);
      final today = getTodayString();

      // Calculate times relative to 10:00 AM: 2 hours ago, 1 hour ago, 1 hour ahead
      final twoHoursAgo = '08:00';    // 2 hours overdue
      final oneHourAgo = '09:00';     // 1 hour overdue
      final oneHourAhead = '11:00';   // 1 hour in future

      // Medication A: pending dose (1 hour overdue)
      final medA = MedicationBuilder()
          .withId('med_a')
          .withName('Medication A')
          .withDosageInterval(24)
          .withSingleDose(oneHourAgo, 1.0)
          .withTakenDoses([], today)
          .build();

      // Medication B: pending dose (2 hours overdue)
      final medB = MedicationBuilder()
          .withId('med_b')
          .withName('Medication B')
          .withDosageInterval(24)
          .withSingleDose(twoHoursAgo, 1.0)
          .withTakenDoses([], today)
          .build();

      // Medication C: future dose (1 hour ahead)
      final medC = MedicationBuilder()
          .withId('med_c')
          .withName('Medication C')
          .withDosageInterval(24)
          .withSingleDose(oneHourAhead, 1.0)
          .withTakenDoses([], today)
          .build();

      final medications = [medC, medA, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B should be first (most overdue), then A, then C
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_a');
      expect(medications[2].id, 'med_c');
    });

    test('should sort future doses by proximity', () {
      // Use a fixed time (10:00 AM) to ensure predictable results
      // This avoids issues with tests running at different times of day
      final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0);
      final today = getTodayString();

      // Calculate future times relative to 10:00 AM
      final oneHourAhead = '11:00';   // 1 hour ahead
      final twoHoursAhead = '12:00';  // 2 hours ahead
      final sixHoursAhead = '16:00';  // 6 hours ahead

      // Medication A: dose 6 hours ahead
      final medA = MedicationBuilder()
          .withId('med_a')
          .withName('Medication A')
          .withDosageInterval(24)
          .withSingleDose(sixHoursAhead, 1.0)
          .withTakenDoses([], today)
          .build();

      // Medication B: dose 1 hour ahead
      final medB = MedicationBuilder()
          .withId('med_b')
          .withName('Medication B')
          .withDosageInterval(24)
          .withSingleDose(oneHourAhead, 1.0)
          .withTakenDoses([], today)
          .build();

      // Medication C: dose 2 hours ahead
      final medC = MedicationBuilder()
          .withId('med_c')
          .withName('Medication C')
          .withDosageInterval(24)
          .withSingleDose(twoHoursAhead, 1.0)
          .withTakenDoses([], today)
          .build();

      final medications = [medA, medC, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B (1 hour ahead) should be first, then C (2 hours ahead), then A (6 hours ahead)
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_c');
      expect(medications[2].id, 'med_a');
    });

    test('should place medications without next dose at the end', () {
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = getTodayString();

      // Calculate a future time (2 hours from now)
      final futureTime = formatRelativeTime(currentHour, 2);

      // Medication A: has future dose (2 hours from now)
      final medA = MedicationBuilder()
          .withId('med_a')
          .withName('Medication A')
          .withDosageInterval(24)
          .withSingleDose(futureTime, 1.0)
          .withTakenDoses([], today)
          .build();

      // Medication B: no dose times configured
      final medB = MedicationBuilder()
          .withId('med_b')
          .withName('Medication B')
          .withDosageInterval(24)
          .withDoseSchedule({})
          .withTakenDoses([], today)
          .build();

      // Medication C: all doses already taken today
      final pastTime = formatRelativeTime(currentHour, -2);
      final medC = MedicationBuilder()
          .withId('med_c')
          .withName('Medication C')
          .withDosageInterval(24)
          .withSingleDose(pastTime, 1.0)
          .withTakenDoses([pastTime], today)
          .build();

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
      // Use a fixed time (10:00 AM) to ensure predictable results
      final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0);
      final today = getTodayString();

      // Calculate times relative to 10:00 AM
      final oneHourAgo = '09:00';          // 1 hour overdue
      final closeFutureTime = '10:05';     // 5 minutes in future

      // Medication A: pending dose (overdue by 1 hour)
      final medA = MedicationBuilder()
          .withId('med_a')
          .withName('Medication A')
          .withDosageInterval(24)
          .withSingleDose(oneHourAgo, 1.0)
          .withTakenDoses([], today)
          .build();

      // Medication B: future dose (very close, in few minutes)
      final medB = MedicationBuilder()
          .withId('med_b')
          .withName('Medication B')
          .withDosageInterval(24)
          .withSingleDose(closeFutureTime, 1.0)
          .withTakenDoses([], today)
          .build();

      final medications = [medB, medA];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // A (pending) should be first, even though B is closer in absolute time
      expect(medications[0].id, 'med_a');
      expect(medications[1].id, 'med_b');
    });

    test('should handle medications with multiple doses (find next available)', () {
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = getTodayString();

      // Calculate times: 4 hours ago (taken), current hour (pending), 2 hours ahead (future)
      final fourHoursAgo = formatRelativeTime(currentHour, -4);
      final currentHourTime = formatTime(currentHour);
      final twoHoursAhead = formatRelativeTime(currentHour, 2);

      // Medication A: has doses at multiple times, one already taken
      final medA = MedicationBuilder()
          .withId('med_a')
          .withName('Medication A')
          .withDosageInterval(6)
          .withDoseSchedule({
            fourHoursAgo: 1.0,
            currentHourTime: 1.0,
            twoHoursAhead: 1.0,
          })
          .withTakenDoses([fourHoursAgo], today)
          .build();

      // Medication B: has dose 1 hour ahead
      final oneHourAhead = formatRelativeTime(currentHour, 1);
      final medB = MedicationBuilder()
          .withId('med_b')
          .withName('Medication B')
          .withDosageInterval(24)
          .withSingleDose(oneHourAhead, 1.0)
          .withTakenDoses([], today)
          .build();

      final medications = [medB, medA];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // A (pending at current hour) should be first
      expect(medications[0].id, 'med_a');
      expect(medications[1].id, 'med_b');
    });

    test('should handle weekly pattern medications', () {
      final now = DateTime.now();
      final currentWeekday = now.weekday;
      final currentHour = now.hour;
      final todayString = getTodayString();

      // Find weekdays that are NOT today (for the weekly pattern medication)
      final otherWeekdays = [1, 2, 3, 4, 5, 6, 7]
          .where((d) => d != currentWeekday)
          .take(3)
          .toList();

      // Calculate a future time for today
      final futureTime = formatRelativeTime(currentHour, 2);

      // Medication A: weekly pattern on days that are NOT today
      // So its next dose will be on a future day
      final medA = MedicationBuilder()
          .withId('med_a')
          .withName('Medication A')
          .withDosageInterval(24)
          .withDurationType(TreatmentDurationType.weeklyPattern)
          .withSingleDose('08:00', 1.0)
          .withWeeklyPattern(otherWeekdays)
          .withTakenDoses([], todayString)
          .build();

      // Medication B: everyday with dose in the future today
      final medB = MedicationBuilder()
          .withId('med_b')
          .withName('Medication B')
          .withDosageInterval(24)
          .withSingleDose(futureTime, 1.0)
          .withTakenDoses([], todayString)
          .build();

      final medications = [medA, medB];
      MedicationSorter.sortByNextDose(medications, currentTime: now);

      // B (today in future) should be first, A (another day) should be second
      expect(medications[0].id, 'med_b');
      expect(medications[1].id, 'med_a');
    });

    test('should get correct next dose DateTime', () {
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = getTodayString();

      // Create a future dose time (3 hours ahead)
      final futureTime = formatRelativeTime(currentHour, 3, 30);
      final futureHour = calculateRelativeHour(currentHour, 3);

      final medication = MedicationBuilder()
          .withId('med_test')
          .withName('Test Medication')
          .withDosageInterval(24)
          .withSingleDose(futureTime, 1.0)
          .withTakenDoses([], today)
          .build();

      final nextDose = MedicationSorter.getNextDoseDateTime(medication, now);

      expect(nextDose, isNotNull);
      expect(nextDose!.year, now.year);
      expect(nextDose.month, now.month);
      expect(nextDose.day, now.day);
      expect(nextDose.hour, futureHour);
      expect(nextDose.minute, 30);
    });

    test('should return null for medication without doses', () {
      final now = DateTime.now();
      final today = getTodayString();

      final medication = MedicationBuilder()
          .withId('med_test')
          .withName('Test Medication')
          .withDosageInterval(24)
          .withDoseSchedule({})
          .withTakenDoses([], today)
          .build();

      final nextDose = MedicationSorter.getNextDoseDateTime(medication, now);

      expect(nextDose, isNull);
    });
  });
}
