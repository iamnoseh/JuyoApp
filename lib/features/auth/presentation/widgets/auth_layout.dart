import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/core/widgets/aurora_background.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final bool canPop;

  const AuthLayout({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.canPop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canPop)
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'IQRA',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          letterSpacing: 4,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      child,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
