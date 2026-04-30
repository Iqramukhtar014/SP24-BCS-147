// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_result.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('number_guessing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guessed_number INTEGER NOT NULL,
        correct_number INTEGER NOT NULL,
        result TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Insert a game result
  Future<int> insertResult(GameResult result) async {
    final db = await database;
    return await db.insert('game_results', result.toMap());
  }

  // Get all results ordered by newest first
  Future<List<GameResult>> getAllResults() async {
    final db = await database;
    final maps = await db.query(
      'game_results',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => GameResult.fromMap(map)).toList();
  }

  // Get stats
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;

    final totalGames = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM game_results'),
        ) ??
        0;

    final totalWins = Sqflite.firstIntValue(
          await db.rawQuery(
              "SELECT COUNT(*) FROM game_results WHERE result = 'win'"),
        ) ??
        0;

    // By difficulty
    final difficulties = ['Easy', 'Medium', 'Hard'];
    Map<String, Map<String, int>> byDifficulty = {};

    for (final diff in difficulties) {
      final total = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM game_results WHERE difficulty = ?',
              [diff],
            ),
          ) ??
          0;

      final wins = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM game_results WHERE difficulty = ? AND result = 'win'",
              [diff],
            ),
          ) ??
          0;

      byDifficulty[diff] = {'total': total, 'wins': wins};
    }

    return {
      'totalGames': totalGames,
      'totalWins': totalWins,
      'byDifficulty': byDifficulty,
    };
  }

  // Clear all history
  Future<void> clearAllHistory() async {
    final db = await database;
    await db.delete('game_results');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
