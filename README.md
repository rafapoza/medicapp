# MedicApp

Una aplicación móvil desarrollada en Flutter para la gestión personal de medicamentos.

## Descripción

MedicApp permite a los usuarios llevar un registro organizado de sus medicamentos de forma sencilla e intuitiva. La aplicación ofrece funcionalidades CRUD (Crear, Leer, Actualizar, Eliminar) para gestionar una lista personalizada de medicamentos, incluyendo la duración de cada tratamiento.

## Características principales

- **Persistencia de datos**: Tus medicamentos se guardan localmente en SQLite y persisten entre sesiones
- **Registro de medicamentos**: Añade nuevos medicamentos a tu lista con un flujo guiado de tres pasos
- **Tipos de medicamento**: Clasifica cada medicamento por su formato (pastilla, jarabe, inyección, cápsula, crema, gotas, spray, inhalador, parche, supositorio) con iconos representativos
- **Frecuencia de tomas**: Define cada cuántas horas tomarás el medicamento (1, 2, 3, 4, 6, 8, 12, 24 horas)
- **Programación de horarios**:
  - Establece las horas exactas de cada toma del día
  - Define la cantidad específica de medicamento para cada toma (dosis variables)
  - Unidades de medida específicas según el tipo de medicamento (pastillas, ml, gramos, etc.)
  - El sistema calcula automáticamente el número de tomas según la frecuencia
  - Validación de horas duplicadas con indicadores visuales
  - Formato de 24 horas para mayor precisión
- **Duración del tratamiento**: Define cuánto tiempo tomarás cada medicamento:
  - **Todos los días**: Para tratamientos continuos sin fecha de finalización
  - **Hasta acabar la medicación**: Para tratamientos que terminarán cuando se acabe el medicamento
  - **Personalizado**: Especifica el número exacto de días del tratamiento (1-365 días)
- **Registro de tomas**: Sistema completo e inteligente para registrar cuando tomas tus medicamentos
  - Botón "Registrar toma" accesible desde cada medicamento
  - Selección del horario específico que acabas de tomar
  - Sistema inteligente de tomas restantes:
    - Rastrea qué tomas ya se han tomado hoy
    - Solo muestra las tomas pendientes del día actual
    - Registro automático si solo queda una toma pendiente
    - Mensaje de confirmación al completar todas las tomas del día
  - Descuento automático de stock según la cantidad específica de cada toma
  - Validación de stock disponible para la dosis específica antes de permitir el registro
  - Validación de tomas disponibles (no permite registrar más tomas de las programadas)
  - Confirmación visual con stock restante y tomas pendientes
  - Reprogramación automática de notificaciones tras cada registro
- **Gestión de stock (Pastillero)**: Control completo del inventario de medicamentos
  - Registra la cantidad disponible de cada medicamento con unidades específicas (pastillas, ml, gramos, óvulos, aplicaciones, gotas)
  - Pantalla dedicada "Pastillero" con vista general del inventario
  - Indicadores visuales de estado: disponible (verde), stock bajo (naranja), sin stock (rojo)
  - Cálculo automático de duración estimada considerando dosis variables por toma
  - Stock bajo detectado automáticamente cuando quedan menos de 3 días de medicamento (basado en dosis diaria total)
  - Tarjetas resumen con totales, medicamentos con stock bajo y sin stock
- **Próxima toma**: Visualiza la hora de la siguiente toma de cada medicamento en la lista principal
- **Notificaciones push**: Recibe recordatorios automáticos en cada hora de toma programada
  - Notificaciones locales programadas para cada horario del medicamento
  - Se repiten diariamente a la misma hora
  - Incluyen el nombre y tipo del medicamento
  - Se reprograman automáticamente al editar medicamentos
  - Se cancelan automáticamente al eliminar medicamentos
- **Edición completa**: Modifica tanto la información básica como la duración del tratamiento y horarios
- **Eliminación**: Elimina medicamentos de tu lista
- **Validación inteligente**:
  - Previene la creación de medicamentos duplicados (case-insensitive)
  - Valida rangos de días en tratamientos personalizados
  - Valida frecuencias de tomas que dividan 24 horas exactamente
  - Previene horarios duplicados con alertas visuales
  - Valida que las cantidades de stock sean no negativas
- **Interfaz responsiva**:
  - Diseño moderno con Material Design 3
  - Layout adaptable que muestra 3 tipos de medicamento por fila en todos los dispositivos
  - Scroll optimizado para pantallas pequeñas
  - Pull-to-refresh en pantalla de Pastillero
- **Visualización detallada**: Cada medicamento muestra su tipo, nombre, duración del tratamiento y próxima toma
- **Indicadores visuales de stock**: Alertas en pantalla principal para medicamentos con problemas de stock
  - Icono rojo de error cuando el medicamento se ha agotado (stock = 0)
  - Icono naranja de advertencia cuando el stock es bajo (menos de 3 días de medicamento)
  - Sin indicador cuando el stock es suficiente
  - Toca el indicador para ver detalles: cantidad exacta y duración estimada en días

## Tecnologías

- Flutter 3.9.2+
- Dart
- Material Design 3
- SQLite (sqflite 2.3.0) - Base de datos local para persistencia
- sqflite_common_ffi 2.3.0 - Para tests en desktop/VM
- flutter_local_notifications 17.0.0 - Sistema de notificaciones locales
- timezone 0.9.2 - Gestión de zonas horarias para notificaciones programadas


## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/rafapoza/medicapp.git

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## Tests

El proyecto incluye una suite completa de tests de widgets:

```bash
flutter test
```

## Estructura del proyecto

```
lib/
├── database/
│   └── database_helper.dart            # Gestión de base de datos SQLite (singleton)
├── models/
│   ├── medication.dart                 # Modelo principal de medicamento
│   ├── medication_type.dart            # Enum de tipos de medicamento con unidades de stock
│   └── treatment_duration_type.dart    # Enum de tipos de duración de tratamiento
├── screens/
│   ├── medication_list_screen.dart     # Pantalla principal con lista de medicamentos
│   ├── medication_stock_screen.dart    # Pantalla de Pastillero con gestión de inventario
│   ├── add_medication_screen.dart      # Pantalla para añadir medicamento (paso 1)
│   ├── edit_medication_screen.dart     # Pantalla para editar medicamento
│   ├── treatment_duration_screen.dart  # Pantalla de duración del tratamiento (paso 2)
│   └── medication_schedule_screen.dart # Pantalla de programación de horarios (paso 3)
├── services/
│   └── notification_service.dart       # Servicio de notificaciones locales (singleton)
├── main.dart                            # Punto de entrada con inicialización de notificaciones
└── test/
    └── widget_test.dart                 # Suite completa de tests con persistencia
```

## Base de datos

La aplicación utiliza SQLite para almacenar localmente todos los medicamentos. Los datos persisten entre sesiones de la aplicación.

### Características de la base de datos:

- **Patrón Singleton**: Una única instancia de `DatabaseHelper` gestiona todas las operaciones
- **CRUD completo**: Create, Read, Update, Delete
- **Tabla medications** (versión 5):
  - `id` (TEXT PRIMARY KEY)
  - `name` (TEXT NOT NULL)
  - `type` (TEXT NOT NULL)
  - `dosageIntervalHours` (INTEGER NOT NULL)
  - `durationType` (TEXT NOT NULL)
  - `customDays` (INTEGER NULLABLE)
  - `doseTimes` (TEXT NOT NULL) - Horarios de tomas en formato "HH:mm" separados por comas (generado automáticamente desde doseSchedule para compatibilidad)
  - `doseSchedule` (TEXT NOT NULL) - Horarios y cantidades en formato JSON: {"HH:mm": cantidad, ...}
  - `stockQuantity` (REAL NOT NULL DEFAULT 0) - Cantidad de medicamento disponible
  - `takenDosesToday` (TEXT NOT NULL DEFAULT '') - Horarios de tomas registradas hoy
  - `takenDosesDate` (TEXT NULLABLE) - Fecha de las tomas registradas en formato "yyyy-MM-dd"
- **Migraciones**: Sistema de versionado para actualizar el esquema sin perder datos
  - Versión 1 → 2: Añadidos campos de duración de tratamiento y horarios de tomas
  - Versión 2 → 3: Añadido campo de cantidad de stock (stockQuantity)
  - Versión 3 → 4: Añadidos campos para rastrear tomas diarias (takenDosesToday, takenDosesDate)
  - Versión 4 → 5: Añadido campo doseSchedule para soportar dosis variables por toma
- **Compatibilidad**: Migración automática de datos legacy (doseTimes) a nuevo formato (doseSchedule)
- **Testing**: Los tests utilizan una base de datos en memoria para aislamiento completo

## Sistema de notificaciones

La aplicación utiliza `flutter_local_notifications` para enviar recordatorios automáticos de cada toma de medicamento.

### Características del sistema de notificaciones:

- **Notificaciones programadas**: Cada horario de toma genera una notificación que se repite diariamente
- **Gestión automática**:
  - Al añadir un medicamento, se programan automáticamente todas sus notificaciones
  - Al editar un medicamento, se reprograman sus notificaciones con los nuevos horarios
  - Al eliminar un medicamento, se cancelan todas sus notificaciones pendientes
- **Persistencia**: Las notificaciones sobreviven al reinicio del dispositivo
- **Patrón Singleton**: Una única instancia de `NotificationService` gestiona todas las operaciones
- **Zona horaria**: Configurada para España (Europe/Madrid) por defecto
- **Identificación única**: Cada toma de cada medicamento tiene un ID único para evitar conflictos
- **Permisos avanzados**:
  - Solicita automáticamente permisos de notificaciones al iniciar la app
  - Verifica el estado de los permisos en tiempo real
  - Soporta alarmas exactas en Android 12+ con permisos `SCHEDULE_EXACT_ALARM` y `USE_EXACT_ALARM`
  - Logs detallados para diagnosticar problemas de permisos
- **Manejo inteligente de horarios**:
  - Si un horario ya pasó hoy, la notificación se programa para el día siguiente
  - Soporte para alarmas exactas e inexactas (fallback automático)
  - Logs de depuración para cada notificación programada
- **Compatibilidad**: Funciona en Android (incluido Android 13+) e iOS

### Contenido de las notificaciones:

- **Título**: "💊 Hora de tomar tu medicamento"
- **Cuerpo**: Nombre del medicamento y tipo (ej: "Paracetamol - Pastilla")
- **Hora**: Programada según los horarios configurados para cada medicamento

### Herramientas de depuración:

La app incluye herramientas de diagnóstico para desarrolladores accesibles desde un menú oculto:

**Activar el menú de depuración:**
- Toca 5 veces consecutivas el título "Mis Medicamentos" en la pantalla principal (máximo 2 segundos entre toques)
- El menú aparecerá en la esquina superior derecha (⋮)
- Para ocultarlo nuevamente, toca otras 5 veces consecutivas el título

**Opciones del menú de depuración:**

- **Probar notificación**: Envía una notificación inmediata para verificar permisos
- **Probar programada (1 min)**: Programa una notificación de prueba para 1 minuto en el futuro
- **Reprogramar notificaciones**: Reprograma manualmente todas las notificaciones de medicamentos
- **Info de notificaciones**: Muestra información detallada:
  - Estado de permisos otorgados
  - Número de notificaciones pendientes
  - Lista completa de notificaciones programadas
  - Medicamentos con horarios configurados

### Requisitos de permisos en Android:

Para que las notificaciones funcionen correctamente en Android, es posible que necesites:

1. **Android 13+**: Permitir notificaciones desde la configuración de la app
2. **Android 12+**: Permitir alarmas exactas en:
   - Configuración → Apps → MedicApp → Alarmas y recordatorios → Permitir
3. **Optimización de batería**: Desactivar la optimización de batería para la app:
   - Configuración → Apps → MedicApp → Batería → Sin restricciones

## Flujo de uso

### Añadir un medicamento

1. Toca el botón flotante (+) en la esquina inferior derecha de la pantalla principal
2. Selecciona "Añadir medicamento" en el menú que aparece
3. **Paso 1 - Información básica**: Introduce el nombre del medicamento, la frecuencia de tomas (cada cuántas horas), la cantidad disponible (stock) y selecciona su tipo
   - Las unidades de stock se ajustan automáticamente según el tipo de medicamento (pastillas, ml, gramos, etc.)
4. **Paso 2 - Duración del tratamiento**: Selecciona cuánto tiempo tomarás el medicamento
   - Todos los días (sin límite)
   - Hasta acabar la medicación
   - Personalizado (introduce el número de días)
5. **Paso 3 - Programación de horarios**: Define las horas exactas y cantidades de cada toma
   - El sistema calcula automáticamente el número de tomas según la frecuencia
   - Selecciona la hora de cada toma usando el selector de tiempo
   - Define la cantidad específica de medicamento para cada toma
   - Las unidades se ajustan automáticamente según el tipo de medicamento (pastillas, ml, gramos, etc.)
   - Validación automática de horarios duplicados y cantidades válidas
6. El medicamento se añade a tu lista con toda la información

### Editar un medicamento

1. Toca el medicamento que quieres editar
2. En el modal, selecciona "Editar medicamento"
3. Modifica la información básica (nombre, frecuencia de tomas, stock y tipo)
4. Actualiza la duración del tratamiento si es necesario
5. Ajusta los horarios y cantidades de las tomas en la pantalla de programación
6. Los cambios se guardan automáticamente

### Registrar una toma

1. Toca el medicamento del que quieres registrar una toma
2. En el modal, selecciona "Registrar toma"
3. Comportamiento inteligente según las tomas disponibles:
   - **Primera toma del día con múltiples dosis**: Selecciona cuál de tus horarios programados acabas de tomar
   - **Tomas sucesivas**: Solo se muestran los horarios que aún no has tomado hoy
   - **Última toma pendiente del día**: Se registra automáticamente sin preguntar
   - **Una sola toma al día**: Se registra automáticamente sin preguntar
4. El sistema automáticamente:
   - Rastrea qué tomas ya se han tomado hoy
   - Resetea el conteo de tomas al día siguiente
   - Resta la cantidad específica de la dosis de tu stock disponible
   - Actualiza el contador de medicamentos
   - Reprograma las notificaciones
   - Te muestra el stock restante y las tomas pendientes
5. Validaciones:
   - Si no tienes stock disponible, recibirás una alerta
   - Si no tienes suficiente stock para la cantidad de esa toma específica, recibirás un aviso
   - Si ya tomaste todas las dosis del día, recibirás un aviso
   - Si no tienes horarios configurados, recibirás un aviso

### Ver el Pastillero

1. Toca el botón flotante (+) en la esquina inferior derecha de la pantalla principal
2. Selecciona "Ver Pastillero" en el menú que aparece
3. Visualiza el estado del inventario:
   - Tarjetas resumen con totales generales
   - Lista detallada de cada medicamento con:
     - Stock actual con unidades específicas
     - Indicador visual de estado (verde/naranja/rojo)
     - Duración estimada del stock en días
4. Desliza hacia abajo para actualizar la información (pull-to-refresh)

### Eliminar un medicamento

1. Toca el medicamento que quieres eliminar
2. En el modal, selecciona "Eliminar medicamento"
3. El medicamento se elimina de tu lista
