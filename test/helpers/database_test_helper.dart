import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Helper para configurar y limpiar la base de datos en tests.
///
/// Ejemplo de uso:
/// ```dart
/// void main() {
///   DatabaseTestHelper.setupAll();
///   DatabaseTestHelper.setupEach();
///
///   test('mi test', () async {
///     // tu test aquí
///   });
/// }
/// ```
class DatabaseTestHelper {
  /// Configura la base de datos para todos los tests en un grupo.
  /// Debe llamarse con setUpAll() una sola vez por archivo de test.
  static void setupAll() {
    setUpAll(() {
      // Inicializar FFI para sqflite
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Usar base de datos en memoria para tests
      DatabaseHelper.setInMemoryDatabase(true);
    });
  }

  /// Limpia la base de datos después de cada test.
  /// Debe llamarse con tearDown() en cada grupo de tests.
  static void setupEach() {
    tearDown(() async {
      await cleanDatabase();
    });
  }

  /// Limpia todos los datos de la base de datos.
  static Future<void> cleanDatabase() async {
    await DatabaseHelper.instance.deleteAllMedications();
    await DatabaseHelper.instance.deleteAllDoseHistory();
    await DatabaseHelper.resetDatabase();
  }

  /// Configura completamente la base de datos (setUpAll + tearDown).
  /// Atazo para configurar todo con una sola llamada.
  static void setup() {
    setupAll();
    setupEach();
  }
}
