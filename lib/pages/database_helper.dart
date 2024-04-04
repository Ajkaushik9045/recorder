import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    // Get a location using getDatabasesPath
String documentsDirectory = await getDatabasesPath();
String path = join(documentsDirectory, 'recordings.db');

    // Open/create the database at a given path
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    // Create the recordings table
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

  Future<List<Map<String, dynamic>>> getRecordings() async {
    final db = await database;
    return await db.query('recordings');
  }
}
