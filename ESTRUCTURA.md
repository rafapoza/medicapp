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
│   ├── main_screen.dart                # Pantalla principal con NavigationRail
│   ├── medication_inventory_screen.dart# Vista unificada de inventario (tabs)
│   │
│   ├── # Pantallas principales modularizadas
│   ├── medication_list_screen.dart     # Pantalla principal con lista de medicamentos (1193 líneas)
│   │   └── medication_list/            # Módulos de medication_list
│   │       ├── widgets/                # Widgets reutilizables
│   │       │   ├── medication_card.dart
│   │       │   ├── battery_optimization_banner.dart
│   │       │   ├── empty_medications_view.dart
│   │       │   ├── today_doses_section.dart
│   │       │   └── debug_menu.dart
│   │       ├── dialogs/                # Diálogos modales
│   │       │   ├── medication_options_sheet.dart
│   │       │   ├── dose_selection_dialog.dart
│   │       │   ├── manual_dose_input_dialog.dart
│   │       │   ├── refill_input_dialog.dart
│   │       │   ├── edit_today_dose_dialog.dart
│   │       │   ├── notification_permission_dialog.dart
│   │       │   └── debug_info_dialog.dart
│   │       └── services/               # Servicios específicos
│   │           └── dose_calculation_service.dart
│   │
│   ├── medicine_cabinet_screen.dart    # Pantalla de Botiquín (151 líneas)
│   │   └── medicine_cabinet/           # Módulos de medicine_cabinet
│   │       └── widgets/
│   │           ├── medication_card.dart
│   │           ├── empty_cabinet_view.dart
│   │           ├── no_search_results_view.dart
│   │           └── medication_options_modal.dart
│   │
│   ├── medication_stock_screen.dart    # Pantalla de Pastillero
│   │
│   ├── dose_action_screen.dart         # Pantalla de acciones desde notificación (281 líneas)
│   │   └── dose_action/                # Módulos de dose_action
│   │       └── widgets/
│   │           ├── medication_header_card.dart
│   │           ├── take_dose_button.dart
│   │           ├── skip_dose_button.dart
│   │           └── postpone_buttons.dart
│   │
│   ├── dose_history_screen.dart        # Pantalla de historial de dosis (292 líneas)
│   │   └── dose_history/               # Módulos de dose_history
│   │       ├── widgets/
│   │       │   ├── stat_card.dart
│   │       │   ├── dose_history_card.dart
│   │       │   ├── filter_dialog.dart
│   │       │   ├── statistics_card.dart
│   │       │   ├── active_filters_chip.dart
│   │       │   └── empty_history_view.dart
│   │       └── dialogs/
│   │           ├── edit_entry_dialog.dart
│   │           └── delete_confirmation_dialog.dart
│   │
│   ├── # Flujo modular de añadir medicamento (7 pasos)
│   ├── medication_info_screen.dart     # Paso 1: Información básica (121 líneas)
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
│   ├── notification_service.dart       # Servicio de notificaciones locales (singleton)
│   ├── dose_action_service.dart        # Servicio de registro de dosis (taken/skipped/manual/extra)
│   ├── dose_history_service.dart       # Servicio de gestión de historial
│   └── preferences_service.dart        # Servicio de preferencias de usuario
├── main.dart                            # Punto de entrada con inicialización de notificaciones
└── test/                                # Suite completa de tests (434 tests)
    ├── # Tests de modelos (2 tests)
    ├── medication_model_test.dart       # Modelo de medicamento, cálculo de stock
    │
    ├── # Tests de servicios (80 tests)
    ├── notification_service_test.dart   # Notificaciones, permisos, postpone, ongoing (42 tests)
    ├── dose_action_service_test.dart    # Registro de dosis, validaciones (28 tests)
    ├── dose_history_service_test.dart   # Historial, eliminación, cambio estado (12 tests)
    ├── preferences_service_test.dart    # Preferencias de usuario (12 tests)
    │
    ├── # Tests de database y persistencia (18 tests)
    ├── database_refill_test.dart        # Persistencia de recargas (6 tests)
    ├── database_export_import_test.dart # Export/import con backup (12 tests)
    │
    ├── # Tests de funcionalidad principal (104 tests)
    ├── dose_management_test.dart        # Historial de dosis, eliminación (11 tests)
    ├── extra_dose_test.dart             # Tomas excepcionales (13 tests)
    ├── notification_cancellation_test.dart # Cancelación inteligente (11 tests)
    ├── early_dose_notification_test.dart # Reprogramación de dosis tempranas (5 tests)
    ├── early_dose_with_fasting_test.dart # Dosis tempranas con ayuno (8 tests)
    ├── medication_sorting_test.dart     # Ordenamiento por urgencia (6 tests)
    ├── as_needed_stock_test.dart        # Stock para ocasionales (15 tests)
    ├── as_needed_main_screen_display_test.dart # Display de ocasionales (10 tests)
    │
    ├── # Tests de funcionalidad de ayuno (40 tests)
    ├── fasting_test.dart                # Configuración de ayuno (13 tests)
    ├── fasting_countdown_test.dart      # Cuenta atrás visual (14 tests)
    ├── dynamic_fasting_notification_test.dart # Notificaciones dinámicas (13 tests)
    ├── fasting_notification_scheduling_test.dart # Programación de ayuno (13 tests)
    │
    ├── # Tests de pantallas de edición (74 tests)
    ├── edit_screens_validation_test.dart # EditQuantityScreen (18 tests)
    ├── edit_schedule_screen_test.dart   # EditScheduleScreen (15 tests)
    ├── edit_fasting_screen_test.dart    # EditFastingScreen (18 tests)
    ├── edit_duration_screen_test.dart   # EditDurationScreen (23 tests)
    │
    ├── # Tests de widgets principales (20 tests)
    ├── dose_action_screen_test.dart     # Pantalla de acciones de dosis (20 tests)
    │
    ├── # Tests de integración (45 tests)
    └── integration/                     # Suite modular de tests de integración
        ├── helpers/                     # Helpers compartidos i18n
        ├── delete_medication_test.dart
        ├── dose_registration_test.dart
        ├── edit_medication_test.dart
        ├── medication_modal_test.dart
        ├── navigation_test.dart
        └── stock_management_test.dart
```

## Arquitectura Modular

### Principios aplicados
- **KISS (Keep It Simple)**: Cada componente tiene una única responsabilidad
- **DRY (Don't Repeat Yourself)**: Widgets reutilizables entre pantallas
- **Separación de responsabilidades**: Lógica de negocio separada de la presentación
- **Feature-based organization**: Módulos organizados por funcionalidad

### Resultados de la modularización
| Pantalla | Antes | Después | Reducción |
|----------|-------|---------|-----------|
| medication_list_screen.dart | 1,666 | 1,193 | -28.4% |
| medicine_cabinet_screen.dart | 606 | 151 | -75.1% |
| dose_history_screen.dart | 618 | 292 | -52.8% |
| medication_info_screen.dart | 135 | 121 | -10.4% |
| dose_action_screen.dart | 489 | 281 | -42.5% |
| **TOTAL** | **3,227** | **1,959** | **-39.3%** |

### Beneficios
✅ **Mantenibilidad**: Código más organizado y fácil de mantener
✅ **Reusabilidad**: Widgets compartidos entre múltiples pantallas
✅ **Testabilidad**: Componentes más pequeños y fáciles de probar
✅ **Escalabilidad**: Estructura preparada para crecimiento futuro
✅ **Legibilidad**: Archivos más cortos y enfocados
