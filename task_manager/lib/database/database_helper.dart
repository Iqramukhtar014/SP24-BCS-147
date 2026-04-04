import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'tasks.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        isCompleted INTEGER NOT NULL,
        repeat TEXT,
        subtasks TEXT
      )
    ''');
  }

  Future<int> insertTask(Task t) async {
    final db = await database;
    return await db.insert('tasks', t.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'dueDate ASC');
    return rows.map((r) => Task.fromMap(r)).toList();
  }

  Future<int> updateTask(Task t) async {
    final db = await database;
    return await db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
