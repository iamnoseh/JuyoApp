import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:juyo/core/theme/app_theme.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;
  final bool showMesh;

  const AuroraBackground({
    super.key,
    required this.child,
    this.showMesh = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : const Color(0xFF0F172A).withValues(alpha: 0.02);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: palette.backgroundStart,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.backgroundStart, palette.backgroundEnd],
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: overlayColor,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
