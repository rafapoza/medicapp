# MedicApp

Una aplicación móvil desarrollada en Flutter para la gestión personal de medicamentos.

## Descripción

MedicApp permite a los usuarios llevar un registro organizado de sus medicamentos de forma sencilla e intuitiva. La aplicación ofrece funcionalidades CRUD (Crear, Leer, Actualizar, Eliminar) para gestionar una lista personalizada de medicamentos, incluyendo la duración de cada tratamiento.

## Características principales

- **Registro de medicamentos**: Añade nuevos medicamentos a tu lista con un flujo guiado de dos pasos
- **Tipos de medicamento**: Clasifica cada medicamento por su formato (pastilla, jarabe, inyección, cápsula, crema, gotas, spray, inhalador, parche, supositorio) con iconos representativos
- **Duración del tratamiento**: Define cuánto tiempo tomarás cada medicamento:
  - **Todos los días**: Para tratamientos continuos sin fecha de finalización
  - **Hasta acabar la medicación**: Para tratamientos que terminarán cuando se acabe el medicamento
  - **Personalizado**: Especifica el número exacto de días del tratamiento (1-365 días)
- **Edición completa**: Modifica tanto la información básica como la duración del tratamiento
- **Eliminación**: Elimina medicamentos de tu lista
- **Validación inteligente**:
  - Previene la creación de medicamentos duplicados (case-insensitive)
  - Valida rangos de días en tratamientos personalizados
- **Interfaz responsiva**:
  - Diseño moderno con Material Design 3
  - Layout adaptable que muestra 3 tipos de medicamento por fila en todos los dispositivos
  - Scroll optimizado para pantallas pequeñas
- **Visualización detallada**: Cada medicamento muestra su tipo, nombre y duración del tratamiento en la lista

## Tecnologías

- Flutter 3.9.2+
- Dart
- Material Design 3

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
├── models/
│   ├── medication.dart                 # Modelo principal de medicamento
│   ├── medication_type.dart            # Enum de tipos de medicamento
│   └── treatment_duration_type.dart    # Enum de tipos de duración de tratamiento
├── screens/
│   ├── medication_list_screen.dart     # Pantalla principal con lista de medicamentos
│   ├── add_medication_screen.dart      # Pantalla para añadir medicamento (paso 1)
│   ├── edit_medication_screen.dart     # Pantalla para editar medicamento
│   └── treatment_duration_screen.dart  # Pantalla de duración del tratamiento (paso 2)
├── main.dart                            # Punto de entrada
└── test/
    └── widget_test.dart                 # Suite completa de tests
```

## Flujo de uso

### Añadir un medicamento

1. **Paso 1 - Información básica**: Introduce el nombre del medicamento y selecciona su tipo
2. **Paso 2 - Duración del tratamiento**: Selecciona cuánto tiempo tomarás el medicamento
   - Todos los días (sin límite)
   - Hasta acabar la medicación
   - Personalizado (introduce el número de días)
3. El medicamento se añade a tu lista con toda la información

### Editar un medicamento

1. Toca el medicamento que quieres editar
2. En el modal, selecciona "Editar medicamento"
3. Modifica la información básica (nombre y tipo)
4. Actualiza la duración del tratamiento si es necesario
5. Los cambios se guardan automáticamente

### Eliminar un medicamento

1. Toca el medicamento que quieres eliminar
2. En el modal, selecciona "Eliminar medicamento"
3. El medicamento se elimina de tu lista
