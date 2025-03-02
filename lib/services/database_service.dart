import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventory_app/models/product.dart';

class DatabaseService {
  Database? _database;
  Database get database => _database!;

  Future<void> initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            category TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertProduct(Product product) async {
    await initDatabase(); // Initialize the database if not already initialized
    return await _database!.insert('products', product.toMap());
  }

  Future<Product> getProduct(int id) async {
    await initDatabase();
    final maps = await _database!.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Product.fromMap(maps.first);
  }
}
