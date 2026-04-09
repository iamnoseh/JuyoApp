import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/core/widgets/aurora_background.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IQRA',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.splashTagline,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.landingHeroTitle,
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.landingHeroSubtitle,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              const Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  StatChip(
                                    label: 'AI',
                                    icon: Icons.auto_awesome_rounded,
                                    color: AppColors.aqua,
                                  ),
                                  StatChip(
                                    label: 'XP',
                                    icon: Icons.bolt_rounded,
                                    color: AppColors.gold,
                                  ),
                                  StatChip(
                                    label: 'Live Duel',
                                    icon: Icons.flash_on_rounded,
                                    color: AppColors.emerald,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FeatureCard(
                          title: l10n.landingFeatureFast,
                          subtitle: l10n.landingFeatureFastSubtitle,
                          icon: Icons.rocket_launch_rounded,
                          color: AppColors.gold,
                        ),
                        const SizedBox(height: 12),
                        _FeatureCard(
                          title: l10n.landingFeatureAi,
                          subtitle: l10n.landingFeatureAiSubtitle,
                          icon: Icons.analytics_rounded,
                          color: AppColors.aqua,
                        ),
                        const SizedBox(height: 12),
                        _FeatureCard(
                          title: l10n.landingFeatureLeague,
                          subtitle: l10n.landingFeatureLeagueSubtitle,
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.emerald,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppPrimaryButton(
                  label: l10n.landingPrimaryCta,
                  onPressed: () => context.go(AppRoutes.login),
                ),
                const SizedBox(height: 12),
                AppSecondaryButton(
                  label: l10n.landingSecondaryCta,
                  onPressed: () => context.go(AppRoutes.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
