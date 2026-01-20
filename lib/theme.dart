import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  
  textTheme: GoogleFonts.openSansTextTheme().apply(
    bodyColor: Colors.black87,
    displayColor: Colors.white,    
  ),  
  /*
  appBarTheme: const AppBarTheme(
    //backgroundColor: Color.fromARGB(255, 113, 243, 230),
    backgroundColor: Colors.white10,
    elevation: 4,
  ),
  */
  colorScheme: const ColorScheme.light(
    //primary: Color(0xFF0097A7),
    //secondary: Color(0xFF009688),
    //surface: Color(0xFFE0F2F1),
    
    primary: Colors.black87,
    secondary: Colors.black87,
    surface: Colors.white,
    onSurface: Colors.black87,

  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.black87),
    hintStyle: TextStyle(color: Colors.black54),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);

final darkTheme = ThemeData(
  textTheme: GoogleFonts.openSansTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.black,
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.white,
    surface: Colors.black87,
    onSurface: Colors.white,

  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white70),
    hintStyle: TextStyle(color: Colors.white54),
    // Makes the field background visible
    filled: true,
    fillColor: Color(0xFF1E1E1E), // slightly lighter than black
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white38),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black87,
    foregroundColor: Colors.white,
  ),
);