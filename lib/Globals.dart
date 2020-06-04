import 'package:flutter/material.dart';

class Globals {
  static Color primaryBlue = Color(0xFF1D1C4D);
  static Color primaryOrange = Color(0xFFD07948);
  static Color buttonColor = Color(0xFF42528B);

  static MaterialColor colorSwatch = MaterialColor(primaryBlue.value, <int, Color>{
    50: Color(0xFF1D1C4D),
    100: Color(0xFF1D1C4D),
    200: Color(0xFF1D1C4D),
    300: Color(0xFF1D1C4D),
    400: Color(0xFF1D1C4D),
    500: Color(0xFF1D1C4D),
    600: Color(0xFF1D1C4D),
    700: Color(0xFF1D1C4D),
    800: Color(0xFF1D1C4D),
    900: Color(0xFF1D1C4D),
  });

  static ThemeData theme = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Globals.colorSwatch,
    fontFamily: "Montserrat",
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 30, inherit: true, color: Colors.white, letterSpacing: 4,
          fontWeight: FontWeight.w300),
      bodyText2: TextStyle(fontSize: 25, inherit: true, color: Colors.white, letterSpacing: 4,
          fontWeight: FontWeight.w300)
    ),
    iconTheme: IconThemeData(
      color: primaryOrange,
      opacity: 1,
    ),
    buttonTheme: ButtonThemeData(
      minWidth: 200,
    )
  );
}

