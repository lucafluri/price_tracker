import 'dart:async';

import 'package:price_tracker/services/init.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentService {
  // ignore: cancel_subscriptions
  // ignore: unused_field
  static StreamSubscription _intentDataStreamSubscription;
  static String sharedText;

  ShareIntentService._privateConstructor();

  static final ShareIntentService _instance =
      ShareIntentService._privateConstructor();

  static ShareIntentService get instance => _instance;

  static Future<void> init() async {
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      sharedText = value;
      // Navigate to Home Screen so that _checkForSharedText gets called
      navigatorKey.currentState.pushNamedAndRemoveUntil("/", (route) => false);
      print("Shared: $sharedText");
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      sharedText = value;
      // CheckSharedText in HomeController gets called and executed since app started
      print("Shared: $sharedText");
    });
  }
}
