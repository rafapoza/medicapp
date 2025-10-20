# Tests

El proyecto incluye una suite completa de tests:

```bash
flutter test
```

### Suite de tests incluida:

- **test/medication_model_test.dart**: Tests del modelo de medicamento (19 tests)
  - Grupo "Skipped Doses": 11 tests para gestión de dosis no tomadas
  - Grupo "Stock and Doses": 2 tests para cálculo de stock y dosis diarias
  - Grupo "Refill": 6 tests para funcionalidad de recarga
- **test/notification_service_test.dart**: Tests del servicio de notificaciones (14 tests)
  - Tests de singleton, inicialización, permisos
  - Programación de notificaciones de medicamentos
  - Notificaciones pospuestas (5 tests)
  - Modo de test
- **test/database_refill_test.dart**: Tests de persistencia de recargas (7 tests)
  - Integración con base de datos SQLite
  - Verificación de persistencia de `lastRefillAmount`
  - Tests de actualización y compatibilidad
- **test/widget_test.dart**: Suite completa de tests de widgets e integración (44 tests)
  - Tests de navegación y UI
  - Tests de validación de formularios
  - Tests de CRUD de medicamentos
  - Tests de gestión de stock (incluyendo validación de stock vacío)
  - Tests de registro de tomas con sistema inteligente
  - Tests de indicadores de stock (iconos de advertencia y error)
  - Tests de menú de depuración
  - Tests de flujo modular de edición de medicamentos
  - Implementa técnicas de verificación indirecta para casos donde los SnackBars no son confiables en tests
- **test/dose_management_test.dart**: Tests del sistema de historial de dosis (12 tests)
  - Tests de creación de entradas de historial
  - Tests de consulta de historial por medicamento y rango de fechas
  - Tests de cálculo de estadísticas de adherencia
  - Tests de persistencia y recuperación de datos
  - Tests de integración con base de datos SQLite
- **test/fasting_test.dart**: Tests de configuración de ayuno (15 tests)
  - Funcionalidad completa de ayuno:
    - Configuración por defecto (sin ayuno)
    - Ayuno antes y después de la toma
    - Duración de ayuno en minutos
    - Serialización y deserialización JSON
    - Compatibilidad con datos legacy (sin campos de ayuno)
    - Round-trip de encoding/decoding
    - Preservación de campos al actualizar
    - Validación de todos los tipos de medicamento
- **test/dynamic_fasting_notification_test.dart**: Tests de notificaciones dinámicas de ayuno (12 tests)
  - Notificaciones basadas en hora real de toma:
    - Programación correcta para ayuno tipo "after"
    - No programación para ayuno tipo "before"
    - Validaciones de configuración (requiresFasting, notifyFasting, fastingDurationMinutes)
    - Diferentes duraciones de ayuno (30, 60, 90, 120, 180, 240 minutos)
    - Compatibilidad con todos los tipos de medicamento
    - Manejo de horas de toma pasadas y futuras
    - Medicamentos con múltiples horarios de toma
    - Compatibilidad con todos los tipos de duración de tratamiento
- **test/medication_sorting_test.dart**: Tests de ordenamiento de medicamentos (8 tests)
  - Sistema de priorización de medicamentos:
    - Ordenamiento por urgencia (dosis pendientes primero)
    - Priorización por retraso (más atrasadas primero)
    - Ordenamiento por proximidad para dosis futuras
    - Manejo de medicamentos sin próxima dosis
    - Priorización de pendientes sobre futuras
    - Manejo de múltiples dosis por medicamento
    - Soporte para patrones semanales y otros tipos de duración
    - Cálculo correcto de próxima dosis con DateTime
  - **Importante**: Los tests usan fechas y horas reales (`DateTime.now()`) para compatibilidad con el modelo `Medication` que usa tiempo real internamente

**Total**: 134 tests cubriendo modelo, servicios, persistencia, UI, historial, funcionalidad de ayuno y ordenamiento

### Mejoras recientes en la suite de tests

- **Corrección de timeouts**: Reemplazado `pumpAndSettle()` con `pump()` explícitos en el helper `addMedicationWithDuration` para evitar problemas de timeout con animaciones de modales
- **Verificación indirecta de SnackBars**: Implementada estrategia de verificación indirecta para casos donde los SnackBars no son confiables en tests automatizados, verificando el comportamiento mediante el estado de la UI (modales cerrados, diálogos no mostrados, etc.)
- **Finders específicos**: Uso de finders descendientes para evitar ambigüedades al buscar widgets con textos duplicados
- **Tests con fechas reales**: Los tests de ordenamiento (`medication_sorting_test.dart`) ahora usan `DateTime.now()` en lugar de fechas fijas para compatibilidad con el modelo `Medication` que usa tiempo real internamente. Esto asegura que las validaciones de fecha (`takenDosesDate`, `shouldTakeToday()`, etc.) funcionen correctamente
- **Todos los tests pasan**: La suite completa de tests ahora pasa exitosamente sin fallos
