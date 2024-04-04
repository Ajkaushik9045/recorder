import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecordingInfo {
  final int id;
  final String path;
  final int duration;

  RecordingInfo({
    required this.id,
    required this.path,
    required this.duration,
  });
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, 'recordings.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recordings(
        id INTEGER PRIMARY KEY,
        path TEXT,
        duration INTEGER
      )
    ''');
  }

  Future<void> insertRecording(String path, int duration) async {
    final db = await database;
    await db.insert(
      'recordings',
      {'path': path, 'duration': duration},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RecordingInfo>> getRecordings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recordings');
    return List.generate(maps.length, (i) {
      return RecordingInfo(
        id: maps[i]['id'],
        path: maps[i]['path'],
        duration: maps[i]['duration'],
      );
    });
  }

  Future<void> deleteRecording(int id) async {
    final db = await database;
    await db.delete(
      'recordings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
