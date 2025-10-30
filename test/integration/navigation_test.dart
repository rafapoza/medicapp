import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicapp/main.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/notification_service.dart';
import '../helpers/widget_test_helpers.dart';
import '../helpers/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DatabaseTestHelper.setupAll();

  // Clean up database before each test to ensure test isolation
  setUp(() async {
    // Set larger window size for accessibility tests (larger fonts and buttons)
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView!.physicalSize = const Size(1200, 1800);
    binding.platformDispatcher.implicitView!.devicePixelRatio = 1.0;

    // Mock SharedPreferences to avoid plugin errors in tests
    SharedPreferences.setMockInitialValues({});

    // Close and reset the database to get a fresh in-memory instance
    await DatabaseHelper.resetDatabase();
    // Enable in-memory mode for this test
    DatabaseHelper.setInMemoryDatabase(true);
    // Enable test mode for notifications (disables actual notifications)
    NotificationService.instance.enableTestMode();
  });

  // Clean up after each test
  tearDown(() {
    // Reset window size to default
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView!.resetPhysicalSize();
    binding.platformDispatcher.implicitView!.resetDevicePixelRatio();
  });

  testWidgets('Should navigate to treatment duration screen after entering medication info', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Tap FAB to navigate directly to add medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter name (use .first to get the name field, not the frequency field)
    await tester.enterText(find.byType(TextFormField).first, 'Ibuprofeno');

    // Scroll to and tap continue
    await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
    await tester.tap(find.text(getL10n(tester).btnContinue));
    await tester.pumpAndSettle();

    // Verify we're on the treatment duration screen
    expect(find.text(getL10n(tester).medicationDurationTitle), findsWidgets);
    expect(find.text(getL10n(tester).medicationDurationSubtitle), findsWidgets);
    expect(find.text(getL10n(tester).durationContinuousTitle), findsWidgets);
    expect(find.text(getL10n(tester).durationUntilEmptyTitle), findsWidgets);
    expect(find.text(getL10n(tester).durationSpecificDatesTitle), findsWidgets);
  });

  testWidgets('Should cancel adding medication from duration screen', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Start adding a medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'TestMed');
    await scrollToWidget(tester, find.text(getL10n(tester).btnContinue));
    await tester.tap(find.text(getL10n(tester).btnContinue));
    await tester.pumpAndSettle();

    // Verify we're on the duration/treatment type screen
    expect(find.text(getL10n(tester).medicationDurationTitle), findsWidgets);

    // Go back from duration screen
    await scrollToWidget(tester, find.text(getL10n(tester).btnBack));
    await tester.tap(find.text(getL10n(tester).btnBack));
    await tester.pumpAndSettle();

    // Verify we're back on the add medication screen (step 1)
    expect(find.text(getL10n(tester).addMedicationTitle), findsWidgets);
    expect(find.text(getL10n(tester).medicationInfoTitle), findsWidgets);
  });

  testWidgets('Floating action button should navigate directly to add medication', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Tap the floating action button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify we're directly on the add medication screen (no modal)
    // Navigation to other sections (Pastillero, Botiquín, Historial) is now via BottomNavigationBar
    expect(find.text(getL10n(tester).addMedicationTitle), findsWidgets);
    expect(find.text(getL10n(tester).medicationInfoTitle), findsWidgets);
  });

  testWidgets('Should navigate back from add medication screen', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Tap FAB to navigate to add medication
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify we're on the add medication screen
    expect(find.text(getL10n(tester).addMedicationTitle), findsWidgets);

    // Navigate back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(); // Start navigation

    // Wait for database operations to complete after navigation
    await waitForDatabase(tester);

    // Additional pumps to finish any remaining animations
    await tester.pump();
    await tester.pump();

    // Verify we're back on the main screen
    expect(find.text(getL10n(tester).mainScreenTitle), findsWidgets);
  });

  testWidgets('Should show NavigationBar on mobile screens', (WidgetTester tester) async {
    // Force mobile screen size (portrait)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Verify the navigation sections are present with short labels
    expect(find.text(getL10n(tester).navMedicationShort), findsWidgets);
    expect(find.text(getL10n(tester).navInventoryShort), findsWidgets);
    expect(find.text(getL10n(tester).navHistoryShort), findsWidgets);
    expect(find.text(getL10n(tester).navSettingsShort), findsWidgets);

    // Verify NavigationBar is used (bottom navigation)
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('Should show NavigationRail on tablet screens', (WidgetTester tester) async {
    // Force tablet screen size
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Additional pumps to ensure full rendering after async queries
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify the navigation sections are present (now using short labels in both views)
    expect(find.text(getL10n(tester).navMedicationShort), findsWidgets);
    expect(find.text(getL10n(tester).navInventoryShort), findsWidgets);
    expect(find.text(getL10n(tester).navHistoryShort), findsWidgets);
    expect(find.text(getL10n(tester).navSettingsShort), findsWidgets);

    // Verify NavigationRail is used (side navigation)
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Should show NavigationRail in landscape mode', (WidgetTester tester) async {
    // Force landscape orientation (even on mobile size)
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Build our app
    await tester.pumpWidget(const MedicApp());
    await waitForDatabase(tester);

    // Additional pumps to ensure full rendering after async queries
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify the navigation sections are present (now using short labels in both views)
    expect(find.text(getL10n(tester).navMedicationShort), findsWidgets);
    expect(find.text(getL10n(tester).navInventoryShort), findsWidgets);
    expect(find.text(getL10n(tester).navHistoryShort), findsWidgets);
    expect(find.text(getL10n(tester).navSettingsShort), findsWidgets);

    // Verify NavigationRail is used in landscape
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
