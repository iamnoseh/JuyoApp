import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.dashboardTitle,
      subtitle: 'Demo dashboard adapted from the frontend structure',
      trailing: const AppHeaderActions(),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final textMuted = Theme.of(context).textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, Demo User',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Keep building momentum. Your mobile app is now running on demo content first, just like we planned.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatChip(
                    label: 'XP 2140',
                    icon: LucideIcons.zap,
                    color: AppColors.gold,
                  ),
                  StatChip(
                    label: 'League Silver',
                    icon: LucideIcons.trophy,
                    color: AppColors.aqua,
                  ),
                  StatChip(
                    label: 'Streak 12',
                    icon: LucideIcons.flame,
                    color: AppColors.emerald,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: 'Continue learning',
                icon: LucideIcons.arrowRight,
                onPressed: () => context.go(AppRoutes.tests),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                title: 'Monthly activity',
                icon: Icons.bar_chart_rounded,
                color: AppColors.aqua,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _BarDay(label: 'Mon', value: 0.42),
                  _BarDay(label: 'Tue', value: 0.64),
                  _BarDay(label: 'Wed', value: 0.58),
                  _BarDay(label: 'Thu', value: 0.83),
                  _BarDay(label: 'Fri', value: 0.76),
                  _BarDay(label: 'Sat', value: 0.52),
                  _BarDay(label: 'Sun', value: 0.91),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                title: 'League status',
                icon: Icons.emoji_events_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Current league',
                      value: 'Silver',
                      accent: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      label: 'Weekly rank',
                      value: '#4',
                      accent: AppColors.aqua,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      label: 'To gold',
                      value: '260 XP',
                      accent: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                title: 'Admission goal',
                icon: LucideIcons.target,
                color: AppColors.gold,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: 0.74,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          '74%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TGMU (DMT)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Medicine',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Passing score target: 312',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                title: 'Cluster subjects',
                icon: Icons.layers_rounded,
                color: AppColors.aqua,
              ),
              const SizedBox(height: 14),
              const _SubjectProgress(name: 'Biology', progress: 0.84, score: '84%'),
              const SizedBox(height: 12),
              const _SubjectProgress(name: 'Chemistry', progress: 0.71, score: '71%'),
              const SizedBox(height: 12),
              const _SubjectProgress(name: 'Physics', progress: 0.58, score: '58%'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                title: 'Daily goals',
                icon: Icons.checklist_rounded,
                color: AppColors.emerald,
              ),
              const SizedBox(height: 14),
              Text('3 / 5 tests completed', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0.6,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(height: 16),
              const _TaskRow(done: true, title: 'Review anatomy lecture'),
              const SizedBox(height: 10),
              const _TaskRow(done: true, title: 'Solve chemistry mini test'),
              const SizedBox(height: 10),
              const _TaskRow(done: false, title: 'Join one duel'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                title: 'Achievements',
                icon: Icons.workspace_premium_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _AchievementBadge(label: 'First Step', icon: LucideIcons.star),
                  _AchievementBadge(label: 'Top 10', icon: LucideIcons.trophy),
                  _AchievementBadge(label: '7 Day Streak', icon: LucideIcons.flame),
                  _AchievementBadge(label: 'Fast Solver', icon: LucideIcons.zap),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optimized for mobile preview: reduced blur, reduced repaint pressure, demo-first content.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textMuted),
        ),
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _CardTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _BarDay extends StatelessWidget {
  final String label;
  final double value;

  const _BarDay({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 120 * value,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.aqua, AppColors.gold],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SubjectProgress extends StatelessWidget {
  final String name;
  final double progress;
  final String score;

  const _SubjectProgress({
    required this.name,
    required this.progress,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, style: Theme.of(context).textTheme.bodyLarge)),
            Text(score, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: progress > 0.7 ? AppColors.emerald : AppColors.gold,
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final bool done;
  final String title;

  const _TaskRow({
    required this.done,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: done ? AppColors.emerald : Theme.of(context).textTheme.bodyMedium?.color,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _AchievementBadge({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
