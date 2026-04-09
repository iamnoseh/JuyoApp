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
        if (showMesh) _AuroraLayer(isDark: isDark, meshColor: palette.mesh),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.backdropTint,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AuroraLayer extends StatelessWidget {
  const _AuroraLayer({
    required this.isDark,
    required this.meshColor,
  });

  final bool isDark;
  final Color meshColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuroraPainter(
        aquaColor: AppColors.aqua.withValues(alpha: isDark ? 0.24 : 0.18),
        goldColor: AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.12),
        emeraldColor: AppColors.emerald.withValues(alpha: isDark ? 0.12 : 0.08),
        meshColor: meshColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({
    required this.aquaColor,
    required this.goldColor,
    required this.emeraldColor,
    required this.meshColor,
  });

  final Color aquaColor;
  final Color goldColor;
  final Color emeraldColor;
  final Color meshColor;

  @override
  void paint(Canvas canvas, Size size) {
    final aquaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          aquaColor,
          AppColors.aqua.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.18, size.height * 0.14),
          radius: size.width * 0.48,
        ),
      );

    final goldPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          goldColor,
          AppColors.gold.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.86, size.height * 0.22),
          radius: size.width * 0.42,
        ),
      );

    final emeraldPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          emeraldColor,
          AppColors.emerald.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.9),
          radius: size.width * 0.52,
        ),
      );

    canvas.drawRect(Offset.zero & size, aquaPaint);
    canvas.drawRect(Offset.zero & size, goldPaint);
    canvas.drawRect(Offset.zero & size, emeraldPaint);

    final meshPaint = Paint()
      ..color = meshColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const spacing = 36.0;
    for (double dx = -size.height; dx < size.width + size.height; dx += spacing) {
      canvas.drawLine(
        Offset(dx, 0),
        Offset(dx - size.height, size.height),
        meshPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
