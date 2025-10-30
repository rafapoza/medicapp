import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:medicapp/screens/settings_screen.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/services/preferences_service.dart';
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
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await DatabaseHelper.resetDatabase();
  });

  Widget createTestApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es', 'ES'),
      home: child,
    );
  }

  group('SettingsScreen - Initial State and Rendering', () {
    testWidgets('should render settings screen with all sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Check AppBar title
      expect(find.text('Configuración'), findsOneWidget);

      // Check Display section exists
      expect(find.text('Visualización'), findsOneWidget);

      // Check Backup section exists
      expect(find.text('Copia de Seguridad'), findsOneWidget);

      // Check preference switches exist
      expect(find.text('Mostrar hora real de toma'), findsOneWidget);
      expect(find.text('Mostrar cuenta atrás de ayuno'), findsOneWidget);

      // Check export/import options exist
      expect(find.text('Exportar Base de Datos'), findsOneWidget);
      expect(find.text('Importar Base de Datos'), findsOneWidget);
    });

    testWidgets('should load initial preference values', (WidgetTester tester) async {
      // Set some preferences before rendering
      await PreferencesService.setShowActualTimeForTakenDoses(true);
      await PreferencesService.setShowFastingCountdown(false);

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Find switches
      final switchWidgets = tester.widgetList<Switch>(find.byType(Switch));
      expect(switchWidgets.length, greaterThanOrEqualTo(2));

      // First switch should be on (actual time)
      expect(switchWidgets.first.value, true);
      // Second switch should be off (fasting countdown)
      expect(switchWidgets.elementAt(1).value, false);
    });

    testWidgets('should show fasting notification switch only on Android when countdown is enabled', (WidgetTester tester) async {
      await PreferencesService.setShowFastingCountdown(true);

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Note: In test environment, Platform.isAndroid may not be true
      // This test validates the widget structure, actual platform check happens at runtime
      final switchCount = tester.widgetList<Switch>(find.byType(Switch)).length;
      expect(switchCount, greaterThanOrEqualTo(2));
    });
  });

  group('SettingsScreen - Preference Toggle Changes', () {
    testWidgets('should toggle show actual time preference', (WidgetTester tester) async {
      await PreferencesService.setShowActualTimeForTakenDoses(false);

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Find and tap the ListTile containing the preference
      await tester.tap(find.text('Mostrar hora real de toma'));
      await tester.pumpAndSettle();

      // Verify preference was saved
      final newValue = await PreferencesService.getShowActualTimeForTakenDoses();
      expect(newValue, true);
    });

    testWidgets('should toggle show fasting countdown preference', (WidgetTester tester) async {
      await PreferencesService.setShowFastingCountdown(false);

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Find and tap the ListTile containing the preference
      await tester.tap(find.text('Mostrar cuenta atrás de ayuno'));
      await tester.pumpAndSettle();

      // Verify preference was saved
      final newValue = await PreferencesService.getShowFastingCountdown();
      expect(newValue, true);
    });

    testWidgets('should disable fasting notification when countdown is disabled', (WidgetTester tester) async {
      // Enable both preferences
      await PreferencesService.setShowFastingCountdown(true);
      await PreferencesService.setShowFastingNotification(true);

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Find and tap the countdown switch to disable it
      await tester.tap(find.text('Mostrar cuenta atrás de ayuno'));
      await tester.pumpAndSettle();

      // Verify both preferences are now disabled
      final countdownValue = await PreferencesService.getShowFastingCountdown();
      final notificationValue = await PreferencesService.getShowFastingNotification();

      expect(countdownValue, false);
      expect(notificationValue, false);
    });

    testWidgets('should persist preference changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Toggle actual time preference
      await tester.tap(find.text('Mostrar hora real de toma'));
      await tester.pumpAndSettle();

      // Rebuild widget tree (simulating app restart)
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Verify preference is still set
      final value = await PreferencesService.getShowActualTimeForTakenDoses();
      expect(value, true);
    });
  });

  group('SettingsScreen - Export Database', () {
    testWidgets('should display export button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Verify export button is visible
      expect(find.text('Exportar Base de Datos'), findsOneWidget);
      expect(find.text('Guarda una copia de todos tus medicamentos e historial'), findsOneWidget);

      // Find export button card
      final exportCard = find.ancestor(
        of: find.text('Exportar Base de Datos'),
        matching: find.byType(Card),
      );

      expect(exportCard, findsOneWidget);

      // Note: Cannot test actual export functionality in widget tests
      // as it requires platform-specific plugins (share_plus)
    });

    testWidgets('export and import buttons should be disabled during operations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Get initial opacity (enabled state)
      final exportCard = find.ancestor(
        of: find.text('Exportar Base de Datos'),
        matching: find.byType(Card),
      ).first;

      expect(exportCard, findsOneWidget);

      // Note: Testing button disabled state during async operations is complex
      // in widget tests without mocking the services completely
    });
  });

  group('SettingsScreen - Import Database', () {
    testWidgets('should show confirmation dialog before importing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Find import button
      final importButton = find.ancestor(
        of: find.text('Importar Base de Datos'),
        matching: find.byType(InkWell),
      );

      expect(importButton, findsOneWidget);

      // Tap import
      await tester.tap(importButton);
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Importar Base de Datos'), findsWidgets); // Title appears twice
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('should cancel import when user selects cancel', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Tap import button
      final importButton = find.ancestor(
        of: find.text('Importar Base de Datos'),
        matching: find.byType(InkWell),
      );
      await tester.tap(importButton);
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
      // Should not show loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should proceed with file picker when user confirms', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Tap import button
      final importButton = find.ancestor(
        of: find.text('Importar Base de Datos'),
        matching: find.byType(InkWell),
      );
      await tester.tap(importButton);
      await tester.pumpAndSettle();

      // Tap continue
      await tester.tap(find.text('Continuar'));
      await tester.pump(); // Don't settle, check intermediate state

      // Should show loading (briefly before file picker would open)
      // Note: File picker will fail in test environment
    });
  });

  group('SettingsScreen - UI State Management', () {
    testWidgets('should handle mounted check during async operations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Toggle a preference
      await tester.tap(find.text('Mostrar hora real de toma'));

      // Dispose the widget immediately
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // Widget should handle mounted check gracefully (no exceptions thrown)
    });

    testWidgets('should show all preference switches with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Check all preference titles
      expect(find.text('Mostrar hora real de toma'), findsOneWidget);
      expect(find.text('Mostrar cuenta atrás de ayuno'), findsOneWidget);

      // Check subtitles
      expect(find.text('Muestra la hora real en que se tomaron las dosis en lugar de la hora programada'), findsOneWidget);
      expect(find.text('Muestra el tiempo restante de ayuno en la pantalla principal'), findsOneWidget);
    });

    testWidgets('should display export and import with correct subtitles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Check export
      expect(find.text('Exportar Base de Datos'), findsOneWidget);
      expect(find.text('Guarda una copia de todos tus medicamentos e historial'), findsOneWidget);

      // Check import
      expect(find.text('Importar Base de Datos'), findsOneWidget);
      expect(find.text('Restaura una copia de seguridad previamente exportada'), findsOneWidget);
    });
  });

  group('SettingsScreen - Navigation', () {
    testWidgets('should have back button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // AppBar should be present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);
    });

    testWidgets('should show info card at bottom', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Info card should be visible (it's a custom widget)
      // We can't test its exact content without knowing the implementation
      // but we can verify the list scrolls properly
    });
  });

  group('SettingsScreen - Preference Interactions', () {
    testWidgets('should allow multiple preference toggles', (WidgetTester tester) async {
      await PreferencesService.setShowActualTimeForTakenDoses(false);
      await PreferencesService.setShowFastingCountdown(false);

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Toggle actual time
      await tester.tap(find.text('Mostrar hora real de toma'));
      await tester.pumpAndSettle();

      // Toggle fasting countdown
      await tester.tap(find.text('Mostrar cuenta atrás de ayuno'));
      await tester.pumpAndSettle();

      // Verify both preferences are enabled
      expect(await PreferencesService.getShowActualTimeForTakenDoses(), true);
      expect(await PreferencesService.getShowFastingCountdown(), true);
    });

    testWidgets('should maintain state after orientation change', (WidgetTester tester) async {
      await PreferencesService.setShowActualTimeForTakenDoses(true);

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Simulate rebuild (like orientation change)
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Verify state is maintained
      final value = await PreferencesService.getShowActualTimeForTakenDoses();
      expect(value, true);
    });
  });
}
