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
  - Tests de gestión de stock
  - Tests de registro de tomas con sistema inteligente
  - Tests de patrones de horario avanzado (semanal, fechas específicas)
  - 80+ tests cubriendo todos los flujos de la aplicación
- **test/dose_management_test.dart**: Tests del sistema de historial de dosis
  - Tests de creación de entradas de historial
  - Tests de consulta de historial por medicamento y rango de fechas
  - Tests de cálculo de estadísticas de adherencia
  - Tests de persistencia y recuperación de datos
  - Tests de integración con base de datos SQLite

**Total**: 120+ tests cubriendo modelo, servicios, persistencia, UI e historial
