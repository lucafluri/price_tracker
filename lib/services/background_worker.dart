import 'package:flutter/cupertino.dart';
import 'package:price_tracker/services/product_utils.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundWorkerService {
  BackgroundWorkerService._privateConstructor();
  static final BackgroundWorkerService _instance = BackgroundWorkerService._privateConstructor();

  static BackgroundWorkerService get instance => _instance;

  static Future<void> init() async {
    await Workmanager.initialize(_dispatchCallbacks, isInDebugMode: false);
  }
}

void _dispatchCallbacks() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager.executeTask((taskName, inputData) async {
    switch (taskName) {
      case "Price Tracker Scraper":
      case "Manual Price Tracker Scraper":
        try {
          // TODO change to per price
          await updatePrices();
          // // TODO Remove notification
          // pushNotification(3, "Prices have been updated",
          //     "We updated the prices for you in the background!");
          print("Executed Task");
        } catch (e) {
          debugPrint(e);
        }

        break;
    }
    return Future.value(true);
  });
}