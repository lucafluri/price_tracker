import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:price_tracker/utils/product_utils.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path/path.dart' as p;




FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Directory _appDocsDir;

Future<void> startApp() async {
  _appDocsDir = await getApplicationDocumentsDirectory();

  Workmanager.initialize(callbackDispatcher, isInDebugMode: false);
  print('init work manager');

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

File fileFromDocsDir(String filename) {
  String pathName = p.join(_appDocsDir.path, filename);
  return File(pathName);
}

void pushNotification(int id, String title, String body) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(id, title, body, platformChannelSpecifics, payload: 'item x');
}

void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Init Notifications Plugin
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

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