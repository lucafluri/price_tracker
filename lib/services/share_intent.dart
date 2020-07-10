import 'dart:async';


import 'package:receive_sharing_intent/receive_sharing_intent.dart';


class ShareIntentService {
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
      print("Shared: $sharedText");
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      sharedText = value;
      print("Shared: $sharedText");
    });
  }


}
