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
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.base,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.base, AppColors.surface],
            ),
          ),
        ),
        if (showMesh) const _AuroraLayer(),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.base.withValues(alpha: 0.14),
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
  const _AuroraLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuroraPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final aquaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.aqua.withValues(alpha: 0.24),
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
          AppColors.gold.withValues(alpha: 0.18),
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
          AppColors.emerald.withValues(alpha: 0.12),
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
      ..color = Colors.white.withValues(alpha: 0.025)
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
