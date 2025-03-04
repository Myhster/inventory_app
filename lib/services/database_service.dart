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
      version: 3, // Version erhöht für orderIndex
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTables(db);
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN orderIndex INTEGER DEFAULT 0',
          );
          // Setze initiale Reihenfolge für bestehende Kategorien
          final categories = await db.query('categories');
          for (int i = 0; i < categories.length; i++) {
            await db.update(
              'categories',
              {'orderIndex': i},
              where: 'id = ?',
              whereArgs: [categories[i]['id']],
            );
          }
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
        name TEXT NOT NULL UNIQUE,
        orderIndex INTEGER DEFAULT 0
      )
    ''');
    for (var cat in [
      'Unsortiert',
      'Gemüse',
      'Obst',
      'Brot',
      'Reinigungsmittel',
    ]) {
      await db.insert('categories', {
        'name': cat,
        'orderIndex': 0,
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
    final existing = await _database!.query(
      'categories',
      orderBy: 'orderIndex DESC',
      limit: 1,
    );
    int orderIndex =
        existing.isNotEmpty ? (existing.first['orderIndex'] as int) + 1 : 0;
    return await _database!.insert('categories', {
      ...category.toMap(),
      'orderIndex': orderIndex,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Category>> getCategories() async {
    await initDatabase();
    final maps = await _database!.query(
      'categories',
      orderBy: 'orderIndex ASC',
    );
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

  Future<void> updateCategoryOrder(int id, int newOrderIndex) async {
    await initDatabase();
    await _database!.update(
      'categories',
      {'orderIndex': newOrderIndex},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
