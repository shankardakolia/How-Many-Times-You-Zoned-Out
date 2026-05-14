import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/zone_out_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zone_out.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE zone_out_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        durationSeconds INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_date ON zone_out_entries(date)',
    );
  }

  Future<int> insertEntry(ZoneOutEntry entry) async {
    final db = await database;
    return await db.insert('zone_out_entries', entry.toMap());
  }

  Future<List<ZoneOutEntry>> getTodayEntries(String todayDate) async {
    final db = await database;
    final maps = await db.query(
      'zone_out_entries',
      where: 'date = ?',
      whereArgs: [todayDate],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => ZoneOutEntry.fromMap(m)).toList();
  }

  Future<List<ZoneOutEntry>> getEntriesForDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'zone_out_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => ZoneOutEntry.fromMap(m)).toList();
  }

  Future<Map<String, int>> getDailyScores(List<String> dates) async {
    final db = await database;
    final placeholders = dates.map((_) => '?').join(',');
    final maps = await db.rawQuery(
      '''
      SELECT date, COUNT(*) as count, SUM(durationSeconds) as totalDuration
      FROM zone_out_entries
      WHERE date IN ($placeholders)
      GROUP BY date
      ORDER BY date ASC
      ''',
      dates,
    );
    final result = <String, int>{};
    for (final m in maps) {
      result[m['date'] as String] = (m['count'] as int);
    }
    return result;
  }

  Future<String?> getBestFocusDay() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT date, COUNT(*) as count
      FROM zone_out_entries
      GROUP BY date
      ORDER BY count ASC
      LIMIT 1
    ''');
    if (maps.isEmpty) return null;
    return maps.first['date'] as String?;
  }
}
