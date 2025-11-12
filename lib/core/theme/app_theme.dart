import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF2563EB),
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF22C55E),
    brightness: Brightness.dark,
  );
}
