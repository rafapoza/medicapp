# Estructura del proyecto

```
lib/
├── database/
│   └── database_helper.dart            # Gestión de base de datos SQLite (singleton)
├── models/
│   ├── medication.dart                 # Modelo principal de medicamento
│   ├── medication_type.dart            # Enum de tipos de medicamento con unidades de stock
│   ├── treatment_duration_type.dart    # Enum de tipos de duración de tratamiento
│   └── dose_history_entry.dart         # Modelo para historial de dosis
├── screens/
│   ├── medication_list_screen.dart     # Pantalla principal con lista de medicamentos
│   ├── medication_stock_screen.dart    # Pantalla de Pastillero con gestión de inventario
│   ├── dose_action_screen.dart         # Pantalla de acciones desde notificación
│   ├── dose_history_screen.dart        # Pantalla de historial de dosis
│   ├── add_medication_screen.dart      # Pantalla para añadir medicamento (paso 1)
│   ├── edit_medication_screen.dart     # Pantalla para editar medicamento
│   ├── treatment_duration_screen.dart  # Pantalla de duración del tratamiento (paso 2)
│   ├── treatment_dates_screen.dart     # Pantalla de fechas de tratamiento
│   └── medication_schedule_screen.dart # Pantalla de programación de horarios (paso 3)
├── services/
│   └── notification_service.dart       # Servicio de notificaciones locales (singleton)
├── main.dart                            # Punto de entrada con inicialización de notificaciones
└── test/
    ├── medication_model_test.dart       # Tests del modelo de medicamento (19 tests)
    ├── notification_service_test.dart   # Tests del servicio de notificaciones
    ├── database_refill_test.dart        # Tests de persistencia de recargas (7 tests)
    ├── dose_management_test.dart        # Tests de historial de dosis
    └── widget_test.dart                 # Tests de widgets e integración (80+ tests)
```
