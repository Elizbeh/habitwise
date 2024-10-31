import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF862989); // First color for gradient
const Color secondaryColor = Color(0xFF2EC5BB); // Second color for gradient
const Color lightTextColor = Colors.white;
const Color darkTextColor = Colors.black;
const Color lightTextInputColor = Colors.white;
const Color darkTextInputColor = Color.fromARGB(255, 93, 93, 93); // Darkened for dark mode input fields

double getAdaptiveFontSize(BuildContext context, double size) {
  double baseWidth = 375; // Base width (for design reference)
  double scaleFactor = MediaQuery.of(context).size.width / baseWidth;
  return size * scaleFactor;
}

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Color.fromARGB(255, 237, 234, 234),
      onPrimary: lightTextColor,
      onSecondary: darkTextColor,
      onBackground: darkTextColor,
    ),
    scaffoldBackgroundColor: Color.fromARGB(255, 237, 234, 234),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Set to transparent to show gradient
      iconTheme: IconThemeData(color: lightTextColor),
      titleTextStyle: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: lightTextColor,
          fontSize: getAdaptiveFontSize(context, 26), // Title font size
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightTextInputColor, // Light mode input field color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: secondaryColor, width: 2.0),
      ),
      hintStyle: TextStyle(color: secondaryColor),
    ),
    textTheme: GoogleFonts.robotoTextTheme(
      Theme.of(context).textTheme.apply(
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      ).copyWith(
        displayLarge: TextStyle(fontSize: getAdaptiveFontSize(context, 30), fontWeight: FontWeight.bold), // Main title
        displayMedium: TextStyle(fontSize: getAdaptiveFontSize(context, 26), fontWeight: FontWeight.bold), // Secondary title
        displaySmall: TextStyle(fontSize: getAdaptiveFontSize(context, 22), fontWeight: FontWeight.bold), // Tertiary title
        bodyLarge: TextStyle(fontSize: getAdaptiveFontSize(context, 16)), // Body text
        bodyMedium: TextStyle(fontSize: getAdaptiveFontSize(context, 15)), // Smaller body text
        bodySmall: TextStyle(fontSize: getAdaptiveFontSize(context, 13)), // Captions
        titleMedium: TextStyle(fontSize: getAdaptiveFontSize(context, 20), fontWeight: FontWeight.w600), // Subtitles
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor,
        backgroundColor: secondaryColor, // Button background color
        textStyle: GoogleFonts.roboto(
          fontSize: getAdaptiveFontSize(context, 20),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      minWidth: 100, // Customize width
      selectedIconTheme: IconThemeData(size: 30), // Selected icon size
      unselectedIconTheme: IconThemeData(size: 24), // Unselected icon size
      labelType: NavigationRailLabelType.all, // Show labels for all items
    ),
  );
}

ThemeData darkTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Color.fromRGBO(28, 28, 36, 1.0),
      onPrimary: lightTextColor,
      onSecondary: lightTextColor,
      onBackground: lightTextColor,
    ),
    scaffoldBackgroundColor: Color.fromRGBO(28, 28, 36, 1.0),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Set to transparent to show gradient
      iconTheme: IconThemeData(color: lightTextColor),
      titleTextStyle: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: lightTextColor,
          fontSize: getAdaptiveFontSize(context, 26), // Title font size
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkTextInputColor, // Dark mode input field color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: secondaryColor, width: 2.0),
      ),
      hintStyle: TextStyle(color: secondaryColor),
    ),
    textTheme: GoogleFonts.robotoTextTheme(
      Theme.of(context).textTheme.apply(
        bodyColor: lightTextColor,
        displayColor: lightTextColor,
      ).copyWith(
        displayLarge: TextStyle(fontSize: getAdaptiveFontSize(context, 30), fontWeight: FontWeight.bold), // Main title
        displayMedium: TextStyle(fontSize: getAdaptiveFontSize(context, 26), fontWeight: FontWeight.bold), // Secondary title
        displaySmall: TextStyle(fontSize: getAdaptiveFontSize(context, 22), fontWeight: FontWeight.bold), // Tertiary title
        bodyLarge: TextStyle(fontSize: getAdaptiveFontSize(context, 18)), // Body text
        bodyMedium: TextStyle(fontSize: getAdaptiveFontSize(context, 16)), // Smaller body text
        bodySmall: TextStyle(fontSize: getAdaptiveFontSize(context, 14)), // Captions
        titleMedium: TextStyle(fontSize: getAdaptiveFontSize(context, 20), fontWeight: FontWeight.w600), // Subtitles
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor,
        backgroundColor: secondaryColor, // Button background color
        textStyle: GoogleFonts.roboto(
          fontSize: getAdaptiveFontSize(context, 22),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      minWidth: 100, // Customize width
      selectedIconTheme: IconThemeData(size: 30), // Selected icon size
      unselectedIconTheme: IconThemeData(size: 24), // Unselected icon size
      labelType: NavigationRailLabelType.all, // Show labels for all items
    ),
  );
}
