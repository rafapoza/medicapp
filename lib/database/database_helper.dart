import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication.dart';
import '../models/dose_history_entry.dart';

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
      version: 11,
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
        selectedDates $textNullableType,
        weeklyDays $textNullableType,
        doseTimes $textType,
        doseSchedule $textType,
        stockQuantity $realType,
        takenDosesToday $textType,
        skippedDosesToday $textType,
        takenDosesDate $textNullableType,
        lastRefillAmount REAL,
        lowStockThresholdDays $integerType DEFAULT 3,
        startDate $textNullableType,
        endDate $textNullableType
      )
    ''');

    // Create dose_history table for tracking all doses
    await db.execute('''
      CREATE TABLE dose_history (
        id $idType,
        medicationId $textType,
        medicationName $textType,
        medicationType $textType,
        scheduledDateTime $textType,
        registeredDateTime $textType,
        status $textType,
        quantity REAL NOT NULL,
        notes $textNullableType
      )
    ''');

    // Create index for faster queries by medicationId and date
    await db.execute('''
      CREATE INDEX idx_dose_history_medication
      ON dose_history(medicationId)
    ''');

    await db.execute('''
      CREATE INDEX idx_dose_history_date
      ON dose_history(scheduledDateTime)
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

    if (oldVersion < 7) {
      // Add lastRefillAmount column for version 7 (store last refill amount for suggestions)
      await db.execute('''
        ALTER TABLE medications ADD COLUMN lastRefillAmount REAL
      ''');
    }

    if (oldVersion < 8) {
      // Add lowStockThresholdDays column for version 8 (configurable low stock threshold)
      await db.execute('''
        ALTER TABLE medications ADD COLUMN lowStockThresholdDays INTEGER NOT NULL DEFAULT 3
      ''');
    }

    if (oldVersion < 9) {
      // Add selectedDates and weeklyDays columns for version 9 (specific days and weekly patterns)
      await db.execute('''
        ALTER TABLE medications ADD COLUMN selectedDates TEXT
      ''');
      await db.execute('''
        ALTER TABLE medications ADD COLUMN weeklyDays TEXT
      ''');
    }

    if (oldVersion < 10) {
      // Add startDate and endDate columns for version 10 (Phase 2: treatment date range)
      await db.execute('''
        ALTER TABLE medications ADD COLUMN startDate TEXT
      ''');
      await db.execute('''
        ALTER TABLE medications ADD COLUMN endDate TEXT
      ''');
    }

    if (oldVersion < 11) {
      // Create dose_history table for version 11 (Phase 2: dose history tracking)
      const idType = 'TEXT PRIMARY KEY';
      const textType = 'TEXT NOT NULL';
      const textNullableType = 'TEXT';

      await db.execute('''
        CREATE TABLE dose_history (
          id $idType,
          medicationId $textType,
          medicationName $textType,
          medicationType $textType,
          scheduledDateTime $textType,
          registeredDateTime $textType,
          status $textType,
          quantity REAL NOT NULL,
          notes $textNullableType
        )
      ''');

      // Create indexes
      await db.execute('''
        CREATE INDEX idx_dose_history_medication
        ON dose_history(medicationId)
      ''');

      await db.execute('''
        CREATE INDEX idx_dose_history_date
        ON dose_history(scheduledDateTime)
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

  // === DOSE HISTORY METHODS ===

  // Create - Insert a dose history entry
  Future<int> insertDoseHistory(DoseHistoryEntry entry) async {
    final db = await database;
    return await db.insert(
      'dose_history',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read - Get all dose history entries
  Future<List<DoseHistoryEntry>> getAllDoseHistory() async {
    final db = await database;
    final result = await db.query(
      'dose_history',
      orderBy: 'scheduledDateTime DESC', // Most recent first
    );

    return result.map((map) => DoseHistoryEntry.fromMap(map)).toList();
  }

  // Read - Get dose history for a specific medication
  Future<List<DoseHistoryEntry>> getDoseHistoryForMedication(String medicationId) async {
    final db = await database;
    final result = await db.query(
      'dose_history',
      where: 'medicationId = ?',
      whereArgs: [medicationId],
      orderBy: 'scheduledDateTime DESC',
    );

    return result.map((map) => DoseHistoryEntry.fromMap(map)).toList();
  }

  // Read - Get dose history for a date range
  Future<List<DoseHistoryEntry>> getDoseHistoryForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? medicationId,
  }) async {
    final db = await database;

    final startString = startDate.toIso8601String();
    final endString = endDate.toIso8601String();

    String where = 'scheduledDateTime >= ? AND scheduledDateTime <= ?';
    List<dynamic> whereArgs = [startString, endString];

    if (medicationId != null) {
      where += ' AND medicationId = ?';
      whereArgs.add(medicationId);
    }

    final result = await db.query(
      'dose_history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'scheduledDateTime DESC',
    );

    return result.map((map) => DoseHistoryEntry.fromMap(map)).toList();
  }

  // Read - Get statistics for a medication
  Future<Map<String, dynamic>> getDoseStatistics({
    String? medicationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String where = '1 = 1'; // Always true
    List<dynamic> whereArgs = [];

    if (medicationId != null) {
      where += ' AND medicationId = ?';
      whereArgs.add(medicationId);
    }

    if (startDate != null) {
      where += ' AND scheduledDateTime >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      where += ' AND scheduledDateTime <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    // Get total count
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM dose_history WHERE $where',
      whereArgs,
    );
    final total = totalResult.first['total'] as int;

    // Get taken count
    final takenResult = await db.rawQuery(
      'SELECT COUNT(*) as taken FROM dose_history WHERE $where AND status = ?',
      [...whereArgs, 'taken'],
    );
    final taken = takenResult.first['taken'] as int;

    // Get skipped count
    final skippedResult = await db.rawQuery(
      'SELECT COUNT(*) as skipped FROM dose_history WHERE $where AND status = ?',
      [...whereArgs, 'skipped'],
    );
    final skipped = skippedResult.first['skipped'] as int;

    // Calculate adherence percentage
    final adherence = total > 0 ? (taken / total * 100).toDouble() : 0.0;

    return {
      'total': total,
      'taken': taken,
      'skipped': skipped,
      'adherence': adherence,
    };
  }

  // Delete - Delete a dose history entry
  Future<int> deleteDoseHistory(String id) async {
    final db = await database;
    return await db.delete(
      'dose_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Delete all dose history for a medication
  Future<int> deleteDoseHistoryForMedication(String medicationId) async {
    final db = await database;
    return await db.delete(
      'dose_history',
      where: 'medicationId = ?',
      whereArgs: [medicationId],
    );
  }

  // Delete all dose history (useful for testing)
  Future<int> deleteAllDoseHistory() async {
    final db = await database;
    return await db.delete('dose_history');
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
