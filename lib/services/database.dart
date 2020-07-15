import 'dart:io';

import 'package:path/path.dart';
import 'package:price_tracker/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final _databaseName = "price_tracker.db";

  // v2 added parseSuccess column
  static final _databaseVersion = 2;

  static final table = 'products';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnProductUrl = 'productUrl';
  static final columnPrices = 'prices';
  static final columnDates = 'dates';
  static final columnTargetPrice = 'targetPrice';
  static final columnImageUrl = 'imageUrl';
  static final columnParseSuccess = 'parseSuccess';

  // make this a singleton class
  DatabaseService._privateConstructor();
  static final DatabaseService _instance =
      DatabaseService._privateConstructor();

  static Future<DatabaseService> getInstance() async {
    if (_database == null) await init();

    return _instance;
  }

  // only have a single app-wide reference to the database
  static Database _database;

  // this opens the database (and creates it if it doesn't exist)
  static Future<void> init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    _database = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute('ALTER TABLE $table ADD $columnParseSuccess TEXT');
      print("Database upgraded from version 1 to version 2, added column "
          "'$columnParseSuccess'");
    }
    // if (oldVersion == 1 || oldVersion == 2) {
    //   await db.execute('ALTER TABLE $table ADD $columnFavorite INTEGER');
    //   print("Database upgraded from version 2 to version 3, added column "
    //       "'$columnFavorite'");
    // }
  }

  // SQL code to create the database table
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY NOT NULL,
            $columnName TEXT NOT NULL,
            $columnProductUrl TEXT,
            $columnPrices TEXT,
            $columnDates TEXT,
            $columnTargetPrice TEXT,
            $columnImageUrl TEXT,
            $columnParseSuccess TEXT
          )
          ''');
  }

  // Helper methods

  /// Inserts a Product in the database if not already present
  ///
  /// returns id of the inserted product or -1 if already present
  Future<int> insert(Product product) async {
    // First check, whether the movie already exists:
    final bool duplicate = await contains(product);
    if (duplicate) {
      print('Product ${product.id} already exists in db');
      return -1;
    } else {
      product.id = null;
      int answer = await _database.insert(table, product.toMap());
      product.id = answer;

      print('Product ${product.id} inserted into db.');

      return answer;
    }
  }

  /// Gets a specific product from the database.
  /// Returns product, or 'null' if not found.
  Future<Product> getProduct(int id) async {
    var result =
        await _database.rawQuery('SELECT * FROM $table WHERE $columnId = $id');

    if (result.length > 0) {
      return new Product.fromMap(result.first);
    }

    return null;
  }

  /// Gets a specific product from the database.
  /// Returns product, or 'null' if not found.
  Future<Product> getFirstProduct() async {
    var result = await _database.rawQuery('SELECT * FROM $table');

    if (result.length > 0) {
      return new Product.fromMap(result.first);
    }

    return null;
  }

  /// Returns the list of Products
  Future<List<Product>> getAllProducts() async {
    List<Map<String, dynamic>> list = await _database.query(table);
    List<Product> products = list.map((el) => Product.fromMap(el)).toList();
    return products;
  }

  Future<bool> contains(Product product) async {
    return (await getAllProducts()).contains(product);
  }

  Future<bool> containsWithSameURL(Product product) async {
    //contains uses the overriden == and hashCode function of Product
    return (await getAllProducts()).contains(product);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _database.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryCount() async {
    return Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Product prod) async {
    return await _database.update(table, prod.toMap(),
        where: '$columnId = ?', whereArgs: [prod.id]);
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<void> updateId(int id) async {
    await _database
        .rawQuery('UPDATE $table SET $columnId = $id WHERE $columnId = $id');
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _database
        .delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // Clears db
  Future<int> deleteAll() async {
    return await _database.delete(table);
  }
}
