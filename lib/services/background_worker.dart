import 'package:flutter/cupertino.dart';
import 'package:price_tracker/services/notifications.dart';
import 'package:price_tracker/services/product_utils.dart';
import 'package:workmanager/workmanager.dart';

import 'init.dart';

class BackgroundWorkerService {
  BackgroundWorkerService._privateConstructor();

  static final BackgroundWorkerService _instance =
      BackgroundWorkerService._privateConstructor();

  static BackgroundWorkerService get instance => _instance;

  static Future<void> init() async {
    await Workmanager.initialize(_dispatchCallbacks, isInDebugMode: false);
  }
}

void _dispatchCallbacks() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppBackground();

  Workmanager.executeTask((taskName, inputData) async {
    switch (taskName) {
      case "Price Tracker Scraper":
      case "Manual Price Tracker Scraper":
      case Workmanager.iOSBackgroundTask:
        try {
          await updatePrices(() {});
          // For testing purpose:
          NotificationService.sendAlertPushNotificationSmall(
              3,
              "Prices have been updated",
              "We've updated the prices for you in the background");
          print("Executed Task");
        } catch (e) {
          debugPrint(e.toString());
        }

        break;
    }
    return Future.value(true);
  });
}
