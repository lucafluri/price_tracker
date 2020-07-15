import 'package:flutter/widgets.dart';
import 'package:price_tracker/screens/home/home.dart';
import 'package:price_tracker/screens/intro/intro.dart';
import 'package:price_tracker/screens/settings/settings.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => HomeScreen(),
  "/intro": (context) => IntroScreen(),
  "/settings": (context) => SettingsScreen(),
};
