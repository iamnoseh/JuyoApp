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

@immutable
class AppThemePalette extends ThemeExtension<AppThemePalette> {
  const AppThemePalette({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.backdropTint,
    required this.glass,
    required this.border,
    required this.cardStroke,
    required this.navSurface,
    required this.secondaryFill,
    required this.inputFill,
    required this.mesh,
    required this.shadow,
  });

  final Color backgroundStart;
  final Color backgroundEnd;
  final Color backdropTint;
  final Color glass;
  final Color border;
  final Color cardStroke;
  final Color navSurface;
  final Color secondaryFill;
  final Color inputFill;
  final Color mesh;
  final Color shadow;

  static const light = AppThemePalette(
    backgroundStart: Color(0xFFF7FAFF),
    backgroundEnd: Color(0xFFE8F1FF),
    backdropTint: Color(0x80FFFFFF),
    glass: Color(0xD9FFFFFF),
    border: Color(0x1F0F172A),
    cardStroke: Color(0x140F172A),
    navSurface: Color(0xE6FFFFFF),
    secondaryFill: Color(0xFFF8FAFC),
    inputFill: Color(0xF2FFFFFF),
    mesh: Color(0x120F172A),
    shadow: Color(0x1A0F172A),
  );

  static const dark = AppThemePalette(
    backgroundStart: AppColors.base,
    backgroundEnd: AppColors.surface,
    backdropTint: Color(0x24020617),
    glass: Color(0x14FFFFFF),
    border: AppColors.border,
    cardStroke: AppColors.cardStroke,
    navSurface: Color(0xEA0F172A),
    secondaryFill: Color(0x08FFFFFF),
    inputFill: Color(0x0FFFFFFF),
    mesh: Color(0x08FFFFFF),
    shadow: Color(0x3D020617),
  );

  @override
  AppThemePalette copyWith({
    Color? backgroundStart,
    Color? backgroundEnd,
    Color? backdropTint,
    Color? glass,
    Color? border,
    Color? cardStroke,
    Color? navSurface,
    Color? secondaryFill,
    Color? inputFill,
    Color? mesh,
    Color? shadow,
  }) {
    return AppThemePalette(
      backgroundStart: backgroundStart ?? this.backgroundStart,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      backdropTint: backdropTint ?? this.backdropTint,
      glass: glass ?? this.glass,
      border: border ?? this.border,
      cardStroke: cardStroke ?? this.cardStroke,
      navSurface: navSurface ?? this.navSurface,
      secondaryFill: secondaryFill ?? this.secondaryFill,
      inputFill: inputFill ?? this.inputFill,
      mesh: mesh ?? this.mesh,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppThemePalette lerp(ThemeExtension<AppThemePalette>? other, double t) {
    if (other is! AppThemePalette) return this;
    return AppThemePalette(
      backgroundStart: Color.lerp(backgroundStart, other.backgroundStart, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      backdropTint: Color.lerp(backdropTint, other.backdropTint, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      border: Color.lerp(border, other.border, t)!,
      cardStroke: Color.lerp(cardStroke, other.cardStroke, t)!,
      navSurface: Color.lerp(navSurface, other.navSurface, t)!,
      secondaryFill: Color.lerp(secondaryFill, other.secondaryFill, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      mesh: Color.lerp(mesh, other.mesh, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
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
  static ThemeData get light => _buildTheme(brightness: Brightness.light);

  static ThemeData get dark => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final palette = isDark ? AppThemePalette.dark : AppThemePalette.light;
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF64748B);
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.aqua,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.gold,
      onPrimary: Colors.white,
      secondary: AppColors.aqua,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: isDark ? AppColors.surface : Colors.white,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.backgroundStart,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 14,
          color: textPrimary,
          height: 1.45,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 13,
          color: textSecondary,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: textMuted,
          height: 1.35,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputFill,
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: palette.border),
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
        backgroundColor: isDark ? AppColors.surfaceSoft : const Color(0xFF0F172A),
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
    );
  }
}

extension AppThemeContextX on BuildContext {
  AppThemePalette get appPalette =>
      Theme.of(this).extension<AppThemePalette>() ?? AppThemePalette.dark;
}
