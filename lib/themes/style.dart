import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    // primarySwatch: Colors.yellow,
    primaryColor: Colors.yellow[400],
    accentColor: Colors.yellowAccent[400],
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}