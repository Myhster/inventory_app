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
      version: 7,
      onCreate: (db, version) async {
        await _createTables(db);
        await _addShoppingListTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createTables(db);
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN orderIndex INTEGER DEFAULT 0',
          );
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
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE products ADD COLUMN orderIndex INTEGER DEFAULT 0',
          );
          final products = await db.query('products');
          for (int i = 0; i < products.length; i++) {
            await db.update(
              'products',
              {'orderIndex': i},
              where: 'id = ?',
              whereArgs: [products[i]['id']],
            );
          }
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE products ADD COLUMN threshold INTEGER DEFAULT 1',
          );
          await db.execute(
            'ALTER TABLE products ADD COLUMN useFillLevel INTEGER DEFAULT 0',
          );
          await db.execute('ALTER TABLE products ADD COLUMN fillLevel REAL');
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE products RENAME TO tmp_products');
          await db.execute('''
            CREATE TABLE products (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              quantity INTEGER NOT NULL,
              category TEXT NOT NULL,
              orderIndex INTEGER DEFAULT 0,
              threshold REAL DEFAULT 0.2,
              useFillLevel INTEGER DEFAULT 0,
              fillLevel REAL
            )
          ''');
          await db.execute('INSERT INTO products SELECT * FROM tmp_products');
          await db.execute('DROP TABLE tmp_products');
        }
        if (oldVersion < 7) {
          await _addShoppingListTable(db);
        }
      },
    );
  }
  
  Future<void> _addShoppingListTable(Database db) async {
    await db.execute('''
      CREATE TABLE shopping_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity_to_buy INTEGER NOT NULL,
        category TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        orderIndex INTEGER DEFAULT 0,
        threshold REAL DEFAULT 0.2,
        useFillLevel INTEGER DEFAULT 0,
        fillLevel REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        orderIndex INTEGER DEFAULT 0
      )
    ''');
    for (var cat in [
      'Unsorted',
      'Fruits',
      'Vegetables',
      'Bread',
      'Detergents',
    ]) {
      await db.insert('categories', {
        'name': cat,
        'orderIndex': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<int> insertProduct(Product product) async {
    await initDatabase();
    final existing = await _database!.query(
      'products',
      where: 'category = ?',
      whereArgs: [product.category],
      orderBy: 'orderIndex DESC',
      limit: 1,
    );
    int orderIndex =
        existing.isNotEmpty ? (existing.first['orderIndex'] as int) + 1 : 0;
    return await _database!.insert('products', {
      ...product.toMap(),
      'orderIndex': orderIndex,
    });
  }

  Future<List<Product>> getProducts() async {
    await initDatabase();
    final maps = await _database!.query(
      'products',
      orderBy: 'category ASC, orderIndex ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
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

  Future<void> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await initDatabase();
    await _database!.update(table, values, where: where, whereArgs: whereArgs);
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

  Future<void> updateProductOrder(int id, int newOrderIndex) async {
    await initDatabase();
    await _database!.update(
      'products',
      {'orderIndex': newOrderIndex},
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<void> updateCategoryOrder(int id, int newOrderIndex) async {
    await initDatabase();
    await _database!.update(
      'categories',
      {'orderIndex': newOrderIndex},
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<int> insertShoppingItem(
    String name,
    int quantityToBuy,
    String category,
  ) async {
    await initDatabase();
    return await _database!.insert('shopping_list', {
      'name': name,
      'quantity_to_buy': quantityToBuy,
      'category': category,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getShoppingItems() async {
    await initDatabase();
    return await _database!.query('shopping_list');
  }

  Future<void> removeShoppingItem(int id) async {
    await initDatabase();
    await _database!.delete('shopping_list', where: 'id = ?', whereArgs: [id]);
  }
}
