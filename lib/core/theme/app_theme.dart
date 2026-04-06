import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Juyo Core Palette
  static const Color aqua = Color(0xFF0DCCF2);      // Vibrant Aqua
  static const Color gold = Color(0xFFF59E0B);      // Premium Gold
  static const Color navy = Color(0xFF0F172A);      // Deep Navy for curves/accents
  
  // Neutral Palette
  static const Color lightBg = Color(0xFFF3F6FB);
  static const Color background = Color(0xFFF3F6FB);
  static const Color milkyCard = Color(0xFFFFFFFF);
  static const Color slate = Color(0xFF64748B);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color red = Color(0xFFF43F5E);
}

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.aqua,
        brightness: brightness,
        surface: AppColors.milkyCard,
      ).copyWith(
        primary: AppColors.gold,
        secondary: AppColors.aqua,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w900, 
          letterSpacing: -1.0, 
          fontSize: 26,
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800, 
          letterSpacing: -0.5, 
          fontSize: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.aqua, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
