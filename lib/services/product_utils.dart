import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:price_tracker/services/notifications.dart';

double reloadProgress;

Future<int> countPriceFall() async {
  final _db = await DatabaseService.getInstance();

  List<Product> products = await _db.getAllProducts();

  int count = 0;

  for (int i = 0; i < products.length; i++) {
    if (products[i].priceFall()) {
      count++;

      debugPrint(products[i].name);
      debugPrint(
          "Price diff: " + products[i].priceDifferenceToYesterday().toString());
      debugPrint(
          "Percentage: " + products[i].percentageToYesterday().toString());
      debugPrint("Available again: " + products[i].availableAgain().toString());
    }
  }
  return count;
}

//Returns number of products that fell under the set target
Future<int> countPriceUnderTarget() async {
  final _db = await DatabaseService.getInstance();

  List<Product> products = await _db.getAllProducts();

  int count = 0;

  for (int i = 0; i < products.length; i++) {
    if (products[i].underTarget()) count++;
  }
  return count;
}

//Returns number of products that fell under the set target
Future<int> countFailedParsing() async {
  final _db = await DatabaseService.getInstance();

  List<Product> products = await _db.getAllProducts();

  int count = 0;

  for (int i = 0; i < products.length; i++) {
    if (!products[i].parseSuccess) count++;
  }
  return count;
}

Future<void> updatePrices(Function perUpdate, {test: false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final _db = await DatabaseService.getInstance();

  List<Product> products = await _db.getAllProducts();

  for (int i = 0; i < products.length; i++) {
    await products[i].update(test: test);
    await _db.update(products[i]);
    reloadProgress = i / products.length;
    perUpdate();
  }

  products = await _db.getAllProducts();
  int countFall = await countPriceFall();
  int countTarget = await countPriceUnderTarget();

  if (countFall > 0) {
    if (countFall == 1) {
      NotificationService.sendPushNotification(
          0,
          '$countFall product is cheaper',
          'We detected that $countFall product is cheaper today!'); //Display Notification
    } else {
      NotificationService.sendPushNotification(
          0,
          '$countFall products are cheaper',
          'We detected that $countFall products are cheaper today!'); //Display Notification
    }
  }
  if (countTarget > 0) {
    if (countTarget == 1) {
      NotificationService.sendPushNotification(
          1,
          '$countTarget product is under their target!',
          'We detected that $countTarget product is under the set target today!'); //Display Notification
    } else {
      NotificationService.sendPushNotification(
          1,
          '$countTarget products are under their target!',
          'We detected that $countTarget products are under the set targets today!'); //Display Notification
    }
  }

  reloadProgress = null;
}
