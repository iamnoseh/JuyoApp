import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';
import 'package:juyo/features/home/domain/entities/dashboard_data.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_event.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardOverviewPage extends StatefulWidget {
  const DashboardOverviewPage({super.key});

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  late final DashboardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<DashboardBloc>()..add(const DashboardLoadRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    _bloc.add(const DashboardRefreshRequested());
    await _bloc.stream.firstWhere(
      (state) => state is DashboardLoaded || state is DashboardFailure,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final data = state is DashboardLoaded ? state.data : null;
          final user = data?.user;

          return AppScaffold(
            topBar: AppTopStatsBar(
              totalXp: user?.xp ?? 0,
              streak: user?.streak ?? 0,
            ),
            title: '',
            showHeader: false,
            scrollable: false,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (state is DashboardLoading || state is DashboardInitial)
                    const _LoadingView()
                  else if (state is DashboardFailure)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ErrorState(
                        title: _tr(
                          context,
                          'Не удалось загрузить дашбоард',
                          'Could not load dashboard',
                        ),
                        subtitle: state.message,
                        onRetry: () => _bloc.add(const DashboardLoadRequested()),
                      ),
                    )
                  else if (data != null)
                    _DashboardSections(data: data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardSections extends StatelessWidget {
  final DashboardData data;

  const _DashboardSections({required this.data});

  @override
  Widget build(BuildContext context) {
    final user = data.user;
    final stats = data.dashboardStats;
    final subjectRows = data.skills.isNotEmpty
        ? data.skills
            .map(
              (item) => _SubjectRowData(
                item.subjectName,
                item.proficiencyPercent.clamp(0, 100).toInt(),
              ),
            )
            .toList()
        : (stats?.subjectPerformance ?? const <SubjectPerformanceModel>[])
            .map(
              (item) => _SubjectRowData(
                item.subject,
                item.score.clamp(0, 100).toInt(),
              ),
            )
            .toList();
    subjectRows.sort((a, b) => b.score.compareTo(a.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(user: user, motivation: data.motivation),
        const SizedBox(height: 14),
        _ActivityCard(stats: stats, user: user),
        const SizedBox(height: 14),
        _LeagueCard(user: user, leaderboard: data.leaderboard),
        const SizedBox(height: 14),
        _AdmissionCard(user: user, admissionStats: data.admissionStats, stats: stats),
        const SizedBox(height: 14),
        _SubjectsCard(clusterName: user?.clusterName, items: subjectRows.take(5).toList()),
        const SizedBox(height: 14),
        _DailyGoalsCard(user: user, stats: stats),
        const SizedBox(height: 14),
        _AchievementsCard(user: user, stats: stats),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final UserModel? user;
  final DashboardMotivation motivation;

  const _HeroCard({required this.user, required this.motivation});

  @override
  Widget build(BuildContext context) {
    final quote = _cleanText(
      motivation.content,
      _tr(
        context,
        'Знание растет, когда вы двигаетесь каждый день.',
        'Knowledge grows when you move forward every day.',
      ),
    );
    final author = _cleanText(motivation.author, '');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        context,
                        'С возвращением, ${_firstName(user?.fullName)}',
                        'Welcome back, ${_firstName(user?.fullName)}',
                      ),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('“$quote”', style: Theme.of(context).textTheme.bodyMedium),
                    if (author.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '— $author',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.gold),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AvatarBadge(user: user),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatChip(
                label: (user?.currentLeagueName?.trim().isNotEmpty ?? false)
                    ? user!.currentLeagueName!
                    : _tr(context, 'Студент', 'Student'),
                icon: LucideIcons.trophy,
                color: AppColors.aqua,
              ),
              if ((user?.globalRank ?? 0) > 0)
                StatChip(
                  label: _tr(
                    context,
                    'Ранг #${user!.globalRank}',
                    'Rank #${user!.globalRank}',
                  ),
                  icon: LucideIcons.award,
                  color: AppColors.gold,
                ),
              if (user?.isPremium == true)
                const StatChip(
                  label: 'Premium',
                  icon: LucideIcons.crown,
                  color: AppColors.gold,
                ),
            ],
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: _tr(context, 'Продолжить обучение', 'Continue learning'),
            icon: LucideIcons.arrowRight,
            onPressed: () => context.go(AppRoutes.tests),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final DashboardStatsModel? stats;
  final UserModel? user;

  const _ActivityCard({required this.stats, required this.user});

  @override
  Widget build(BuildContext context) {
    final all = stats?.dailyActivity ?? const <DailyActivityModel>[];
    final bars = all.length > 7 ? all.sublist(all.length - 7) : all;
    final total = all.fold<int>(0, (sum, item) => sum + item.testsCount);
    final maxValue = math.max(
      1,
      bars.fold<int>(0, (sum, item) => math.max(sum, item.testsCount)),
    );
    final accuracy = _accuracy(stats);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: _tr(context, 'Активность', 'Activity'),
            icon: Icons.insights_rounded,
            color: AppColors.aqua,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: _tr(context, 'Тестов', 'Tests'),
                  value: '$total',
                  color: AppColors.aqua,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: _tr(context, 'Точность', 'Accuracy'),
                  value: '$accuracy%',
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: _tr(context, 'Красный список', 'Red List'),
                  value: '${stats?.todoRedListCount ?? 0}',
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  (bars.isEmpty
                          ? List<DailyActivityModel>.generate(
                              7,
                              (_) => DailyActivityModel(date: '', testsCount: 0),
                            )
                          : bars)
                      .map(
                        (item) => Expanded(
                          child: _BarItem(item: item, maxValue: maxValue),
                        ),
                      )
                      .toList(),
            ),
          ),
          if ((user?.lastTestResults.length ?? 0) > 0) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user!.lastTestResults.take(3).map((item) {
                final label =
                    item.subjectName?.trim().isNotEmpty == true
                    ? item.subjectName!
                    : _tr(context, 'Общий тест', 'General test');
                return _Pill(text: '$label • ${item.totalScore}');
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  int _accuracy(DashboardStatsModel? stats) {
    final items = stats?.subjectPerformance ?? const <SubjectPerformanceModel>[];
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, item) => sum + item.score);
    return (total / items.length).round().clamp(0, 100);
  }
}

class _LeagueCard extends StatelessWidget {
  final UserModel? user;
  final List<LeagueLeaderboardModel> leaderboard;

  const _LeagueCard({required this.user, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    final me = leaderboard
        .cast<LeagueLeaderboardModel?>()
        .firstWhere((item) => item?.isMe == true, orElse: () => null);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionTitle(
                  title:
                      user?.currentLeagueName?.trim().isNotEmpty == true
                      ? user!.currentLeagueName!
                      : _tr(context, 'Лига', 'League'),
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.gold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.league),
                child: Text(_tr(context, 'Открыть', 'Open')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: _tr(context, 'Место', 'Place'),
                  value:
                      (me?.rank ?? user?.globalRank ?? 0) > 0
                      ? '#${me?.rank ?? user?.globalRank}'
                      : '—',
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: 'XP',
                  value: '${_parseXp(me?.xp) ?? user?.xp ?? 0}',
                  color: AppColors.aqua,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: _tr(context, 'Premium', 'Premium'),
                  value:
                      user?.isPremium == true
                      ? _tr(context, 'Да', 'Yes')
                      : _tr(context, 'Нет', 'No'),
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (leaderboard.isEmpty)
            EmptyState(
              title: _tr(context, 'Рейтинг пока пуст', 'Leaderboard is empty'),
              subtitle: _tr(
                context,
                'Когда данные появятся, лучшие игроки будут здесь.',
                'Top players will appear here when data is available.',
              ),
              icon: Icons.emoji_events_outlined,
            )
          else
            Column(
              children: leaderboard
                  .take(4)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LeaderboardRow(item: item),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  int? _parseXp(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
  }
}

class _AdmissionCard extends StatelessWidget {
  final UserModel? user;
  final AdmissionStatsModel? admissionStats;
  final DashboardStatsModel? stats;

  const _AdmissionCard({
    required this.user,
    required this.admissionStats,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final university =
        (admissionStats?.targetUniversity ??
                admissionStats?.universityName ??
                user?.targetUniversity ??
                '')
            .trim();
    final major =
        (admissionStats?.targetMajorName ??
                admissionStats?.specialtyName ??
                user?.targetMajorName ??
                '')
            .trim();
    final probability = ((admissionStats?.admissionProbability ??
                (stats?.universityProbability.isNotEmpty == true
                    ? stats!.universityProbability.first.percent
                    : 0)))
        .round()
        .clamp(0, 100)
        .toInt();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: _tr(
              context,
              'Готовность к поступлению',
              'Admission readiness',
            ),
            icon: LucideIcons.target,
            color: AppColors.gold,
          ),
          const SizedBox(height: 14),
          if (university.isEmpty && major.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(
                    context,
                    'Пока не выбрана цель поступления.',
                    'No admission target has been selected yet.',
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                AppSecondaryButton(
                  label: _tr(context, 'Открыть профиль', 'Open profile'),
                  icon: Icons.person_outline_rounded,
                  onPressed: () => context.go(AppRoutes.profile),
                ),
              ],
            )
          else
            Row(
              children: [
                _Ring(value: probability),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.isEmpty ? '—' : university,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        major.isEmpty ? '—' : major,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ScorePill(
                              label: '2024',
                              value: _score(
                                admissionStats?.targetPassingScore2024 ??
                                    user?.targetPassingScore2024,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ScorePill(
                              label: '2025',
                              value: _score(
                                admissionStats?.targetPassingScore2025 ??
                                    user?.targetPassingScore2025,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ScorePill(
                              label: _tr(context, 'Цель', 'Target'),
                              value: _score(
                                admissionStats?.targetPassingScore != 0
                                    ? admissionStats?.targetPassingScore
                                    : user?.targetPassingScore,
                              ),
                              highlighted: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _score(num? value) {
    if (value == null || value <= 0) return '—';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}

class _SubjectsCard extends StatelessWidget {
  final String? clusterName;
  final List<_SubjectRowData> items;

  const _SubjectsCard({required this.clusterName, required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: clusterName?.trim().isNotEmpty == true
                ? clusterName!
                : _tr(context, 'Подготовка по предметам', 'Subject preparation'),
            icon: Icons.layers_rounded,
            color: AppColors.aqua,
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            EmptyState(
              title: _tr(context, 'Нет данных по предметам', 'No subject data yet'),
              subtitle: _tr(
                context,
                'Ваш прогресс появится после решения тестов.',
                'Your progress will appear after solving tests.',
              ),
              icon: Icons.menu_book_outlined,
            )
          else
            Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectProgressRow(item: item),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DailyGoalsCard extends StatelessWidget {
  final UserModel? user;
  final DashboardStatsModel? stats;

  const _DailyGoalsCard({required this.user, required this.stats});

  @override
  Widget build(BuildContext context) {
    final completed = stats?.dailyProgress.completed ?? 0;
    final goal = math.max(1, stats?.dailyProgress.goal ?? 0);
    final progress = (completed / goal).clamp(0.0, 1.0);
    final tasks = <MapEntry<String, bool>>[
      MapEntry(
        _tr(context, 'Завершить дневной план тестов', 'Complete daily test goal'),
        completed >= goal,
      ),
      MapEntry(
        _tr(context, 'Разобрать красный список', 'Review red list'),
        (stats?.todoRedListCount ?? 0) == 0,
      ),
      MapEntry(
        _tr(context, 'Сохранить серию сегодня', 'Keep your streak today'),
        completed > 0 || (user?.streak ?? 0) > 0,
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: _tr(context, 'Цели на сегодня', 'Daily goals'),
            icon: Icons.checklist_rounded,
            color: AppColors.emerald,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _tr(
                    context,
                    '$completed из $goal тестов завершено',
                    '$completed of $goal tests completed',
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.emerald,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: context.appPalette.secondaryFill,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(height: 16),
          ...tasks.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskRow(title: entry.key, done: entry.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final UserModel? user;
  final DashboardStatsModel? stats;

  const _AchievementsCard({required this.user, required this.stats});

  @override
  Widget build(BuildContext context) {
    final subjectPerformance = stats?.subjectPerformance ?? const <SubjectPerformanceModel>[];
    final accuracy = subjectPerformance.isEmpty
        ? 0
        : (subjectPerformance.fold<int>(0, (sum, item) => sum + item.score) /
                  subjectPerformance.length)
              .round();
    final items = <_BadgeData>[
      _BadgeData(
        LucideIcons.flame,
        (user?.streak ?? 0) >= 7
            ? _tr(context, 'Серия 7+', '7+ streak')
            : _tr(context, 'Держите серию', 'Keep your streak'),
        (user?.streak ?? 0) >= 7,
        AppColors.emerald,
      ),
      _BadgeData(
        LucideIcons.zap,
        (user?.xp ?? 0) >= 1000
            ? '1000 XP'
            : _tr(context, 'До 1000 XP', 'Road to 1000 XP'),
        (user?.xp ?? 0) >= 1000,
        AppColors.gold,
      ),
      _BadgeData(
        LucideIcons.target,
        accuracy >= 70
            ? _tr(context, 'Точность 70%+', '70%+ accuracy')
            : _tr(context, 'Поднять точность', 'Raise accuracy'),
        accuracy >= 70,
        AppColors.aqua,
      ),
      _BadgeData(
        LucideIcons.crown,
        user?.isPremium == true
            ? 'Premium'
            : _tr(context, 'Открыть Premium', 'Unlock Premium'),
        user?.isPremium == true,
        AppColors.gold,
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: _tr(context, 'Достижения', 'Achievements'),
            icon: Icons.workspace_premium_rounded,
            color: AppColors.gold,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) => _Badge(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _LoadingCard(height: 180),
        SizedBox(height: 14),
        _LoadingCard(height: 240),
        SizedBox(height: 14),
        _LoadingCard(height: 220),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;

  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.appPalette.secondaryFill,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionTitle({
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
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final DailyActivityModel item;
  final int maxValue;

  const _BarItem({required this.item, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final height = 26 + (82 * ((item.testsCount / maxValue).clamp(0.0, 1.0)));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${item.testsCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
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
          Text(
            _dayLabel(item.date, context),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeagueLeaderboardModel item;

  const _LeaderboardRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.isMe
            ? AppColors.gold.withValues(alpha: 0.12)
            : context.appPalette.secondaryFill,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#${item.rank}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: item.isMe ? AppColors.gold : null,
                  ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.aqua.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(item.name),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.xp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.aqua,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final int value;

  const _Ring({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 7,
              backgroundColor: context.appPalette.secondaryFill,
              color: AppColors.gold,
            ),
          ),
          Text('$value%', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _ScorePill({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.gold.withValues(alpha: 0.12)
            : context.appPalette.secondaryFill,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: highlighted ? AppColors.gold : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  final _SubjectRowData item;

  const _SubjectProgressRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.score >= 70
        ? AppColors.aqua
        : item.score >= 40
        ? AppColors.gold
        : AppColors.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              '${item.score}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: item.score / 100,
            minHeight: 8,
            backgroundColor: context.appPalette.secondaryFill,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String title;
  final bool done;

  const _TaskRow({required this.title, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: done
                ? AppColors.emerald.withValues(alpha: 0.16)
                : context.appPalette.secondaryFill,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Icon(
            done ? Icons.check_rounded : Icons.circle_outlined,
            size: 14,
            color: done ? AppColors.emerald : AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? AppColors.textMuted : null,
                ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final _BadgeData item;

  const _Badge({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: item.active ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 15, color: item.color),
          const SizedBox(width: 8),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.appPalette.secondaryFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final UserModel? user;

  const _AvatarBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _avatarUrl(user?.profilePictureUrl);
    final initials = _initials(user?.fullName ?? 'User');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: user?.isPremium == true
                ? const LinearGradient(colors: [Color(0xFFFFD166), AppColors.gold])
                : LinearGradient(
                    colors: [
                      AppColors.aqua.withValues(alpha: 0.24),
                      AppColors.aqua.withValues(alpha: 0.08),
                    ],
                  ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarFallback(context, initials),
                  )
                : _avatarFallback(context, initials),
          ),
        ),
        if (user?.isPremium == true)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'PRO',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarFallback(BuildContext context, String initials) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF132033)
          : Colors.white,
      alignment: Alignment.center,
      child: Text(initials, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _SubjectRowData {
  final String title;
  final int score;

  const _SubjectRowData(this.title, this.score);
}

class _BadgeData {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;

  const _BadgeData(this.icon, this.label, this.active, this.color);
}

String _tr(BuildContext context, String ru, String en) =>
    Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

String _firstName(String? fullName) {
  final clean = (fullName ?? '').trim();
  return clean.isEmpty ? 'User' : clean.split(RegExp(r'\s+')).first;
}

String _cleanText(String raw, String fallback) {
  final value = raw.trim();
  if (value.isEmpty || value.contains('Ð') || value.contains('â')) {
    return fallback;
  }
  return value;
}

String _dayLabel(String rawDate, BuildContext context) {
  final date = DateTime.tryParse(rawDate);
  if (date == null) return '•';
  const ru = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return (Localizations.localeOf(context).languageCode == 'ru' ? ru : en)[date.weekday - 1];
}

String _initials(String name) {
  final parts = name
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part.substring(0, 1).toUpperCase())
      .toList();
  return parts.isEmpty ? 'U' : parts.join();
}

String? _avatarUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
  final host = AppConstants.apiBaseUrl.replaceFirst('/api', '');
  return rawUrl.startsWith('/') ? '$host$rawUrl' : '$host/$rawUrl';
}
