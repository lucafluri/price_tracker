import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/screens/settings/settings.dart';
import 'package:price_tracker/services/backup.dart';
import 'package:price_tracker/services/database.dart';
import 'package:price_tracker/services/init.dart';
import 'package:price_tracker/services/product_utils.dart';
import 'package:toast/toast.dart';
import 'package:workmanager/workmanager.dart';

class Settings extends State<SettingsScreen> {
  static const String VERSION = "0.1.5";
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
    OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: "Do you really want to empty the database?",
      message: "All tracked products will be lost without a backup",
      okLabel: "Clear DB",
      barrierDismissible: true,
      isDestructiveAction: true,
    );
    if (result == OkCancelResult.ok) {
      DatabaseService _db = await DatabaseService.getInstance();
      if (await _db.deleteAll() > 0) {
        showToast("Database cleared!");
        navigatorKey.currentState
            .pushNamedAndRemoveUntil("/", (route) => false);
      } else
        showToast("Database already empty");
    }
  }

  backup() async {
    if (await BackupService.instance.backup())
      showToast("Backup file saved");
    else
      showToast("Error saving backup file");
  }

  restore() async {
    if (await BackupService.instance.restore()) {
      showToast("Products loaded from backup");
      navigatorKey.currentState.pushNamedAndRemoveUntil("/", (route) => false);
    } else
      showToast("Error reading backup file");
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
