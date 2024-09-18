import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF862989); // First color for gradient
const Color secondaryColor = Color(0xFF2EC5BB); // Second color for gradient
const Color lightTextColor = Colors.white;
const Color darkTextColor = Colors.black;
const Color textInputColor = Color(0xFFD9D9D9); // Color for text input fields

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    hintColor: darkTextColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Set to transparent to show gradient
      iconTheme: IconThemeData(color: lightTextColor),
      titleTextStyle: GoogleFonts.goldman(
        textStyle: TextStyle(
          color: lightTextColor,
          fontSize: 18, // Title font size
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: textInputColor,
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
    textTheme: GoogleFonts.goldmanTextTheme(
      Theme.of(context).textTheme.apply(
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      ).copyWith(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), // Main title
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), // Secondary title
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Tertiary title
        bodyLarge: TextStyle(fontSize: 18), // Body text
        bodyMedium: TextStyle(fontSize: 16), // Smaller body text
        bodySmall: TextStyle(fontSize: 14), // Captions
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), // Subtitles
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor,
        backgroundColor: secondaryColor, // Button text color
        textStyle: GoogleFonts.goldman(
          fontSize: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}

ThemeData darkTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    hintColor: secondaryColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Set to transparent to show gradient
      iconTheme: IconThemeData(color: lightTextColor),
      titleTextStyle: GoogleFonts.goldman(
        textStyle: TextStyle(
          color: lightTextColor,
          fontSize: 18, // Title font size
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: textInputColor,
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
    textTheme: GoogleFonts.goldmanTextTheme(
      Theme.of(context).textTheme.apply(
        bodyColor: lightTextColor,
        displayColor: lightTextColor,
      ).copyWith(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), // Main title
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), // Secondary title
        displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Tertiary title
        bodyLarge: TextStyle(fontSize: 16), // Body text
        bodyMedium: TextStyle(fontSize: 14), // Smaller body text
        bodySmall: TextStyle(fontSize: 12), // Captions
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), // Subtitles
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor,
        backgroundColor: secondaryColor, // Button text color
        textStyle: GoogleFonts.goldman(
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}
