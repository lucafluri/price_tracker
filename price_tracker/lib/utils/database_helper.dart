import 'dart:io';

import 'package:path/path.dart';
import 'package:price_tracker/classes/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  
  static final _databaseName = "price_tracker.db";
  static final _databaseVersion = 1;

  static final table = 'products';
  
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnProductUrl = 'productUrl';
  static final columnPrices = 'prices';
  static final columnDates = 'dates';
  static final columnTargetPrice = 'targetPrice';
  static final columnImageUrl = 'imageUrl';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }
  
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY NOT NULL,
            $columnName TEXT NOT NULL,
            $columnProductUrl TEXT,
            $columnPrices TEXT,
            $columnDates TEXT,
            $columnTargetPrice TEXT,
            $columnImageUrl TEXT
          )
          ''');
  }
  
  // Helper methods

  /// Inserts a Product in the database if not already present
  ///
  /// returns id of the inserted product or -1 if already present
  Future<int> insert(Product product) async {
    Database db = await instance.database;
    // First check, whether the movie already exists:
    final Product exists = await getProduct(product.id);
    if (exists != null) {
      print('Product ${product.id} already exists in db');
      return -1;
    } else {
      int answer = await db.insert(table, product.toMap());
      product.id = answer;

      print('Product ${product.id} inserted into db.');
      
      return answer;
    }
  }

  /// Gets a specific product from the database.
  /// Returns product, or 'null' if not found.
  Future<Product> getProduct(int id) async {
    Database db = await instance.database;
    var result =
        await db.rawQuery('SELECT * FROM $table WHERE $columnId = $id');

    if (result.length > 0) {
      return new Product.fromMap(result.first);
    }

    return null;
  }

  /// Returns the list of Products
  Future<List<Product>> getAllProducts() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> list = await db.query(table);
    List<Product> products =
        list.map((el) => Product.fromMap(el)).toList();
    return products;
  }

  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Product prod) async {
    Database db = await instance.database;
    return await db.update(table, prod.toMap(), where: '$columnId = ?', whereArgs: [prod.id]);
  }

    // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<void> updateId(int id) async {
    Database db = await instance.database;
    await db.rawQuery('UPDATE $table SET $columnId = $id WHERE $columnId = $id');
  }


  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  //Clears db
  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}