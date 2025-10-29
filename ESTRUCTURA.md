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
│   └── notification_service.dart       # Servicio de notificaciones locales (singleton)
├── main.dart                            # Punto de entrada con inicialización de notificaciones
└── test/
    ├── medication_model_test.dart       # Tests del modelo de medicamento (19 tests)
    ├── notification_service_test.dart   # Tests del servicio de notificaciones
    ├── database_refill_test.dart        # Tests de persistencia de recargas (7 tests)
    ├── dose_management_test.dart        # Tests de historial de dosis
    └── widget_test.dart                 # Tests de widgets e integración (80+ tests)
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
