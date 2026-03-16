import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient_model.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('patients.db');
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

  Future _createDB(Database db, int version) async {

    await db.execute('''
    CREATE TABLE patients(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      age TEXT,
      gender TEXT,
      disease TEXT,
      phone TEXT,
      address TEXT,
      imagePath TEXT
    )
    ''');
  }

  // INSERT PATIENT

  Future<int> insertPatient(Patient patient) async {
    final db = await instance.database;
    return await db.insert('patients', patient.toMap());
  }

  // GET ALL PATIENTS

  Future<List<Patient>> getPatients() async {
    final db = await instance.database;

    final result = await db.query('patients');

    return result.map((json) => Patient.fromMap(json)).toList();
  }

  // UPDATE PATIENT

  Future<int> updatePatient(Patient patient) async {
    final db = await instance.database;

    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  // DELETE PATIENT

  Future<int> deletePatient(int id) async {
    final db = await instance.database;

    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}