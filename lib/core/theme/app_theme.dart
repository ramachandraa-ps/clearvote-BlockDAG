import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF4296EA),
      scaffoldBackgroundColor: const Color(0xFF111921),
      fontFamily: 'Lexend',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4296EA),
        brightness: Brightness.dark,
      ),
    );
  }
}