// lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'fashion_store.db');

    return await openDatabase(
      path,
      version: 2, // ⬅️ Versión 2 para incluir size y color
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${ProductFields.tableName} (
        ${ProductFields.id} ${ProductFields.idType},
        ${ProductFields.name} ${ProductFields.textType},
        ${ProductFields.description} ${ProductFields.textType},
        ${ProductFields.price} ${ProductFields.realType},
        ${ProductFields.stock} ${ProductFields.intType},
        ${ProductFields.category} ${ProductFields.textType},
        ${ProductFields.imageIcon} ${ProductFields.textType},
        ${ProductFields.size} ${ProductFields.textType},
        ${ProductFields.color} ${ProductFields.textType},
        ${ProductFields.isFavorite} ${ProductFields.intType},
        ${ProductFields.createdTime} ${ProductFields.textType}
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columnas size y color si no existen
      await db.execute('ALTER TABLE ${ProductFields.tableName} ADD COLUMN ${ProductFields.size} TEXT DEFAULT "M"');
      await db.execute('ALTER TABLE ${ProductFields.tableName} ADD COLUMN ${ProductFields.color} TEXT DEFAULT "Black"');
    }
  }

  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert(ProductFields.tableName, product.toJson());
    return product.copy(id: id);
  }

  Future<Product> readProduct(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      ProductFields.tableName,
      columns: ProductFields.values,
      where: '${ProductFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  Future<List<Product>> readAllProducts() async {
    final db = await instance.database;
    const orderBy = '${ProductFields.createdTime} DESC';
    final result = await db.query(ProductFields.tableName, orderBy: orderBy);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> readProductsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      ProductFields.tableName,
      where: '${ProductFields.category} = ?',
      whereArgs: [category],
      orderBy: '${ProductFields.name} ASC',
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> readFavoriteProducts() async {
    final db = await instance.database;
    final result = await db.query(
      ProductFields.tableName,
      where: '${ProductFields.isFavorite} = ?',
      whereArgs: [1],
      orderBy: '${ProductFields.createdTime} DESC',
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return db.update(
      ProductFields.tableName,
      product.toJson(),
      where: '${ProductFields.id} = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      ProductFields.tableName,
      where: '${ProductFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await instance.database;
    final result = await db.query(
      ProductFields.tableName,
      where: '${ProductFields.name} LIKE ? OR ${ProductFields.description} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}