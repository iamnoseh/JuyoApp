import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_event.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const DashboardLoadRequested()),
      child: const _DashboardOverviewView(),
    );
  }
}

class _DashboardOverviewView extends StatelessWidget {
  const _DashboardOverviewView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.dashboardTitle,
      subtitle: l10n.dashboardSubtitle,
      trailing: IconButton(
        onPressed: () => context.push(AppRoutes.profile),
        icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
      ),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.aqua));
          }

          if (state is DashboardFailure) {
            return ErrorState(
              title: l10n.errorTitle,
              subtitle: state.message,
              onRetry: () =>
                  context.read<DashboardBloc>().add(const DashboardRefreshRequested()),
            );
          }

          final data = (state as DashboardLoaded).data;
          final user = data.user;
          final progress = data.dashboardStats?.dailyProgress;
          final name = user?.fullName.trim().isEmpty ?? true
              ? 'Student'
              : user!.fullName.split(' ').first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.shellGreeting}, $name',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.motivation.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        StatChip(
                          label: 'XP ${user?.xp ?? 0}',
                          icon: LucideIcons.zap,
                          color: AppColors.gold,
                        ),
                        StatChip(
                          label: 'ELO ${user?.eloRating ?? 0}',
                          icon: LucideIcons.award,
                          color: AppColors.aqua,
                        ),
                        StatChip(
                          label: 'Streak ${user?.streak ?? 0}',
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
                      title: l10n.commonLeague,
                      subtitle: l10n.leagueSubtitle,
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.gold,
                      onTap: () => context.go(AppRoutes.league),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Progress', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress == null || progress.goal == 0
                          ? 0
                          : progress.completed / progress.goal,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: AppColors.aqua,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${progress?.completed ?? 0}/${progress?.goal ?? 0}',
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
                    Text('Top League', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (data.leaderboard.isEmpty)
                      EmptyState(
                        title: l10n.emptyTitle,
                        subtitle: l10n.emptySubtitle,
                        icon: Icons.emoji_events_outlined,
                      )
                    else
                      ...data.leaderboard.take(5).map(
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
          );
        },
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
