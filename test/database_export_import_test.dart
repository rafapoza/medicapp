import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicapp/database/database_helper.dart';
import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'helpers/medication_builder.dart';

/// Mock de PathProviderPlatform para tests
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    // Usar directorio temporal del sistema
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    // Crear un directorio temporal para documentos
    final tempDir = Directory.systemTemp.createTempSync('medicapp_test_docs_');
    return tempDir.path;
  }
}

void main() {
  // Configuración inicial para todos los tests
  setUpAll(() {
    // Inicializar FFI para sqflite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Configurar mock de path provider
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  group('Database Export/Import - In-Memory Restrictions', () {
    setUp(() async {
      // Usar base de datos en memoria para estos tests
      DatabaseHelper.setInMemoryDatabase(true);
      await DatabaseHelper.resetDatabase();
    });

    tearDown(() async {
      await DatabaseHelper.resetDatabase();
    });

    test('should throw exception when trying to export in-memory database', () async {
      expect(
        () => DatabaseHelper.instance.exportDatabase(),
        throwsException,
      );
    });

    test('should throw exception when trying to import to in-memory database', () async {
      expect(
        () => DatabaseHelper.instance.importDatabase('/fake/path.db'),
        throwsException,
      );
    });
  });

  group('Database Export', () {
    late Directory testDbDir;
    late String testDbPath;

    setUp(() async {
      // Crear directorio temporal para base de datos de prueba
      testDbDir = await Directory.systemTemp.createTemp('medicapp_test_db_');
      testDbPath = join(testDbDir.path, 'medications.db');

      // Desactivar modo en memoria
      DatabaseHelper.setInMemoryDatabase(false);
      await DatabaseHelper.resetDatabase();

      // Limpiar todas las medicaciones antes de cada test
      await DatabaseHelper.instance.deleteAllMedications();
      await DatabaseHelper.instance.deleteAllDoseHistory();

      // Configurar la ruta de la base de datos para tests
      databaseFactory = databaseFactoryFfi;
    });

    tearDown(() async {
      // Limpiar datos antes de resetear
      await DatabaseHelper.instance.deleteAllMedications();
      await DatabaseHelper.instance.deleteAllDoseHistory();
      await DatabaseHelper.resetDatabase();

      // Limpiar directorio temporal
      if (await testDbDir.exists()) {
        await testDbDir.delete(recursive: true);
      }
    });

    test('should export database to a file', () async {
      // Insertar algunos datos de prueba
      final medication = MedicationBuilder()
          .withId('export_test_1')
          .withName('Test Medicine')
          .withType(MedicationType.pill)
          .withSingleDose('08:00', 1.0)
          .withStock(30.0)
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Exportar la base de datos
      final exportPath = await DatabaseHelper.instance.exportDatabase();

      // Verificar que el archivo fue creado
      final exportFile = File(exportPath);
      expect(await exportFile.exists(), isTrue);
      expect(await exportFile.length(), greaterThan(0));

      // Limpiar archivo exportado
      if (await exportFile.exists()) {
        await exportFile.delete();
      }
    });

    test('should throw exception when database file does not exist', () async {
      // Resetear la base de datos sin crear el archivo
      await DatabaseHelper.resetDatabase();

      // Eliminar el archivo de base de datos si existe
      final dbPath = await DatabaseHelper.instance.getDatabasePath();
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      // Intentar exportar debería fallar
      expect(
        () => DatabaseHelper.instance.exportDatabase(),
        throwsException,
      );
    });

    test('should create export file with timestamp in name', () async {
      // Insertar datos de prueba
      final medication = MedicationBuilder()
          .withId('export_test_2')
          .withName('Test Medicine 2')
          .build();

      await DatabaseHelper.instance.insertMedication(medication);

      // Exportar
      final exportPath = await DatabaseHelper.instance.exportDatabase();

      // Verificar que el nombre contiene el patrón esperado
      expect(exportPath, contains('medicapp_backup_'));
      expect(exportPath, endsWith('.db'));

      // Limpiar
      final exportFile = File(exportPath);
      if (await exportFile.exists()) {
        await exportFile.delete();
      }
    });
  });

  group('Database Import', () {
    late Directory testDbDir;
    late String testDbPath;

    setUp(() async {
      // Crear directorio temporal para base de datos de prueba
      testDbDir = await Directory.systemTemp.createTemp('medicapp_test_db_');
      testDbPath = join(testDbDir.path, 'medications.db');

      // Desactivar modo en memoria
      DatabaseHelper.setInMemoryDatabase(false);
      await DatabaseHelper.resetDatabase();

      // Limpiar todas las medicaciones antes de cada test
      await DatabaseHelper.instance.deleteAllMedications();
      await DatabaseHelper.instance.deleteAllDoseHistory();

      databaseFactory = databaseFactoryFfi;
    });

    tearDown(() async {
      // Limpiar datos antes de resetear
      await DatabaseHelper.instance.deleteAllMedications();
      await DatabaseHelper.instance.deleteAllDoseHistory();
      await DatabaseHelper.resetDatabase();

      // Limpiar directorio temporal
      if (await testDbDir.exists()) {
        await testDbDir.delete(recursive: true);
      }
    });

    test('should import database and preserve all data', () async {
      // Crear medicaciones de prueba
      final med1 = MedicationBuilder()
          .withId('import_test_1')
          .withName('Medicine 1')
          .withType(MedicationType.pill)
          .withSingleDose('08:00', 1.0)
          .withStock(30.0)
          .withLastRefill(50.0)
          .build();

      final med2 = MedicationBuilder()
          .withId('import_test_2')
          .withName('Medicine 2')
          .withType(MedicationType.syrup)
          .withSingleDose('20:00', 5.0)
          .withStock(100.0)
          .withFasting(type: 'after', duration: 120)
          .build();

      // Insertar medicaciones
      await DatabaseHelper.instance.insertMedication(med1);
      await DatabaseHelper.instance.insertMedication(med2);

      // Exportar base de datos
      final exportPath = await DatabaseHelper.instance.exportDatabase();

      // Limpiar base de datos actual
      await DatabaseHelper.instance.deleteAllMedications();
      final medsBeforeImport = await DatabaseHelper.instance.getAllMedications();
      expect(medsBeforeImport.length, 0);

      // Importar base de datos
      await DatabaseHelper.instance.importDatabase(exportPath);

      // Verificar que todos los datos fueron importados
      final medsAfterImport = await DatabaseHelper.instance.getAllMedications();
      expect(medsAfterImport.length, 2);

      final imported1 = medsAfterImport.firstWhere((m) => m.id == 'import_test_1');
      expect(imported1.name, 'Medicine 1');
      expect(imported1.type, MedicationType.pill);
      expect(imported1.stockQuantity, 30.0);
      expect(imported1.lastRefillAmount, 50.0);

      final imported2 = medsAfterImport.firstWhere((m) => m.id == 'import_test_2');
      expect(imported2.name, 'Medicine 2');
      expect(imported2.type, MedicationType.syrup);
      expect(imported2.stockQuantity, 100.0);
      expect(imported2.requiresFasting, isTrue);
      expect(imported2.fastingType, 'after');
      expect(imported2.fastingDurationMinutes, 120);

      // Limpiar archivo exportado
      final exportFile = File(exportPath);
      if (await exportFile.exists()) {
        await exportFile.delete();
      }
    });

    test('should throw exception when import file does not exist', () async {
      expect(
        () => DatabaseHelper.instance.importDatabase('/fake/nonexistent/path.db'),
        throwsException,
      );
    });

    test('should create backup before importing', () async {
      // Crear medicación inicial
      final originalMed = MedicationBuilder()
          .withId('backup_test_1')
          .withName('Original Medicine')
          .build();

      await DatabaseHelper.instance.insertMedication(originalMed);

      // Crear base de datos para importar
      final med2 = MedicationBuilder()
          .withId('backup_test_2')
          .withName('New Medicine')
          .build();

      // Exportar (esto creará un archivo temporal)
      await DatabaseHelper.instance.insertMedication(med2);
      final exportPath = await DatabaseHelper.instance.exportDatabase();

      // La importación debería crear un backup
      await DatabaseHelper.instance.importDatabase(exportPath);

      // Verificar que el backup fue creado
      final dbPath = await DatabaseHelper.instance.getDatabasePath();
      final backupPath = '$dbPath.backup';
      final backupFile = File(backupPath);

      // El backup debería existir
      expect(await backupFile.exists(), isTrue);

      // Limpiar
      final exportFile = File(exportPath);
      if (await exportFile.exists()) {
        await exportFile.delete();
      }
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    });

    test('should restore from backup if import fails', () async {
      // Crear medicación inicial
      final originalMed = MedicationBuilder()
          .withId('restore_test_1')
          .withName('Original Medicine')
          .build();

      await DatabaseHelper.instance.insertMedication(originalMed);

      // Crear archivo corrupto para importar
      final corruptFile = File(join(testDbDir.path, 'corrupt.db'));
      await corruptFile.writeAsString('This is not a valid database file');

      // Intentar importar debería fallar
      try {
        await DatabaseHelper.instance.importDatabase(corruptFile.path);
        fail('Should have thrown an exception');
      } catch (e) {
        // Esperamos que falle
        expect(e, isException);
      }

      // La base de datos original debería estar intacta
      final meds = await DatabaseHelper.instance.getAllMedications();
      expect(meds.length, 1);
      expect(meds[0].id, 'restore_test_1');
      expect(meds[0].name, 'Original Medicine');

      // Limpiar
      if (await corruptFile.exists()) {
        await corruptFile.delete();
      }
    });

    test('should replace current database with imported one', () async {
      // Crear medicaciones originales
      final originalMed1 = MedicationBuilder()
          .withId('replace_test_1')
          .withName('Original 1')
          .build();

      final originalMed2 = MedicationBuilder()
          .withId('replace_test_2')
          .withName('Original 2')
          .build();

      await DatabaseHelper.instance.insertMedication(originalMed1);
      await DatabaseHelper.instance.insertMedication(originalMed2);

      // Exportar
      final exportPath = await DatabaseHelper.instance.exportDatabase();

      // Cambiar base de datos actual
      await DatabaseHelper.instance.deleteAllMedications();
      final newMed = MedicationBuilder()
          .withId('replace_test_3')
          .withName('New Medicine')
          .build();
      await DatabaseHelper.instance.insertMedication(newMed);

      // Verificar estado antes de importar
      final medsBeforeImport = await DatabaseHelper.instance.getAllMedications();
      expect(medsBeforeImport.length, 1);
      expect(medsBeforeImport[0].id, 'replace_test_3');

      // Importar base de datos anterior
      await DatabaseHelper.instance.importDatabase(exportPath);

      // Verificar que la base de datos fue reemplazada
      final medsAfterImport = await DatabaseHelper.instance.getAllMedications();
      expect(medsAfterImport.length, 2);
      expect(medsAfterImport.any((m) => m.id == 'replace_test_1'), isTrue);
      expect(medsAfterImport.any((m) => m.id == 'replace_test_2'), isTrue);
      expect(medsAfterImport.any((m) => m.id == 'replace_test_3'), isFalse);

      // Limpiar
      final exportFile = File(exportPath);
      if (await exportFile.exists()) {
        await exportFile.delete();
      }
    });
  });

  group('Database Export/Import - Integration', () {
    late Directory testDbDir;

    setUp(() async {
      testDbDir = await Directory.systemTemp.createTemp('medicapp_test_db_');
      DatabaseHelper.setInMemoryDatabase(false);
      await DatabaseHelper.resetDatabase();

      // Limpiar todas las medicaciones antes de cada test
      await DatabaseHelper.instance.deleteAllMedications();
      await DatabaseHelper.instance.deleteAllDoseHistory();

      databaseFactory = databaseFactoryFfi;
    });

    tearDown(() async {
      // Limpiar datos antes de resetear
      await DatabaseHelper.instance.deleteAllMedications();
      await DatabaseHelper.instance.deleteAllDoseHistory();
      await DatabaseHelper.resetDatabase();
      if (await testDbDir.exists()) {
        await testDbDir.delete(recursive: true);
      }
    });

    test('should handle multiple export/import cycles', () async {
      // Ciclo 1: Crear y exportar
      final med1 = MedicationBuilder()
          .withId('cycle_test_1')
          .withName('Cycle Medicine 1')
          .build();
      await DatabaseHelper.instance.insertMedication(med1);
      final export1 = await DatabaseHelper.instance.exportDatabase();

      // Ciclo 2: Añadir más datos y exportar
      final med2 = MedicationBuilder()
          .withId('cycle_test_2')
          .withName('Cycle Medicine 2')
          .build();
      await DatabaseHelper.instance.insertMedication(med2);
      final export2 = await DatabaseHelper.instance.exportDatabase();

      // Importar primera exportación
      await DatabaseHelper.instance.importDatabase(export1);
      var meds = await DatabaseHelper.instance.getAllMedications();
      expect(meds.length, 1);
      expect(meds[0].id, 'cycle_test_1');

      // Importar segunda exportación
      await DatabaseHelper.instance.importDatabase(export2);
      meds = await DatabaseHelper.instance.getAllMedications();
      expect(meds.length, 2);

      // Limpiar
      await File(export1).delete();
      await File(export2).delete();
    });

    test('should preserve complex medication data through export/import', () async {
      final complexMed = MedicationBuilder()
          .withId('complex_test_1')
          .withName('Complex Medicine')
          .withType(MedicationType.injection)
          .withMultipleDoses(['08:00', '14:00', '20:00'], 2.5)
          .withStock(45.5)
          .withLastRefill(75.25)
          .withFasting(type: 'before', duration: 30)
          .withLowStockThreshold(7)
          .build();

      await DatabaseHelper.instance.insertMedication(complexMed);

      // Exportar e importar
      final exportPath = await DatabaseHelper.instance.exportDatabase();
      await DatabaseHelper.instance.deleteAllMedications();
      await DatabaseHelper.instance.importDatabase(exportPath);

      // Verificar todos los campos
      final imported = await DatabaseHelper.instance.getMedication('complex_test_1');
      expect(imported, isNotNull);
      expect(imported!.name, 'Complex Medicine');
      expect(imported.type, MedicationType.injection);
      expect(imported.doseSchedule.length, 3);
      expect(imported.doseSchedule['08:00'], 2.5);
      expect(imported.doseSchedule['14:00'], 2.5);
      expect(imported.doseSchedule['20:00'], 2.5);
      expect(imported.stockQuantity, 45.5);
      expect(imported.lastRefillAmount, 75.25);
      expect(imported.requiresFasting, isTrue);
      expect(imported.fastingType, 'before');
      expect(imported.fastingDurationMinutes, 30);
      expect(imported.lowStockThresholdDays, 7);

      // Limpiar
      await File(exportPath).delete();
    });
  });
}
