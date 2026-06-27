import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sms_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sms_queue.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sms_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT,
        body TEXT,
        refNo TEXT,
        amount TEXT,
        status TEXT
      )
    ''');
  }

  Future<int> insertSms(SmsData sms) async {
    final db = await instance.database;
    return await db.insert('sms_queue', sms.toMap());
  }

  Future<List<SmsData>> getAllSms() async {
    final db = await instance.database;

    final result = await db.query('sms_queue', orderBy: 'id DESC');
    return result.map((json) => SmsData.fromMap(json)).toList();
  }

  Future<List<SmsData>> getPendingSms() async {
    final db = await instance.database;
    final result = await db.query(
      'sms_queue',
      where: "status = ?",
      whereArgs: ['pending'],
    );
    return result.map((json) => SmsData.fromMap(json)).toList();
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'sms_queue',
      {'status': status},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('sms_queue');
  }
}
