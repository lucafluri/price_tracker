import 'package:flutter/material.dart';
import 'package:price_tracker/routes.dart';
import 'package:price_tracker/services/init.dart';
import 'package:price_tracker/themes/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool _seen = (prefs.getBool('seen') ?? false);

  runApp(PriceTrackerApp(firstLaunch: !_seen,));
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
      initialRoute: firstLaunch ? '/intro' : '/',
      routes: routes,
    );
  }
}