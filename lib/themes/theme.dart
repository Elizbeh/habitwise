import 'package:flutter/material.dart';

class AppThemes {
  // Define your light theme
  static final ThemeData lightTheme = ThemeData(
    hintColor: Color.fromARGB(255, 93, 156, 164),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromRGBO(126, 35, 191, 0.498),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 93, 156, 164),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(126, 35, 191, 1.0),
      primary: Color.fromRGBO(126, 35, 191, 1.0),
      onPrimary: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
    ),
  );

  // Define your dark theme
  static final ThemeData darkTheme = ThemeData(
    hintColor: Color.fromARGB(233, 93, 59, 99),
    scaffoldBackgroundColor: Color.fromARGB(255, 18, 18, 18),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 93, 156, 164),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 93, 156, 164),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(126, 35, 191, 1.0),
      primary: Color.fromRGBO(126, 35, 191, 1.0),
      onPrimary: Colors.white,
      background: Color.fromARGB(255, 18, 18, 18),
      onBackground: Colors.white,
    ),
  );
}
