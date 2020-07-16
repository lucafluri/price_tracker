import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:price_tracker/services/init.dart';
import 'package:price_tracker/services/product_utils.dart';

import 'package:rxdart/subjects.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static NotificationAppLaunchDetails notificationAppLaunchDetails;
  static String currentPayload;

  NotificationService._privateConstructor();

  static final NotificationService _instance =
      NotificationService._privateConstructor();

  static NotificationService get instance => _instance;

  static Future<void> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // Info if app was launched from notification
    notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    var iOSInitializationSettings = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });

    var initializationSettings = InitializationSettings(
        androidInitializationSettings, iOSInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
        currentPayload = payload;

        // If state is mounted, the app is in memory,
        // else the app starts and the callback gets triggered in the home view
        if (navigatorKey.currentState.mounted) notificationTapCallback(payload);
      }
      selectNotificationSubject.add(payload);
    });
  }

  static Future<void> sendAlertPushNotificationSmall(
      int id, String title, String body,
      {String payload = ""}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      'Price Alerts',
      'Price change alerts for tracked products',
      importance: Importance.Max,
      priority: Priority.High,
      // ticker: 'ticker',
      // icon: 'app_icon',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);

    print("Push notifications was sent!");
  }

  static Future<void> sendAlertPushNotificationBig(
      int id, String title, String body,
      {String payload = ""}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '0', 'Price Alerts', 'Price change alerts for tracked products',
        importance: Importance.Max,
        priority: Priority.High,
        // ticker: 'ticker',
        // icon: 'app_icon',
        styleInformation: BigTextStyleInformation(body));
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);

    print("Push notifications was sent!");
  }
}

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

/// For iOS-notifications:
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

/// For iOS-notifications:
class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
