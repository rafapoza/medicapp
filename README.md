# MedicApp

Una aplicación móvil desarrollada en Flutter para la gestión personal de medicamentos.

## Descripción

MedicApp permite a los usuarios llevar un registro organizado de sus medicamentos de forma sencilla e intuitiva. La aplicación ofrece funcionalidades CRUD (Crear, Leer, Actualizar, Eliminar) para gestionar una lista personalizada de medicamentos.

## Características principales

- **Registro de medicamentos**: Añade nuevos medicamentos a tu lista
- **Tipos de medicamento**: Clasifica cada medicamento por su formato (pastilla, jarabe, inyección, etc.) con iconos representativos
- **Edición**: Modifica la información de medicamentos existentes
- **Eliminación**: Elimina medicamentos de tu lista
- **Validación**: Previene la creación de medicamentos duplicados
- **Interfaz intuitiva**: Diseño moderno con Material Design 3

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
├── models/          # Modelos de datos
├── screens/         # Pantallas de la aplicación
└── main.dart        # Punto de entrada
```
