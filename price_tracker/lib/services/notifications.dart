import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService._privateConstructor();
  static final NotificationService _instance = NotificationService._privateConstructor();

  static NotificationService get instance => _instance;

  static Future<void> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var androidInitializationSettings = AndroidInitializationSettings('app_icon');
    var iOSInitializationSettings = IOSInitializationSettings();

    await _flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(androidInitializationSettings, iOSInitializationSettings)
    );
  }

  static Future<void> sendPushNotification(int id, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(id, title, body, platformChannelSpecifics, payload: 'item x');
  }
}
