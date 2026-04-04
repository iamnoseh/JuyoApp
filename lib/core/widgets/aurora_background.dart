import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:juyo/core/theme/app_theme.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Refined Deep Navy Base
        Positioned.fill(
          child: Container(
            color: isDark ? AppColors.navy : AppColors.lightBg,
          ),
        ),
        
        // Futuristic Aurora Blobs (Gold & Aqua)
        Positioned.fill(
          child: AuroraPainter(isDark: isDark),
        ),
        
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 130, sigmaY: 130),
            child: Container(
              color: isDark 
                ? AppColors.navy.withOpacity(0.55) 
                : AppColors.lightBg.withOpacity(0.4),
            ),
          ),
        ),

        // Noise Texture Overly
        Positioned.fill(
          child: Opacity(
            opacity: isDark ? 0.04 : 0.015,
            child: Image.network(
              'https://www.transparenttextures.com/patterns/noise.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
            ),
          ),
        ),

        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}

class AuroraPainter extends StatefulWidget {
  final bool isDark;
  const AuroraPainter({super.key, required this.isDark});

  @override
  State<AuroraPainter> createState() => _AuroraPainterState();
}

class _AuroraPainterState extends State<AuroraPainter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AuroraElementPainter(_controller.value, widget.isDark),
        );
      },
    );
  }
}

class _AuroraElementPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _AuroraElementPainter(this.progress, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final double intensity = isDark ? 0.18 : 0.08;
    
    final paintAqua = Paint()
      ..color = AppColors.aqua.withOpacity(intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final paintGold = Paint()
      ..color = AppColors.gold.withOpacity(intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Aqua - Bottom Left
    canvas.drawCircle(
      Offset(
        size.width * 0.1 + (progress * 60),
        size.height * 0.85 - (progress * 35),
      ),
      size.width * 0.8,
      paintAqua,
    );

    // Gold - Top Right
    canvas.drawCircle(
      Offset(
        size.width * 0.9 - (progress * 45),
        size.height * 0.15 + (progress * 55),
      ),
      size.width * 0.7,
      paintGold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
