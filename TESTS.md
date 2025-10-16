# Tests

El proyecto incluye una suite completa de tests:

```bash
flutter test
```

### Suite de tests incluida:

- **test/medication_model_test.dart**: Tests del modelo de medicamento
  - Grupo "Skipped Doses": 11 tests para gestión de dosis no tomadas
  - Grupo "Stock and Doses": 2 tests para cálculo de stock y dosis diarias
  - Grupo "Refill": 6 tests para funcionalidad de recarga
- **test/notification_service_test.dart**: Tests del servicio de notificaciones
  - Tests de singleton, inicialización, permisos
  - Programación de notificaciones de medicamentos
  - Notificaciones pospuestas (5 tests)
  - Modo de test
- **test/database_refill_test.dart**: Tests de persistencia de recargas
  - 7 tests de integración con base de datos SQLite
  - Verificación de persistencia de `lastRefillAmount`
  - Tests de actualización y compatibilidad
- **test/widget_test.dart**: Suite completa de tests de widgets e integración
  - Tests de navegación y UI
  - Tests de validación de formularios
  - Tests de CRUD de medicamentos
  - Tests de gestión de stock (incluyendo validación de stock vacío)
  - Tests de registro de tomas con sistema inteligente
  - Tests de indicadores de stock (iconos de advertencia y error)
  - Tests de menú de depuración
  - Tests de flujo modular de edición de medicamentos
  - 44 tests cubriendo los flujos principales de la aplicación
  - Implementa técnicas de verificación indirecta para casos donde los SnackBars no son confiables en tests
- **test/dose_management_test.dart**: Tests del sistema de historial de dosis
  - Tests de creación de entradas de historial
  - Tests de consulta de historial por medicamento y rango de fechas
  - Tests de cálculo de estadísticas de adherencia
  - Tests de persistencia y recuperación de datos
  - Tests de integración con base de datos SQLite

**Total**: 90+ tests cubriendo modelo, servicios, persistencia, UI e historial

### Mejoras recientes en la suite de tests

- **Corrección de timeouts**: Reemplazado `pumpAndSettle()` con `pump()` explícitos en el helper `addMedicationWithDuration` para evitar problemas de timeout con animaciones de modales
- **Verificación indirecta de SnackBars**: Implementada estrategia de verificación indirecta para casos donde los SnackBars no son confiables en tests automatizados, verificando el comportamiento mediante el estado de la UI (modales cerrados, diálogos no mostrados, etc.)
- **Finders específicos**: Uso de finders descendientes para evitar ambigüedades al buscar widgets con textos duplicados
- **Todos los tests pasan**: La suite completa de widget_test.dart (44 tests) ahora pasa exitosamente sin fallos
