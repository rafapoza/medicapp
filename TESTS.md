# Tests

El proyecto incluye una suite completa de tests:

```bash
flutter test
```

### Suite de tests incluida:

- **test/as_needed_stock_test.dart**: Tests de gestión de stock para medicamentos ocasionales (15 tests)
  - Cálculo de stock bajo basado en consumo real
  - Serialización y deserialización de `lastDailyConsumption`
  - Compatibilidad con medicamentos programados y ocasionales
  - Validaciones de umbral de stock
- **test/medication_model_test.dart**: Tests del modelo de medicamento (2 tests)
  - Grupo "Stock and Doses": tests para cálculo de stock y dosis diarias
- **test/notification_service_test.dart**: Tests del servicio de notificaciones (13 tests)
  - Tests de singleton, inicialización, permisos
  - Programación de notificaciones de medicamentos
  - Notificaciones pospuestas (5 tests)
  - Modo de test
- **test/notification_cancellation_test.dart**: Tests de cancelación inteligente de notificaciones (11 tests)
  - Cancelación automática al registrar tomas manuales
  - Cancelación para todos los tipos de duración de tratamiento
  - Cancelación de múltiples dosis independientemente
  - Cancelación junto con notificaciones pospuestas
  - Manejo correcto de casos edge (horario inexistente, medicación nunca programada)
  - Compatibilidad con todos los tipos de medicamento
- **test/database_refill_test.dart**: Tests de persistencia de recargas (6 tests)
  - Integración con base de datos SQLite
  - Verificación de persistencia de `lastRefillAmount`
  - Tests de actualización y compatibilidad
- **test/widget_test.dart**: Suite completa de tests de widgets e integración (1 test)
  - Test básico de smoke test de la aplicación
- **test/dose_management_test.dart**: Tests del sistema de historial de dosis (11 tests)
  - Tests de eliminación de entradas de historial
  - Tests de cambio de estado (tomada/omitida)
  - Tests de gestión de múltiples dosis
  - Tests de recálculo de estadísticas
  - Tests de integración con base de datos SQLite
- **test/fasting_test.dart**: Tests de configuración de ayuno (13 tests)
  - Funcionalidad completa de ayuno:
    - Configuración por defecto (sin ayuno)
    - Ayuno antes y después de la toma
    - Duración de ayuno en minutos
    - Serialización y deserialización JSON
    - Compatibilidad con datos legacy (sin campos de ayuno)
    - Round-trip de encoding/decoding
    - Preservación de campos al actualizar
    - Validación de todos los tipos de medicamento
- **test/dynamic_fasting_notification_test.dart**: Tests de notificaciones dinámicas de ayuno (13 tests)
  - Notificaciones basadas en hora real de toma:
    - Programación correcta para ayuno tipo "after"
    - No programación para ayuno tipo "before"
    - Validaciones de configuración (requiresFasting, notifyFasting, fastingDurationMinutes)
    - Diferentes duraciones de ayuno (30, 60, 90, 120, 180, 240 minutos)
    - Compatibilidad con todos los tipos de medicamento
    - Manejo de horas de toma pasadas y futuras
    - Medicamentos con múltiples horarios de toma
    - Compatibilidad con todos los tipos de duración de tratamiento
- **test/fasting_notification_scheduling_test.dart**: Tests de lógica de programación de notificaciones de ayuno (13 tests)
  - Notificaciones "before" se programan automáticamente
  - Notificaciones "after" NO se programan automáticamente
  - Notificaciones "after" solo se programan cuando se registra la toma real
  - Validación de condiciones (requiresFasting, notifyFasting)
  - Múltiples dosis y duraciones diferentes
  - Casos edge: ayuno que se solapa, reprogramación
  - Usa hora real de toma, no hora programada
- **test/medication_sorting_test.dart**: Tests de ordenamiento de medicamentos (6 tests)
  - Sistema de priorización de medicamentos:
    - Ordenamiento por urgencia (dosis pendientes primero)
    - Priorización por retraso (más atrasadas primero)
    - Ordenamiento por proximidad para dosis futuras
    - Manejo de medicamentos sin próxima dosis
    - Priorización de pendientes sobre futuras
    - Manejo de múltiples dosis por medicamento
  - **Importante**: Los tests usan fechas y horas reales (`DateTime.now()`) para compatibilidad con el modelo `Medication` que usa tiempo real internamente
- **test/edit_screens_validation_test.dart**: Tests de validación para EditQuantityScreen (18 tests)
  - Renderizado y valores iniciales
  - Validación de campos vacíos, negativos y cero
  - Validación de rangos (umbral 1-30 días)
  - Parsing de decimales e inputs inválidos
  - Casos límite y navegación
  - **Cobertura**: edit_quantity_screen.dart: 0% → 92.6%
- **test/edit_schedule_screen_test.dart**: Tests para EditScheduleScreen (15 tests)
  - Renderizado y gestión de dosis
  - Validación de cantidades inválidas
  - Añadir tomas dinámicamente
  - Navegación y estados de botones
  - Edge cases: dosis únicas, múltiples, decimales
  - **Cobertura**: edit_schedule_screen.dart: 0% → 50.7%
- **test/edit_fasting_screen_test.dart**: Tests para EditFastingScreen (18 tests)
  - Configuración de ayuno (activar/desactivar)
  - Validación de tipo de ayuno y duración mínima
  - Edge cases: duraciones largas, solo minutos, diferentes tipos
  - State management: reseteo al desactivar ayuno
  - **Cobertura**: edit_fasting_screen.dart: 0% → 84.6%
- **test/edit_duration_screen_test.dart**: Tests para EditDurationScreen (23 tests)
  - Renderizado y visualización de fechas
  - Validación de fechas requeridas según tipo de duración
  - Cálculo de duración en días
  - Edge cases: diferentes tipos de duración, períodos largos
  - **Cobertura**: edit_duration_screen.dart: 0% → 82.7%

**Total**: 263 tests cubriendo modelo, servicios, persistencia, historial, funcionalidad de ayuno, notificaciones, stock y pantallas de edición

**Cobertura global**: 45.7% (2710 de 5927 líneas)

**Nota sobre el Botiquín**: La funcionalidad del Botiquín (vista de inventario) está implementada y funcional, pero no tiene tests dedicados ya que utiliza los mismos componentes y datos que el resto de la aplicación (lectura de base de datos, UI de lista, búsqueda). La funcionalidad es verificada manualmente.

### Mejoras recientes en la suite de tests

- **Nuevos tests de pantallas de edición** (74 tests): Suite completa que cubre todas las pantallas de edición de medicamentos
  - **EditQuantityScreen** (18 tests): validación de cantidad y umbral de stock
  - **EditScheduleScreen** (15 tests): gestión de horarios y cantidades de tomas
  - **EditFastingScreen** (18 tests): configuración completa de ayuno
  - **EditDurationScreen** (23 tests): gestión de fechas y duración de tratamiento
  - Cobertura mejorada: 43.8% → 45.7% (+1.9%)
  - Estrategia de tests enfocada en validación sin operaciones de guardado completo para evitar timeouts
  - Uso de `ensureVisible()` para elementos fuera de pantalla en tests de navegación
- **Nuevos tests de cancelación de notificaciones** (11 tests): Suite completa que verifica la cancelación inteligente de notificaciones cuando se registra una toma manual
  - Cubre todos los tipos de duración de tratamiento
  - Verifica cancelación de notificaciones pospuestas
  - Prueba casos edge y manejo de errores
- **Nuevos tests de programación de notificaciones de ayuno** (13 tests): Suite que verifica la lógica de programación automática vs dinámica
  - Notificaciones "before" se programan automáticamente
  - Notificaciones "after" solo se programan cuando se toma el medicamento
  - Usa hora real de toma, no hora programada
- **Corrección de timeouts**: Reemplazado `pumpAndSettle()` con `pump()` explícitos en el helper `addMedicationWithDuration` y en tests de validación para evitar problemas de timeout con animaciones de modales y operaciones asíncronas
- **Verificación indirecta de SnackBars**: Implementada estrategia de verificación indirecta para casos donde los SnackBars no son confiables en tests automatizados, verificando el comportamiento mediante el estado de la UI (modales cerrados, diálogos no mostrados, etc.)
- **Finders específicos**: Uso de finders descendientes para evitar ambigüedades al buscar widgets con textos duplicados
- **Tests con fechas reales**: Los tests de ordenamiento (`medication_sorting_test.dart`) ahora usan `DateTime.now()` en lugar de fechas fijas para compatibilidad con el modelo `Medication` que usa tiempo real internamente. Esto asegura que las validaciones de fecha (`takenDosesDate`, `shouldTakeToday()`, etc.) funcionen correctamente
- **Todos los tests pasan**: La suite completa de 263 tests ahora pasa exitosamente sin fallos
