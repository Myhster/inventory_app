import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/models/category.dart';

class DatabaseService {
  Database? _database;

  Future<void> initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');
    _database = await openDatabase(
      path,
      version: 2, // Version erhöht
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTables(db); // Tabellen neu erstellen bei Upgrade
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    // Vordefinierte Kategorien
    for (var cat in [
      'Unsortiert',
      'Gemüse',
      'Obst',
      'Brot',
      'Reinigungsmittel',
    ]) {
      await db.insert('categories', {
        'name': cat,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<int> insertProduct(Product product) async {
    await initDatabase();
    return await _database!.insert('products', product.toMap());
  }

  Future<Product?> getProductByName(String name) async {
    await initDatabase();
    final maps = await _database!.query(
      'products',
      where: 'name = ?',
      whereArgs: [name],
    );
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<void> updateProductQuantity(int id, int newQuantity) async {
    await initDatabase();
    await _database!.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getProducts() async {
    await initDatabase();
    final maps = await _database!.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> removeProduct(int id) async {
    await initDatabase();
    await _database!.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertCategory(Category category) async {
    await initDatabase();
    return await _database!.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Category>> getCategories() async {
    await initDatabase();
    final maps = await _database!.query('categories');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> removeCategory(int id) async {
    await initDatabase();
    await _database!.transaction((txn) async {
      final category =
          (await txn.query(
            'categories',
            where: 'id = ?',
            whereArgs: [id],
          )).first;
      if (category['name'] != 'Unsortiert') {
        await txn.update(
          'products',
          {'category': 'Unsortiert'},
          where: 'category = ?',
          whereArgs: [category['name']],
        );
        await txn.delete('categories', where: 'id = ?', whereArgs: [id]);
      }
    });
  }
}
