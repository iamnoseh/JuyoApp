import 'package:flutter/material.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileRoutePage extends StatelessWidget {
  const ProfileRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.profileTitle,
      subtitle: 'Demo profile adapted from the frontend layout',
      trailing: const AppHeaderActions(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.aqua, AppColors.gold],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'JD',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Jamshed Davlatov', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.mapPin, size: 14, color: AppColors.aqua),
                  const SizedBox(width: 6),
                  Text('Dushanbe', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'State Lyceum No. 3 | 17 years old',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              AppSecondaryButton(
                label: 'Edit profile',
                icon: LucideIcons.pencil,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile edit demo will be added next.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.sparkles, size: 18, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your cluster', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 2),
                          Text('Medical Sciences', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.calendarDays, size: 14, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Joined: 14 Sep 2025',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.crown, size: 14, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Premium until: 01 Oct 2026',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            Expanded(
              child: _ProfileStatCard(
                label: 'League',
                value: 'Silver',
                icon: LucideIcons.trophy,
                color: AppColors.gold,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ProfileStatCard(
                label: 'XP',
                value: '2140',
                icon: LucideIcons.flame,
                color: AppColors.emerald,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ProfileStatCard(
                label: 'Rank',
                value: '#12',
                icon: LucideIcons.activity,
                color: AppColors.aqua,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileSectionTitle(
                title: 'Academic mission',
                icon: LucideIcons.target,
                color: AppColors.gold,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TGMU (DMT)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Medicine', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text('Readiness: 74%', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 74,
                          height: 74,
                          child: CircularProgressIndicator(
                            value: 0.74,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            color: AppColors.gold,
                          ),
                        ),
                        Text('74%', style: Theme.of(context).textTheme.titleMedium),
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
              _ProfileSectionTitle(
                title: 'Achievements',
                icon: LucideIcons.award,
                color: AppColors.gold,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _ProfileBadge(label: 'First Step', icon: LucideIcons.star),
                  _ProfileBadge(label: 'Top Student', icon: LucideIcons.trophy),
                  _ProfileBadge(label: 'Fast Learner', icon: LucideIcons.zap),
                  _ProfileBadge(label: '7 Day Streak', icon: LucideIcons.flame),
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
              _ProfileSectionTitle(
                title: 'Skill progress',
                icon: LucideIcons.activity,
                color: AppColors.aqua,
              ),
              const SizedBox(height: 14),
              const _ProfileSkill(name: 'Biology', percent: 84),
              const SizedBox(height: 12),
              const _ProfileSkill(name: 'Chemistry', percent: 71),
              const SizedBox(height: 12),
              const _ProfileSkill(name: 'Physics', percent: 58),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileSectionTitle(
                title: 'Last 5 tests',
                icon: LucideIcons.bookOpen,
                color: AppColors.emerald,
              ),
              const SizedBox(height: 14),
              const _ActivityRow(
                title: 'Exam mode',
                subject: 'Biology',
                score: '86 points',
                status: 'Completed',
                success: true,
              ),
              const SizedBox(height: 10),
              const _ActivityRow(
                title: 'Duel',
                subject: 'Chemistry',
                score: '71 points',
                status: 'Completed',
                success: true,
              ),
              const SizedBox(height: 10),
              const _ActivityRow(
                title: 'Practice',
                subject: 'Physics',
                score: '0 points',
                status: 'Failed',
                success: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _ProfileSectionTitle({
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

class _ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ProfileBadge({
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

class _ProfileSkill extends StatelessWidget {
  final String name;
  final int percent;

  const _ProfileSkill({
    required this.name,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, style: Theme.of(context).textTheme.bodyLarge)),
            Text('$percent%', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: percent > 70 ? AppColors.aqua : AppColors.gold,
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String title;
  final String subject;
  final String score;
  final String status;
  final bool success;

  const _ActivityRow({
    required this.title,
    required this.subject,
    required this.score,
    required this.status,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (success ? AppColors.emerald : AppColors.danger).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Icon(
              success ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: success ? AppColors.emerald : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(subject, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: success ? AppColors.gold : AppColors.danger,
                    ),
              ),
              const SizedBox(height: 2),
              Text(status, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
