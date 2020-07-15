import 'package:flutter/widgets.dart';
import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/screens/settings/settings.dart';
import 'package:price_tracker/services/database.dart';
import 'package:price_tracker/services/product_utils.dart';
import 'package:toast/toast.dart';
import 'package:workmanager/workmanager.dart';

class Settings extends State<SettingsScreen> {
  static const String VERSION = "0.1.3";
  static const String APP_NAME = "Price Tracker BETA";

  Product testProduct = Product.fromMap({
    "_id": 0,
    "name":
        "Apple iPad (10.2-inch, WiFi, 32GB) - Gold (latest model) - with extra dolphins",
    "productUrl": "testUrl.com",
    "prices": "[-1.0, 269.0, 260.0]",
    "dates":
        "[2020-07-02 00:00:00.000, 2020-07-03 15:43:12.345, 2020-07-04 04:00:45.000]",
    "targetPrice": "261.0",
    "imageUrl": "",
    "parseSuccess": "true",
  });

  showToast(String text, {int sec = 2}) =>
      Toast.show(text, context, duration: sec);

  clearDB() async {
    DatabaseService _db = await DatabaseService.getInstance();
    await _db.deleteAll();
    showToast("Database cleared!");
  }

  void testPriceFallNotification() {
    sendPriceFallNotification(testProduct);
  }

  void testUnderTargetNotification() {
    sendUnderTargetNotification(testProduct);
  }

  void testAvailableAgainNotification() {
    sendAvailableAgainNotification(testProduct);
  }

  void testBackgroundService() {
    Workmanager.registerOneOffTask(
        "manualPriceScraping", "Manual Price Tracker Scraper");
  }

  @override
  Widget build(BuildContext context) => SettingsScreenView(this);
}
