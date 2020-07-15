import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/services/database.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class BackupService {
  BackupService._privateConstructor();
  static final BackupService _instance = BackupService._privateConstructor();
  static BackupService get instance => _instance;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    var formatter = new DateFormat('yyyy-MM-dd-Hm');
    String formattedDT = formatter.format(DateTime.now());
    final path = await _localPath;
    return File('$path/price_tracker_backup_$formattedDT.pt');
  }

  Future<String> _buildJSON() async {
    DatabaseService _db = await DatabaseService.getInstance();
    List<Product> products = await _db.getAllProducts();
    List<dynamic> json = List();

    products.forEach((element) {
      json.add(element.toMap());
    });

    return jsonEncode(json);
  }

  List<Product> _buildProducts(String input) {
    try {
      List<dynamic> list = jsonDecode(input);
      List<Product> products = List();
      for (Map e in list) {
        products.add(Product.fromMap(e));
      }
      return products;
    } catch (e) {
      return null;
    }
  }

  backup() async {
    String json = await _buildJSON();
    final file = await _localFile;
    if (json == null) return;
    file.writeAsString(json);

    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    print(filePath);
  }

  restore() async {
    DatabaseService _db = await DatabaseService.getInstance();

    final params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      sourceType: SourceType.photoLibrary,
    );
    final filePath = await FlutterFileDialog.pickFile(params: params);
    if (filePath == null) {
      debugPrint("Filepath Error");
      return;
    }
    File file = File(filePath);

    if (file == null) {
      debugPrint("ERROR Getting File");
      return;
    }

    String string;

    try {
      string = await file.readAsString();
    } catch (e) {
      debugPrint("Can't read file as string!");
      return;
    }

    List<Product> products = _buildProducts(string);

    if (products == null) {
      debugPrint("Error building Products");
      return;
    }

    for (Product p in products) {
      await _db.insert(p);
    }
  }
}
