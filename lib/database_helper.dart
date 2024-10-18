import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'paintings.db');

    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE paintings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          price REAL NOT NULL
        )
      ''');
    });
  }

  // Thêm mới một painting
  Future<int> addPainting(String title, String description, double price) async {
    var dbClient = await db;
    return await dbClient.insert('paintings', {
      'title': title,
      'description': description,
      'price': price
    });
  }

  // Lấy tất cả paintings
  Future<List<Map<String, dynamic>>> getPaintings() async {
    var dbClient = await db;
    return await dbClient.query('paintings');
  }

  // Cập nhật painting
  Future<int> updatePainting(int id, String title, String description, double price) async {
    var dbClient = await db;
    return await dbClient.update('paintings', {
      'title': title,
      'description': description,
      'price': price
    }, where: 'id = ?', whereArgs: [id]);
  }

  // Xóa painting
  Future<int> deletePainting(int id) async {
    var dbClient = await db;
    return await dbClient.delete('paintings', where: 'id = ?', whereArgs: [id]);
  }
}
