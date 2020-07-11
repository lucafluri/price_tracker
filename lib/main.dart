import 'package:flutter/material.dart';
import 'package:price_tracker/routes.dart';
import 'package:price_tracker/services/init.dart';
import 'package:price_tracker/themes/style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initApp();

  bool firstLaunch = await checkFirstLaunch();

  runApp(PriceTrackerApp(
    firstLaunch: firstLaunch,
  ));
}

class PriceTrackerApp extends StatelessWidget {
  final bool firstLaunch;

  PriceTrackerApp({this.firstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Tracker BETA',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      navigatorKey: navigatorKey,
      initialRoute: firstLaunch ? '/intro' : '/',
      routes: routes,
    );
  }
}
