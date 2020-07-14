import 'dart:math';

import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/screens/product_detail/product_detail.dart';
import 'package:price_tracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:price_tracker/services/init.dart';
import 'package:price_tracker/services/notifications.dart';

double reloadProgress;

double roundToPlace(double d, int places) {
  double mod = pow(10.0, places);
  return ((d * mod).round().toDouble() / mod);
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
    double lastPrice = products[i].latestPrice;
    await products[i].update(test: test);
    await _db.update(products[i]);
    reloadProgress = i / products.length;
    perUpdate();

    // Send notifications only when price changed
    // otherwise the app notified twice per day.
    if (lastPrice != products[i].latestPrice)
      checkAndSendNotifications(products[i]);
  }

  reloadProgress = null;
}

// Opens the corresponding details view of the product by product id in payload
Future<void> notificationTapCallback(String payload) async {
  // get Product by id
  Product product = await (await DatabaseService.getInstance())
      .getProduct(payload != "" ? int.parse(payload) : null);

  // Clear payload variable
  NotificationService.currentPayload = null;

  if (product != null)
    navigatorKey.currentState.push(MaterialPageRoute(
        builder: (context) => ProductDetail(
              product: product,
            )));
}

sendPriceFallNotification(Product p) {
  NotificationService.sendAlertPushNotificationBig(
      p.id,
      "A Product is cheaper by ${p.percentageToYesterday()}%!",
      p.getShortName() +
          "\nThe price fell by ${-p.priceDifferenceToYesterday()} and it costs now ${p.latestPrice}",
      payload: p.id.toString());
}

sendUnderTargetNotification(Product p) {
  NotificationService.sendAlertPushNotificationBig(
      p.id,
      "A Product is under their Target!",
      p.getShortName() + " is under the set target and costs ${p.latestPrice}",
      payload: p.id.toString());
}

sendAvailableAgainNotification(Product p) {
  NotificationService.sendAlertPushNotificationBig(
      p.id,
      "A Product is available again!",
      p.getShortName() + " is available again and costs ${p.latestPrice}",
      payload: p.id.toString());
}

// Checks theproduct and sends the relevant Notification if any
checkAndSendNotifications(Product p) {
  if (p.priceFall()) {
    if (p.underTarget())
      sendUnderTargetNotification(p);
    else
      sendPriceFallNotification(p);
  } else if (p.availableAgain()) sendAvailableAgainNotification(p);
}
