import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/l10n/app_localizations.dart';

/// Helper function to get localized strings in tests.
/// This must be called after the widget tree is built (after pumpWidget).
AppLocalizations getL10n(WidgetTester tester) {
  // Find any widget that has access to localizations
  // Scaffold is a good choice as it's typically present in all screens
  final scaffoldFinder = find.byType(Scaffold);

  if (scaffoldFinder.evaluate().isEmpty) {
    // If no Scaffold, try to find any Text widget which should have inherited localizations
    final textFinder = find.byType(Text);
    if (textFinder.evaluate().isNotEmpty) {
      final context = tester.element(textFinder.first);
      return AppLocalizations.of(context)!;
    }
    // Last resort: use MaterialApp context
    final context = tester.element(find.byType(MaterialApp));
    return AppLocalizations.of(context)!;
  }

  final context = tester.element(scaffoldFinder.first);
  return AppLocalizations.of(context)!;
}

/// Helper function to wait for database operations to complete.
Future<void> waitForDatabase(WidgetTester tester) async {
  // Use runAsync to allow async operations to complete
  await tester.runAsync(() async {
    // Give time for database operations (increased for additional async queries)
    await Future.delayed(const Duration(milliseconds: 2000));
  });

  // Pump frames to rebuild UI after async operations
  await tester.pump();
  await tester.pump();

  // Wait for _checkNotificationPermissions and other async timers in MedicationListScreen
  // This prevents "pending timers" warnings in tests
  await tester.pump(const Duration(seconds: 2));
}

/// Helper function to scroll to a widget if needed.
Future<void> scrollToWidget(WidgetTester tester, Finder finder) async {
  final scrollView = find.byType(SingleChildScrollView);
  if (scrollView.evaluate().isNotEmpty) {
    try {
      await tester.dragUntilVisible(
        finder,
        scrollView.first,
        const Offset(0, -50),
      );
    } catch (e) {
      // If dragUntilVisible fails, try manual scroll
      await tester.drag(scrollView.first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
  }
}

/// Helper function to edit a medication through the new modular menu.
///
/// [sectionTitle]: One of "Información Básica", "Duración del Tratamiento",
/// "Frecuencia", "Horarios y Cantidades", "Cantidad Disponible"
Future<void> openEditMenuAndSelectSection(
  WidgetTester tester,
  String medicationName,
  String sectionTitle,
) async {
  // Tap on the medication to open modal
  await tester.tap(find.text(medicationName));
  await tester.pumpAndSettle();

  // Wait a bit for the modal to fully open
  await tester.pump(const Duration(milliseconds: 100));

  // Scroll to and tap edit button
  await scrollToWidget(tester, find.text(getL10n(tester).medicineCabinetEditMedication));
  await tester.tap(find.text(getL10n(tester).medicineCabinetEditMedication));
  await tester.pumpAndSettle();

  // Wait for navigation to complete
  await tester.pump(const Duration(milliseconds: 200));

  // Verify we're on the edit menu
  expect(find.text(getL10n(tester).editMedicationMenuTitle), findsWidgets);
  expect(find.text(getL10n(tester).editMedicationMenuWhatToEdit), findsWidgets);

  // Scroll to and tap the desired section
  await scrollToWidget(tester, find.text(sectionTitle));
  await tester.tap(find.text(sectionTitle));
  await tester.pumpAndSettle();

  // Wait for navigation to the edit section screen
  await tester.pump(const Duration(milliseconds: 200));
}

/// Helper function to add a medication through the complete flow.
///
/// Note: This uses MedicationScheduleScreen's autoFillForTesting mode to avoid
/// complex time picker interactions during automated testing.
Future<void> addMedicationWithDuration(
  WidgetTester tester,
  String name, {
  String? type,
  String? durationType,
  int dosageIntervalHours = 8, // Default to 8 hours
  String stockQuantity = '0', // Default stock quantity
}) async {
  // Tap the floating action button to go directly to add medication screen
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump(); // Start navigation
  await tester.pump(const Duration(milliseconds: 300)); // Allow navigation
  await tester.pump(); // Complete frame

  // Enter medication name (field 0)
  await tester.enterText(find.byType(TextFormField).first, name);
  await tester.pumpAndSettle();

  // Select type if specified
  if (type != null) {
    // Scroll to the type before tapping (it may be off-screen)
    await scrollToWidget(tester, find.text(type));
    await tester.tap(find.text(type));
    await tester.pumpAndSettle();
  }

  // Scroll to and tap continue button to go to duration screen
  await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
  await tester.tap(find.text(getL10n(tester).btnContinue));
  await tester.pumpAndSettle();

  // Select duration type (default to "Todos los días" if not specified)
  if (durationType != null) {
    await tester.tap(find.text(durationType));
    await tester.pumpAndSettle();
  }

  // Scroll to and tap continue button to go to treatment dates screen
  final l10n = getL10n(tester);
  await scrollToWidget(tester, find.text(l10n.btnContinue));
  await tester.tap(find.text(l10n.btnContinue));
  await tester.pumpAndSettle();

  // Now we're on the treatment dates screen (Phase 2 feature)
  // Verify we're there (may find more than one due to UI elements)
  expect(find.text(l10n.medicationDatesTitle), findsWidgets);

  // Continue from treatment dates screen to frequency screen
  await scrollToWidget(tester, find.text(l10n.btnContinue));
  await tester.tap(find.text(l10n.btnContinue));
  await tester.pumpAndSettle();

  // Now we're on the frequency screen (Phase 2 feature)
  // This screen allows selecting how often to take the medication
  // Check if we're on the frequency screen (it may be skipped for specific dates)
  final frequencyTitle = find.text(getL10n(tester).medicationFrequencyTitle);
  if (frequencyTitle.evaluate().isNotEmpty) {
    // We're on the frequency screen
    // Default is "Todos los días" which is preselected
    // Just continue to the next screen
    await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
    await tester.tap(find.text(getL10n(tester).btnContinue));
    await tester.pumpAndSettle();
  }

  // Now we're on the dosage configuration screen
  // This screen allows specifying dosage interval or custom doses per day
  // Default is "Todos los días igual" with 8-hour interval (preselected)
  // Just verify we're there
  expect(find.text(getL10n(tester).medicationDosageTitle), findsWidgets);

  // If dosageIntervalHours is different from default (8), enter it
  if (dosageIntervalHours != 8) {
    // Find the interval field by looking for the field with "Cada cuántas horas" label
    final intervalField = find.byType(TextFormField).first;
    await tester.enterText(intervalField, dosageIntervalHours.toString());
    await tester.pumpAndSettle();
  }

  await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
  await tester.tap(find.text(getL10n(tester).btnContinue));
  await tester.pumpAndSettle();

  // Now we're on the medication schedule screen
  // The screen will auto-fill times in testing mode
  // Just verify we're there and save
  expect(find.text(getL10n(tester).medicationTimesTitle), findsWidgets);

  // Wait a moment for auto-fill to complete
  await tester.pump(const Duration(milliseconds: 100));

  // Scroll to and tap continue button to go to fasting screen
  await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
  await tester.tap(find.text(getL10n(tester).btnContinue));
  await tester.pumpAndSettle();

  // Now we're on the fasting configuration screen
  // Just verify we're there
  expect(find.text(getL10n(tester).medicationFastingTitle), findsWidgets);

  // For testing, select "No" for fasting (default behavior)
  // The "No" option should be pre-selected by default, so we just continue
  await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
  await tester.tap(find.text(getL10n(tester).btnContinue));
  await tester.pumpAndSettle();

  // Now we're on the quantity screen (final step)
  // Just verify we're there
  expect(find.text(getL10n(tester).medicationQuantityTitle), findsWidgets);

  // Enter stock quantity if specified (default is '0')
  // The quantity screen has 2 fields: 'Cantidad disponible' and 'Avisar cuando queden'
  // Field 0 is the stock quantity
  if (stockQuantity != '0') {
    // Find the first TextFormField (Cantidad disponible)
    final quantityField = find.byType(TextFormField).first;
    // Clear and enter the stock quantity
    await tester.enterText(quantityField, stockQuantity);
    await tester.pumpAndSettle();
  }

  // Scroll to and tap save medication button
  await scrollToWidget(tester, find.text(getL10n(tester).saveMedicationButton));
  await tester.tap(find.text(getL10n(tester).saveMedicationButton));

  // Wait for the save operation to start (button shows loading indicator)
  await tester.pump();

  // Wait for database save operation and notification scheduling to complete
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 800));
  });

  // Pump multiple times to ensure all async operations and UI updates complete
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // Give extra time for navigation to complete and main screen to reload
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // Wait for main screen to reload medications from database
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 500));
  });
  await tester.pump();

  // Wait for SnackBar to disappear (default duration is 4 seconds)
  // This ensures that the FAB is not blocked when this helper returns
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

/// Helper function to tap a text widget multiple times.
///
/// Useful for activating the debug menu by tapping the title 5 times.
Future<void> tapTextMultipleTimes(
  WidgetTester tester,
  String text, {
  int times = 5,
}) async {
  final finder = find.text(text);
  for (int i = 0; i < times; i++) {
    await tester.tap(finder);
    await tester.pump();
  }
  // Wait for any async operations to complete
  await waitForDatabase(tester);
  await tester.pump();
  await tester.pump();
}
