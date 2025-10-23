import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Setup común para inicializar SQLite en tests
void setupTestDatabase() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
}

/// Factory para crear medicaciones de test con valores por defecto
/// @deprecated Usar MedicationBuilder en su lugar
@Deprecated('Usar MedicationBuilder en su lugar')
Medication createTestMedication({
  String? id,
  String? name,
  MedicationType? type,
  int? dosageIntervalHours,
  TreatmentDurationType? durationType,
  Map<String, double>? doseSchedule,
  double? stockQuantity,
  int? lowStockThresholdDays,
  DateTime? startDate,
  DateTime? endDate,
  List<String>? selectedDates,
  List<int>? weeklyDays,
  int? dayInterval,
  bool? requiresFasting,
  String? fastingType,
  int? fastingDurationMinutes,
  bool? notifyFasting,
}) {
  return Medication(
    id: id ?? 'test-med-${DateTime.now().millisecondsSinceEpoch}',
    name: name ?? 'Test Medicine',
    type: type ?? MedicationType.pill,
    dosageIntervalHours: dosageIntervalHours ?? 8,
    durationType: durationType ?? TreatmentDurationType.everyday,
    doseSchedule: doseSchedule ?? {'08:00': 1.0},
    stockQuantity: stockQuantity ?? 20.0,
    lowStockThresholdDays: lowStockThresholdDays ?? 3,
    startDate: startDate, // No default - tests must pass startDate explicitly if needed
    endDate: endDate,
    selectedDates: selectedDates,
    weeklyDays: weeklyDays,
    dayInterval: dayInterval,
    requiresFasting: requiresFasting ?? false,
    fastingType: fastingType,
    fastingDurationMinutes: fastingDurationMinutes,
    notifyFasting: notifyFasting ?? false,
  );
}

// ============================================================================
// HELPERS DE FECHAS
// ============================================================================

/// Obtiene la fecha de hoy en formato 'YYYY-MM-DD'.
String getTodayString() {
  final now = DateTime.now();
  return formatDate(now);
}

/// Obtiene la fecha de ayer en formato 'YYYY-MM-DD'.
String getYesterdayString() {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return formatDate(yesterday);
}

/// Obtiene la fecha de mañana en formato 'YYYY-MM-DD'.
String getTomorrowString() {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  return formatDate(tomorrow);
}

/// Formatea una fecha a string en formato 'YYYY-MM-DD'.
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Crea una fecha para hoy a una hora específica.
DateTime todayAt(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

/// Verifica si dos fechas son del mismo día.
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

/// Verifica si una fecha es hoy.
bool isToday(DateTime date) {
  return isSameDay(date, DateTime.now());
}

/// Crea una fecha X días en el pasado.
DateTime daysAgo(int days) {
  return DateTime.now().subtract(Duration(days: days));
}

/// Crea una fecha X días en el futuro.
DateTime daysFromNow(int days) {
  return DateTime.now().add(Duration(days: days));
}

// ============================================================================
// HELPERS DE NOTIFICACIONES
// ============================================================================

/// Genera un ID único para notificaciones (simula la lógica del servicio).
int generateNotificationId(String medicationId, int doseIndex) {
  final medicationHash = medicationId.hashCode.abs();
  return (medicationHash % 1000000) * 100 + doseIndex;
}

/// Genera un ID de notificación para una fecha específica.
int generateSpecificDateNotificationId(String medicationId, String dateString, int doseIndex) {
  final combinedString = '$medicationId-$dateString-$doseIndex';
  final hash = combinedString.hashCode.abs();
  return 3000000 + (hash % 1000000);
}

/// Genera un ID de notificación para patrón semanal.
int generateWeeklyNotificationId(String medicationId, int weekday, int doseIndex) {
  final combinedString = '$medicationId-weekday$weekday-$doseIndex';
  final hash = combinedString.hashCode.abs();
  return 4000000 + (hash % 1000000);
}

/// Genera un ID de notificación pospuesta.
int generatePostponedNotificationId(String medicationId, String doseTime) {
  final combinedString = '$medicationId-$doseTime';
  final hash = combinedString.hashCode.abs();
  return 2000000 + (hash % 1000000);
}

// ============================================================================
// HELPERS DE FORMATEO DE HORAS
// ============================================================================

/// Formatea una hora en formato 'HH:MM'.
String formatTime(int hour, [int minute = 0]) {
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Calcula una hora relativa (ej: 2 horas atrás, 3 horas adelante).
/// Retorna el valor en formato 24 horas (0-23).
/// Maneja correctamente valores negativos y cruces de medianoche.
int calculateRelativeHour(int currentHour, int delta) {
  int result = (currentHour + delta) % 24;
  // En Dart, el módulo de números negativos devuelve valores negativos
  // Ej: -1 % 24 = -1, no 23. Necesitamos corregir esto.
  if (result < 0) {
    result += 24;
  }
  return result;
}

/// Helper combinado: calcula hora relativa y la formatea.
String formatRelativeTime(int currentHour, int hoursDelta, [int minute = 0]) {
  final hour = calculateRelativeHour(currentHour, hoursDelta);
  return formatTime(hour, minute);
}

// ============================================================================
// HELPERS DE UI/WIDGETS
// ============================================================================

/// Helper para envolver un widget en MaterialApp y pumpearlo
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  bool settleAfter = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es', 'ES'),
      home: screen,
    ),
  );

  if (settleAfter) {
    await tester.pumpAndSettle();
  }
}

/// Helper para test de navegación con botón cancelar
///
/// Este helper verifica:
/// 1. Que la pantalla se puede abrir desde un botón
/// 2. Que el título de la pantalla es correcto
/// 3. Que el botón cancelar navega de regreso
Future<void> testCancelNavigation(
  WidgetTester tester, {
  required String screenTitle,
  required Widget Function(BuildContext) screenBuilder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es', 'ES'),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: screenBuilder,
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
  expect(find.text(screenTitle), findsOneWidget);

  // Scroll to cancel button (may be off-screen)
  await tester.ensureVisible(find.text('Cancelar'));
  await tester.pumpAndSettle();

  // Tap cancel
  await tester.tap(find.text('Cancelar'));
  await tester.pumpAndSettle();

  // Should be back to the original screen
  expect(find.text(screenTitle), findsNothing);
  expect(find.text('Open'), findsOneWidget);
}

/// Helper para verificar que el botón guardar existe
void expectSaveButtonExists() {
  expect(find.text('Guardar Cambios'), findsOneWidget);
}

/// Helper para verificar que el botón cancelar existe
void expectCancelButtonExists() {
  expect(find.text('Cancelar'), findsOneWidget);
}

/// Helper para hacer scroll a un elemento y hacer tap
Future<void> scrollAndTap(
  WidgetTester tester,
  Finder finder, {
  bool settle = true,
}) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// Helper para verificar que se muestra un error de validación
void expectValidationError(String errorMessage) {
  expect(find.text(errorMessage), findsOneWidget);
}

/// Helper para verificar que NO se muestra un error de validación
void expectNoValidationError(String errorMessage) {
  expect(find.text(errorMessage), findsNothing);
}
