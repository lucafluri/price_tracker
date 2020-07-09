import 'dart:io';

import 'package:price_tracker/services/background_worker.dart';
import 'package:price_tracker/services/database.dart';
import 'package:price_tracker/services/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> initApp() async {
  await DatabaseService.init();
  await BackgroundWorkerService.init();
  await NotificationService.init();

  // The following is for Android only! -> see https://github.com/vrtdev/flutter_workmanager#customisation-android-only
  // For iOS, you can set the interval here:
  // ios/Runner/AppDelegate.swift -> in the line   UIApplication.shared.setMinimumBackgroundFetchInterval(
  if (Platform.isAndroid) {
    Workmanager.registerPeriodicTask("priceScraping", "Price Tracker Scraper",
        frequency: Duration(
          hours: 12,
        ));
  }
}

Future<bool> checkFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool seen = prefs.getBool('seen') ?? false;

  if (!seen) prefs.setBool('seen', true);

  return !seen;
}