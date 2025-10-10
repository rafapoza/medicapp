import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _useInMemory = false; // For testing

  DatabaseHelper._init();

  // Set to use in-memory database for testing
  static void setInMemoryDatabase(bool inMemory) {
    _useInMemory = inMemory;
    _database = null; // Reset database when switching modes
  }

  // Reset database instance (useful for testing)
  static Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_useInMemory ? ':memory:' : 'medications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (_useInMemory || filePath == ':memory:') {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        // Debug: Check database schema
        final result = await db.rawQuery('PRAGMA table_info(medications)');
        print('Database columns: ${result.map((e) => e['name']).toList()}');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';
    const realType = 'REAL NOT NULL DEFAULT 0';

    await db.execute('''
      CREATE TABLE medications (
        id $idType,
        name $textType,
        type $textType,
        dosageIntervalHours $integerType,
        durationType $textType,
        customDays $integerNullableType,
        doseTimes $textType,
        doseSchedule $textType,
        stockQuantity $realType,
        takenDosesToday $textType,
        skippedDosesToday $textType,
        takenDosesDate $textNullableType
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add doseTimes column for version 2
      await db.execute('''
        ALTER TABLE medications ADD COLUMN doseTimes TEXT NOT NULL DEFAULT ''
      ''');
    }

    if (oldVersion < 3) {
      // Add stockQuantity column for version 3
      await db.execute('''
        ALTER TABLE medications ADD COLUMN stockQuantity REAL NOT NULL DEFAULT 0
      ''');
    }

    if (oldVersion < 4) {
      // Add takenDosesToday and takenDosesDate columns for version 4
      await db.execute('''
        ALTER TABLE medications ADD COLUMN takenDosesToday TEXT NOT NULL DEFAULT ''
      ''');
      await db.execute('''
        ALTER TABLE medications ADD COLUMN takenDosesDate TEXT
      ''');
    }

    if (oldVersion < 5) {
      // Add doseSchedule column for version 5 (dose quantities per time)
      await db.execute('''
        ALTER TABLE medications ADD COLUMN doseSchedule TEXT NOT NULL DEFAULT ''
      ''');
    }

    if (oldVersion < 6) {
      // Add skippedDosesToday column for version 6 (track skipped doses separately)
      await db.execute('''
        ALTER TABLE medications ADD COLUMN skippedDosesToday TEXT NOT NULL DEFAULT ''
      ''');
    }
  }

  // Create - Insert a medication
  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert(
      'medications',
      medication.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read - Get all medications
  Future<List<Medication>> getAllMedications() async {
    final db = await database;
    final result = await db.query('medications');

    return result.map((json) => Medication.fromJson(json)).toList();
  }

  // Read - Get a single medication by ID
  Future<Medication?> getMedication(String id) async {
    final db = await database;
    final maps = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Medication.fromJson(maps.first);
    }
    return null;
  }

  // Update - Update a medication
  Future<int> updateMedication(Medication medication) async {
    final db = await database;
    return await db.update(
      'medications',
      medication.toJson(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  // Delete - Delete a medication
  Future<int> deleteMedication(String id) async {
    final db = await database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all medications (useful for testing)
  Future<int> deleteAllMedications() async {
    final db = await database;
    return await db.delete('medications');
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
