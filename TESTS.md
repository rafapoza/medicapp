# Tests

El proyecto incluye una suite completa de tests:

```bash
flutter test
```

### Suite de tests incluida:

- **test/as_needed_stock_test.dart** (15): Gestión de stock para ocasionales, cálculo basado en consumo real, serialización
- **test/medication_model_test.dart** (2): Modelo de medicamento, cálculo de stock y dosis
- **test/preferences_service_test.dart** (12): Gestión de preferencias de usuario, independencia entre preferencias, valores por defecto, preferencia de notificación fija de ayuno
- **test/notification_service_test.dart** (42): Servicio de notificaciones, singleton, permisos, notificaciones pospuestas, notificación ongoing persistente con actualización automática
- **test/notification_cancellation_test.dart** (11): Cancelación inteligente, múltiples dosis, casos edge
- **test/early_dose_notification_test.dart** (5): Reprogramación de dosis tempranas, parámetro excludeToday, fix de duplicados
- **test/database_refill_test.dart** (6): Persistencia de recargas en SQLite
- **test/integration/** (45): Suite modular de widgets e integración con helpers i18n compartidos
- **test/dose_management_test.dart** (11): Historial de dosis, eliminación, cambio de estado, recálculo de estadísticas
- **test/fasting_test.dart** (13): Configuración de ayuno, serialización JSON, compatibilidad legacy
- **test/fasting_countdown_test.dart** (14): Cuenta atrás visual de ayuno, cálculo de períodos activos/próximos, diferenciación before/after, validación de estructura de datos
- **test/dynamic_fasting_notification_test.dart** (13): Notificaciones dinámicas basadas en hora real, diferentes duraciones
- **test/fasting_notification_scheduling_test.dart** (13): Lógica de programación de ayuno (before/after), casos edge
- **test/early_dose_with_fasting_test.dart** (8): Toma temprana con ayuno, cancelación correcta, uso de hora real
- **test/medication_sorting_test.dart** (6): Ordenamiento por urgencia, retraso y proximidad
- **test/edit_screens_validation_test.dart** (18): Validación EditQuantityScreen, cobertura 92.6%
- **test/edit_schedule_screen_test.dart** (15): EditScheduleScreen, gestión dinámica de dosis, cobertura 50.7%
- **test/edit_fasting_screen_test.dart** (18): EditFastingScreen, state management, cobertura 84.6%
- **test/edit_duration_screen_test.dart** (23): EditDurationScreen, validación de fechas, cobertura 82.7%
- **test/database_export_import_test.dart** (12): Export/import con validación, backup automático, restauración

**Total**: 361 tests cubriendo modelo, servicios, preferencias, persistencia, historial, funcionalidad de ayuno (incluida cuenta atrás visual y notificación ongoing), notificaciones, stock, pantallas de edición, backup/restore y widgets de integración

**Cobertura global**: 45.7% (2710 de 5927 líneas)

**Nota sobre el Botiquín**: La funcionalidad del Botiquín (vista de inventario) está implementada y funcional, pero no tiene tests dedicados ya que utiliza los mismos componentes y datos que el resto de la aplicación (lectura de base de datos, UI de lista, búsqueda). La funcionalidad es verificada manualmente.

### Mejoras recientes

- **Notificación fija de cuenta atrás** (octubre 2025): Notificación ongoing persistente (Android), timer de actualización automática, 19 tests nuevos (PreferencesService + NotificationService), gestión del medicamento más urgente
- **Cuenta atrás visual de ayuno** (octubre 2025): Nueva preferencia configurable, visualización de tiempo restante en pantalla principal, 14 tests de cálculo y validación, fix de SharedPreferences en tests de integración
- **Refactorización con Helpers** (enero 2025): 3 nuevos módulos (medication_builder, database_test_helper, test_helpers), 13 archivos refactorizados, -751 líneas (-38%), mejoras en legibilidad
- **Tests de pantallas de edición** (74 tests): EditQuantity (18), EditSchedule (15), EditFasting (18), EditDuration (23), cobertura +1.9%
- **Internacionalización** (enero 2025): 43 tests migrados a i18n, ~140 cadenas reemplazadas, 24 nuevas claves ES/EN, 100% cobertura i18n
- **Navegación adaptativa** (enero 2025): Tests para NavigationBar/NavigationRail según tamaño y orientación, MaterialDesign guías
- **Fix notificaciones** (octubre 2025): Corrección de duplicados con dosis tempranas, parámetro excludeToday, 5 nuevos tests, mejoras en menú debug
