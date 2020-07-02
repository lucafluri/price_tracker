import 'package:flutter/widgets.dart';
import 'package:price_tracker/screens/credits/credits.dart';
import 'package:price_tracker/screens/home/home.dart';
import 'package:price_tracker/screens/intro/intro.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => HomeScreen(),
  "/intro": (context) => IntroScreen(),
  "/credits": (context) => CreditsScreen(),
};
