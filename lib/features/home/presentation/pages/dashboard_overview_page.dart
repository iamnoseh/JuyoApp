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
    final topUsers = <({int rank, String name, String xp, bool isMe})>[
      (rank: 1, name: 'Muhammad', xp: '2480', isMe: false),
      (rank: 2, name: 'Zarina', xp: '2310', isMe: false),
      (rank: 3, name: 'Jamshed', xp: '2190', isMe: false),
      (rank: 4, name: 'You', xp: '2140', isMe: true),
    ];

    return AppScaffold(
      title: l10n.dashboardTitle,
      subtitle: l10n.dashboardSubtitle,
      trailing: IconButton(
        onPressed: () => context.push(AppRoutes.profile),
        icon: Icon(
          Icons.person_outline_rounded,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.shellGreeting}, Demo User',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'This dashboard is running on demo data so you can test the full mobile UI before API wiring.',
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
                      label: 'ELO 1520',
                      icon: LucideIcons.award,
                      color: AppColors.aqua,
                    ),
                    StatChip(
                      label: 'Streak 12',
                      icon: LucideIcons.flame,
                      color: AppColors.emerald,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  title: l10n.commonTests,
                  subtitle: l10n.testsSubtitle,
                  icon: Icons.menu_book_rounded,
                  color: AppColors.aqua,
                  onTap: () => context.go(AppRoutes.tests),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickTile(
                  title: l10n.duelTitle,
                  subtitle: l10n.duelSubtitle,
                  icon: Icons.flash_on_rounded,
                  color: AppColors.gold,
                  onTap: () => context.go(AppRoutes.duel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily progress', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.68,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    color: AppColors.aqua,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '68 / 100 XP today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top league', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ...topUsers.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: item.isMe
                              ? AppColors.gold.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.08),
                          child: Text(
                            '${item.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          item.xp,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.gold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
