import 'package:flutter/material.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AuthLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Top Section with Geometric Pattern
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                    ),
                    image: DecorationImage(
                      image: const NetworkImage(
                        'https://www.transparenttextures.com/patterns/cubes.png',
                      ),
                      repeat: ImageRepeat.repeat,
                      opacity: isDark ? 0.05 : 0.1,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        // Juyo Logo Icon
                        Hero(
                          tag: 'logo',
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.graduationCap, color: AppColors.navy, size: 32),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Split Color Branding: J (Gold) uyo (Aqua)
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                            children: [
                              TextSpan(text: 'J', style: TextStyle(color: AppColors.gold)),
                              TextSpan(text: 'UYO', style: TextStyle(color: AppColors.aqua)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Back Button (Optional, for Register/Forgot)
                if (Navigator.canPop(context))
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
              ],
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
