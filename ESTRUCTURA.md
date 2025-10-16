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
│   │
│   ├── # Flujo modular de añadir medicamento (7 pasos)
│   ├── medication_info_screen.dart     # Paso 1: Información básica (nombre, tipo)
│   ├── medication_duration_screen.dart # Paso 2: Tipo de duración del tratamiento
│   ├── medication_dates_screen.dart    # Paso 3: Fechas del tratamiento
│   ├── medication_frequency_screen.dart# Paso 4: Frecuencia de medicación
│   ├── medication_dosage_screen.dart   # Paso 5: Configuración de dosis
│   ├── medication_times_screen.dart    # Paso 6: Horario de tomas
│   ├── medication_quantity_screen.dart # Paso 7: Cantidad de medicamento
│   │
│   ├── # Flujo modular de edición
│   ├── edit_medication_menu_screen.dart# Menú de selección de sección a editar
│   └── edit_sections/                  # Pantallas de edición por sección
│       ├── edit_basic_info_screen.dart # Editar información básica
│       ├── edit_duration_screen.dart   # Editar duración del tratamiento
│       ├── edit_frequency_screen.dart  # Editar frecuencia
│       ├── edit_schedule_screen.dart   # Editar horarios y cantidades
│       └── edit_quantity_screen.dart   # Editar cantidad disponible
│   │
│   ├── # Selectores especializados
│   ├── specific_dates_selector_screen.dart # Selector de fechas específicas
│   └── weekly_days_selector_screen.dart    # Selector de días de la semana
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
