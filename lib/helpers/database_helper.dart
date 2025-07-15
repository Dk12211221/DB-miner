import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/quote_model.dart';

class DbHelper {
  DbHelper._privateConstructor();
  static final DbHelper dbHelper = DbHelper._privateConstructor();

  Database? _db;

  Future<void> initDB() async {
    if (_db != null) return;

    try {
      String dbPath = join(await getDatabasesPath(), "quotes.db");
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS quotes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              quote TEXT NOT NULL,
              author TEXT,
              category TEXT,
              isFavorite INTEGER DEFAULT 0
            );
          ''');
          print("✅ Database and quotes table created.");
        },
      );
    } catch (e) {
      print("❌ DB Initialization failed: $e");
    }
  }

  Future<int> insertQuote(QuoteModel quote) async {
    await initDB();
    return await _db!.insert('quotes', quote.toMap());
  }

  Future<List<QuoteModel>> fetchAllQuotes() async {
    await initDB();
    final List<Map<String, dynamic>> data = await _db!.query('quotes');
    return data.map((e) => QuoteModel.fromJson(e)).toList();
  }

  Future<List<QuoteModel>> fetchFavorites() async {
    await initDB();
    final List<Map<String, dynamic>> data = await _db!.query(
      'quotes',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return data.map((e) => QuoteModel.fromJson(e)).toList();
  }

  Future<List<QuoteModel>> searchQuotes({required String category}) async {
    await initDB();
    final List<Map<String, dynamic>> data = await _db!.query(
      'quotes',
      where: 'category LIKE ?',
      whereArgs: ['%$category%'],
    );
    return data.map((e) => QuoteModel.fromJson(e)).toList();
  }

  Future<int> deleteQuote(int id) async {
    await initDB();
    return await _db!.delete(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(int id, int newValue) async {
    await initDB();
    return await _db!.update(
      'quotes',
      {'isFavorite': newValue},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
