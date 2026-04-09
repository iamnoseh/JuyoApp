import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const Color base = Color(0xFF020617);
  static const Color navy = surface;
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceSoft = Color(0xFF16213E);
  static const Color surfaceCard = Color(0xAA0F172A);
  static const Color aqua = Color(0xFF0DCCF2);
  static const Color aquaSoft = Color(0xFF38BDF8);
  static const Color gold = Color(0xFFF59E0B);
  static const Color emerald = Color(0xFF10B981);
  static const Color danger = Color(0xFFF43F5E);
  static const Color red = danger;
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color slate = textMuted;
  static const Color border = Color(0x1FFFFFFF);
  static const Color cardStroke = Color(0x14FFFFFF);
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color canvasCard = Colors.white;
  static const Color background = base;
  static const Color lightBg = canvas;
  static const Color milkyCard = canvasCard;
  static const Color darkSlate = surfaceSoft;
}

abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppShadows {
  static const List<BoxShadow> glass = <BoxShadow>[
    BoxShadow(
      color: Color(0x3D020617),
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];
}

class AppTheme {
  static ThemeData get light {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.base,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.gold,
        onPrimary: Colors.white,
        secondary: AppColors.aqua,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.45,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: AppColors.textMuted,
          height: 1.35,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.aqua, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceSoft,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
    );
  }
}
