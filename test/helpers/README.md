# Test Helpers - Guía de Uso

Este directorio contiene helpers reutilizables para simplificar y optimizar los tests de la aplicación.

## 📦 Contenido

### 1. `medication_builder.dart` - Builder Pattern para Medications

El **MedicationBuilder** simplifica enormemente la creación de objetos `Medication` en tests.

#### ✨ Ventajas:
- **Código más limpio y legible**: Reduce de 10-15 líneas a 3-5 líneas
- **Valores por defecto sensatos**: No necesitas especificar todo
- **Métodos fluidos**: Encadena llamadas para configurar solo lo necesario
- **Constructor `.from()`**: Copia y modifica medicamentos existentes fácilmente

#### Ejemplos de uso:

**ANTES (código repetitivo):**
```dart
final medication = Medication(
  id: 'test_1',
  name: 'Test Medication',
  type: MedicationType.pastilla,
  dosageIntervalHours: 8,
  durationType: TreatmentDurationType.everyday,
  doseSchedule: {'08:00': 1.0, '16:00': 1.0},
  stockQuantity: 10.0,
  takenDosesToday: ['08:00'],
  skippedDosesToday: [],
  takenDosesDate: getTodayString(),
);
```

**DESPUÉS (usando builder):**
```dart
final medication = MedicationBuilder()
    .withId('test_1')
    .withMultipleDoses(['08:00', '16:00'], 1.0)
    .withTakenDoses(['08:00'])
    .build();
```

#### Métodos disponibles:

```dart
// Configuración básica
.withId(String id)
.withName(String name)
.withType(MedicationType type)
.withStock(double quantity)

// Dosis
.withSingleDose('08:00', 1.0)
.withMultipleDoses(['08:00', '16:00', '20:00'], 1.0)
.withDoseSchedule({'08:00': 1.5, '16:00': 2.0})

// Estado de dosis
.withTakenDoses(['08:00'], getTodayString())
.withSkippedDoses(['16:00'])

// Ayuno
.withFasting(type: 'after', duration: 120, notify: true)
.withFastingDisabled()

// Fechas y patrones
.withStartDate(DateTime.now())
.withDateRange(start, end)
.withWeeklyPattern([1, 3, 5]) // Lunes, miércoles, viernes
.withSpecificDates(['2025-01-15', '2025-01-20'])

// Modificar medicamento existente
final updated = MedicationBuilder.from(original)
    .withStock(original.stockQuantity + 10)
    .build();
```

---

### 2. `database_test_helper.dart` - Setup de Base de Datos

Simplifica la configuración de la base de datos en tests.

**ANTES:**
```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  DatabaseHelper.setInMemoryDatabase(true);
});

tearDown(() async {
  await DatabaseHelper.instance.deleteAllMedications();
  await DatabaseHelper.instance.deleteAllDoseHistory();
  await DatabaseHelper.resetDatabase();
});
```

**DESPUÉS:**
```dart
DatabaseTestHelper.setup();  // ¡Una línea!
```

---

### 3. `test_helpers.dart` - Funciones Utilitarias

Contiene funciones helper comunes para tests.

#### Factory `createTestMedication()` (Deprecated)
⚠️ **Nota**: Esta función está marcada como `@Deprecated` en favor de `MedicationBuilder`.

**Importante**: A partir de enero 2025, `startDate` **no tiene valor por defecto**. Si tu test necesita una fecha específica o null, debes pasarla explícitamente:

```dart
// Para fechas específicas
final med = createTestMedication(
  id: 'test-1',
  startDate: DateTime(2025, 1, 15),
  endDate: DateTime(2025, 2, 14),
);

// Para testear comportamiento con null
final med = createTestMedication(
  id: 'test-2',
  startDate: null,
  endDate: null,
);
```

**Migración recomendada**: Usa `MedicationBuilder` para tests nuevos:
```dart
final med = MedicationBuilder()
    .withId('test-1')
    .withDateRange(DateTime(2025, 1, 15), DateTime(2025, 2, 14))
    .build();
```

#### Helpers de Fechas:
```dart
// Obtener fechas formateadas
getTodayString()        // '2025-10-22'
getYesterdayString()    // '2025-10-21'
getTomorrowString()     // '2025-10-23'
formatDate(DateTime)    // Formatea cualquier fecha

// Crear fechas
todayAt(10, 30)        // Hoy a las 10:30
daysAgo(5)             // Hace 5 días
daysFromNow(7)         // En 7 días

// Comparar fechas
isSameDay(date1, date2)
isToday(date)
```

#### Helpers de Notificaciones:
```dart
generateNotificationId(medId, doseIndex)
generateSpecificDateNotificationId(medId, date, index)
generateWeeklyNotificationId(medId, weekday, index)
generatePostponedNotificationId(medId, doseTime)
```

#### Helpers de UI (para widget tests):
```dart
pumpScreen(tester, widget)
scrollAndTap(tester, finder)
expectValidationError(message)
expectNoValidationError(message)
```

---

## 🔄 Comparación Antes/Después

### Test de actualización de medicamento

**ANTES (47 líneas):**
```dart
test('Delete taken dose restores stock', () async {
  final medication = Medication(
    id: 'test_med_2',
    name: 'Test Medication 2',
    type: MedicationType.pastilla,
    dosageIntervalHours: 12,
    durationType: TreatmentDurationType.everyday,
    doseSchedule: {'08:00': 2.0, '20:00': 1.0},
    stockQuantity: 10.0,
    takenDosesToday: ['08:00'],
    skippedDosesToday: ['20:00'],
    takenDosesDate: _getTodayString(),
  );

  await DatabaseHelper.instance.insertMedication(medication);

  final takenDoses = List<String>.from(medication.takenDosesToday);
  takenDoses.remove('08:00');

  final afterDeleteTaken = Medication(
    id: medication.id,
    name: medication.name,
    type: medication.type,
    dosageIntervalHours: medication.dosageIntervalHours,
    durationType: medication.durationType,
    doseSchedule: medication.doseSchedule,
    stockQuantity: medication.stockQuantity + 2.0,
    takenDosesToday: takenDoses,
    skippedDosesToday: medication.skippedDosesToday,
    takenDosesDate: medication.takenDosesDate,
  );

  await DatabaseHelper.instance.updateMedication(afterDeleteTaken);

  var reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
  expect(reloadedMed!.stockQuantity, 12.0);
});
```

**DESPUÉS (20 líneas - reducción del 57%):**
```dart
test('Delete taken dose restores stock', () async {
  final medication = MedicationBuilder()
      .withId('test_med_2')
      .withDoseSchedule({'08:00': 2.0, '20:00': 1.0})
      .withStock(10.0)
      .withTakenDoses(['08:00'])
      .withSkippedDoses(['20:00'])
      .build();

  await DatabaseHelper.instance.insertMedication(medication);

  final afterDeleteTaken = MedicationBuilder.from(medication)
      .withStock(medication.stockQuantity + 2.0)
      .withTakenDoses([])
      .build();

  await DatabaseHelper.instance.updateMedication(afterDeleteTaken);

  var reloadedMed = await DatabaseHelper.instance.getMedication(medication.id);
  expect(reloadedMed!.stockQuantity, 12.0);
});
```

---

## 📊 Mejoras en Assertions

Se reemplazaron assertions débiles (`expect(true, true)`) por validaciones reales:

**ANTES:**
```dart
test('should schedule fasting notification', () async {
  await service.scheduleDynamicFastingNotification(...);
  expect(true, true);  // ❌ No valida nada
});
```

**DESPUÉS:**
```dart
test('should schedule fasting notification', () async {
  // Verificar configuración
  expect(medication.requiresFasting, true);
  expect(medication.fastingDurationMinutes, 120);

  // Verificar que completa sin errores
  await expectLater(
    service.scheduleDynamicFastingNotification(...),
    completes,  // ✅ Valida que la operación completa
  );
});
```

---

## 📈 Resultados

### Estadísticas de optimización:
- **Reducción de código**: 40-60% menos líneas en tests refactorizados
- **Eliminación de duplicación**:
  - Setup de base de datos: de 15 líneas a 1 línea
  - Función `_getTodayString()`: eliminada (ahora centralizada)
  - Helper de generación de IDs: unificados en un solo lugar
- **Mejora en legibilidad**: Tests más claros y fáciles de entender
- **Mantenibilidad**: Cambios en Medication solo requieren actualizar el builder

### Tests verificados:
✅ `medication_model_test.dart` - 19 tests pasando
✅ `database_refill_test.dart` - 6 tests pasando
✅ `dynamic_fasting_notification_test.dart` - 12 tests pasando
✅ `dose_management_test.dart` - Parcialmente refactorizado

---

## 🚀 Próximos pasos

Para aplicar estas optimizaciones al resto de tests:

1. **Reemplazar creación manual de Medication** con `MedicationBuilder`
2. **Usar `DatabaseTestHelper.setup()`** en tests de BD
3. **Importar funciones de fechas** de `test_helpers.dart` en lugar de crear locales
4. **Mejorar assertions débiles** con validaciones reales
5. **Usar `MedicationBuilder.from()`** para modificaciones

---

## 💡 Tips

- Usa `.withMultipleDoses()` cuando todas las dosis tienen la misma cantidad
- Usa `.withDoseSchedule()` cuando las dosis tienen cantidades diferentes
- `MedicationBuilder.from()` es perfecto para tests de actualización
- Los helpers de fechas manejan el formateo automáticamente
- Siempre verifica que tus assertions sean significativas
